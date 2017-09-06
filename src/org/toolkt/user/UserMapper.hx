/**
 * NOTICE OF LICENSE
 *
 * Copyright (c) 2010, Tristar Holdings (EA) www.tristarafrica.com
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     - Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     - Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     - Neither the name of this software nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software 
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL TRISTAR HOLDINGS (EA) BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.toolkt.user;

import comp.db.ResultSet;
import org.toolkt.core.auth.adapter.Md5DigestAdapter;
import org.toolkt.core.auth.interfaces.IAuthAdapter;
import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.form.interfaces.IValueIntegrityMapper;
import org.toolkt.core.model.abstract.AbstractDbMapper;
import org.toolkt.user.interfaces.IUserMapper;
import org.toolkt.user.User;

class UserMapper extends AbstractDbMapper<User>,
	implements IUserMapper<User>,
	implements IValueIntegrityMapper
{
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
	/**
	 * Find user with supplied id. Throws UserNotFoundException
	 * if no user found.
	 */
	override public function find(user:User, id:Int):Void
	{
		var sql:String = 
			  "SELECT id, username, name, password_salt, password_hash, email "
			+ "FROM user_users " 
			+ "WHERE id = " + id + " "
			+ "LIMIT 1;";
			
		this._find(sql, user);
	}
	
	/**
	 * Find user with supplied username. Throws UserNotFoundException
	 * if no user found.
	 */
	public function findByUsername(user:User, username:String):Void
	{
		var sql:String = 
			  "SELECT id, username, name, password_salt, password_hash, email "
			+ "FROM user_users " 
			+ "WHERE username = '" + username + "' "
			+ "LIMIT 1;";
			
		this._find(sql, user);
	}
	
	/**
	 * Saves user to db.
	 */
	override public function save(user:User):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		var sql:String;
		
//		var digest:Md5DigestAdapter 
//			= this._typeCastAdapter(user.getAuthAdapter());

		var digest:Md5DigestAdapter = user.getAuthAdapter();
		
		if (null != user.password) {
			digest.calculateHash(user.password);
		}
		
		if (null == user.id) {
			
			// Create new db row
			sql = "INSERT INTO user_users (username, name, email, password_salt, password_hash) "
				+ "VALUES ("
				+ "'" + user.username    + "', "
				+ "'" + user.name        + "', "
				+ "'" + user.email       + "', "
				+ "'" + digest.getSalt() + "', "
				+ "'" + digest.getHash() + "'"
				+ ");";
		} else {
			
			// Update existing db row
			sql = "UPDATE user_users SET "
				+ "username = '"      + user.username    + "', "
				+ "name = '"          + user.name        + "', "
				+ "email = '"         + user.email       + "', "
				+ "password_salt = '" + digest.getSalt() + "', "
				+ "password_hash = '" + digest.getHash() + "' "
				+ "WHERE id = "       + user.id          + ";";
		}

		db.request(sql);
		
		if (null != user.id)  return;
		
		var sql:String;
		switch (db.getDbType()) 
		{
			case 'Sqlite':			
				sql = 'SELECT last_insert_rowid() AS id;';
					
			case 'Mysql':
				sql = 'SELECT last_insert_id( ) AS id;';
				
			default:
				throw 'n/i';	// ?
		}
		
		var result:ResultSet = db.request(sql);
		
		if (0 == result.length)  return;

		var rowData:Dynamic = result.next();
		user.id = rowData.id;
	}
	
	public function valueIsUnique(field:String, value:String):Bool
	{
		if (field != 'username' && field != 'email') {
			throw 'Error, can\'t check value integrity of provided field.';
		}
		
		var db:AbstractAdapter = this.getDbAdapter();
		
		var sql:String = "SELECT count(id) AS count FROM user_users WHERE " 
		               + field + " = '" + value + "';";
					   
		var result:ResultSet = db.request(sql);
		var rowData:Dynamic   = result.next();
		
		return (rowData.count == 0);
	}

	/*
	private function _typeCastAdapter(adapter:IAuthAdapter):Md5DigestAdapter
	{
		try {
			return cast(adapter, Md5DigestAdapter);
		} catch (e:Dynamic) {
			throw "UserMapper expects authentication adapter of type Md5DigestAdapter";
		}
	}
	*/
	
	private function _find(sql:String, user:User):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		var result:ResultSet  = null;
		
		try {
			result = db.request(sql);
			if (1 == result.length) {
				
				var rowData:Dynamic = result.next();
				
				user.id       = rowData.id;
				user.username = rowData.username;
				user.name     = rowData.name;
				user.email    = rowData.email;
				
//				var digest:Md5DigestAdapter 
//					= this._typeCastAdapter(user.getAuthAdapter());

				var digest:Md5DigestAdapter = user.getAuthAdapter();

				digest.setHash(rowData.password_hash);
				digest.setSalt(rowData.password_salt);
				
				// Everything ok, clean return
				return;	
			}
		} catch (e:Dynamic) {
			// Continue and throw UserNotFoundException
		}
		throw new org.toolkt.user.exceptions.UserNotFoundException();		
	}
	
}