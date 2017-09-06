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

import org.toolkt.core.auth.adapter.Md5DigestAdapter;
import org.toolkt.core.auth.AuthResult;
import org.toolkt.user.abstract.AbstractUser;
import org.toolkt.user.interfaces.IUserMapper;
import org.toolkt.user.UserMapper;

class User extends AbstractUser<UserMapper, Md5DigestAdapter>
{

	public var email:String;
	public var name:String;

	/**
	 * Get the authentication adapter. Lazy-load default adapter if null.
	 */
	override public function getAuthAdapter():Md5DigestAdapter
	{
		if (null == this._authAdapter) {
			this._authAdapter = new Md5DigestAdapter();
		}
		return this._authAdapter;
	}
	
	/**
	 * Get data mapper. Lazy-load default UserMapper if null.
	 */
	override public function getMapper():UserMapper
	{
		if (null == this._mapper) {
			this._mapper = new UserMapper();
		}
		return this._mapper;
	}
	
	/**
	 * Creates an authentication identity for user.
	 */
	override public function buildIdentity():AuthIdentity
	{
		var identity:AuthIdentity = {
			username: this.username,
			id:       this.id
		}
		return identity;
	}

	/**
	 * Load model with data from resource corresponding to supplied id.
	 */
	override public function find(id:Int):Void
	{
		this.getMapper().find(this, id);
		
		// Data was successfully loaded
		this._loaded = true;
	}
	
	/**
	 * Load user with supplied username.
	 * 
	 * @see		IUserMapper
	 */
	override public function findByUsername(username:String):Void
	{
		this.getMapper().findByUsername(this, username);
		
		// Data was successfully loaded
		this._loaded = true;
	}
	
	/**
	 * Save the user.
	 */
	override public function save():Void
	{
		this.getMapper().save(this);
	}
	
}