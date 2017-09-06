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
package org.toolkt.core.db.adapter;

import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.db.exceptions.DbException;

class Mysql extends AbstractAdapter
{

	private static inline var DB_TYPE          = 'Mysql';
	
	private static inline var DEFAULT_HOSTNAME = 'localhost';
	private static inline var DEFAULT_PORT     = 3306;
	private static inline var DEFAULT_USER     = 'root';
	private static inline var DEFAULT_PASSWORD = '';
	private static inline var DEFAULT_SOCKET   = null;
	
	/**
	 * Database host name
	 */
	private var _host:String;
	
	/**
	 * Port
	 */
	private var _port:Int;
	
	/**
	 * Db username
	 */
	private var _user:String;

	/**
	 * Db password
	 */
	private var _password:String;
	
	/**
	 * Socket
	 */
	private var _socket:String;

	override public function getDbType():String
	{
		return Mysql.DB_TYPE;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super(options);
		
		// Set default values
		this._host     = Mysql.DEFAULT_HOSTNAME;
		this._port     = Mysql.DEFAULT_PORT;
		this._user     = Mysql.DEFAULT_USER;
		this._password = Mysql.DEFAULT_PASSWORD;
		this._socket   = Mysql.DEFAULT_SOCKET;

		// Assign values from supplied options
		if (null != options.database) {
			this._database = options.database;
		} else {
			// Required value
			throw new DbException("No value provided for required field 'database'.");
		}
		if (null != options.host) {
			this._host = options.host;
		}
		if (null != options.port) {
			var port:String = options.port;
			this._port = Std.parseInt(port);
		}
		if (null != options.user) {
			this._user = options.user;
		}
		if (null != options.password) {
			this._password = options.password;
		}
		if (null != options.socket) {
			this._socket = options.socket;
		}
	}
	
    /**
     * Test if a connection is active
     */
	override public function isConnected():Bool
	{
		return (null != this._connection);			// !!??
	}

    /**
     * Force the connection to close
	 */
	override public function close():Void
	{
		if (!this.isConnected()) {
			return;
		}
		
		this._connection.close();
	}
	
    /**
     * Creates a connection to the database.
	 */ 
	override private function _connect():Void
	{
		if (this.isConnected()) {
			return;
		}
		
		this._connection = comp.db.Mysql.connect({
			host:     this._host,
			port:     this._port,
			user:     this._user,
			pass:     this._password,
			socket:   this._socket,
			database: this._database
		});
	}
	
}