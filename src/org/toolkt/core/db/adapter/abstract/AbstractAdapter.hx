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
package org.toolkt.core.db.adapter.abstract;

//import comp.db.interfaces.IResultSet;
import comp.db.ResultSet;
import comp.db.Connection;

/* abstract */ class AbstractAdapter
{

	/**
	 * Name of the database
	 */
	private var _database:String;
	
    /**
     * Database connection
	 */
	private var _connection:Connection;
	
	/**
	 * Default db adapter
	 */
	private static var _defaultAdapter:AbstractAdapter;

	/* abstract */ public function getDbType():String
	{
		return throw "Abstract method";
	}
	
	/**
	 * Performs the escape method on the passed String value, then surrounds
	 * it with single quote characters.
	 */
	public function quote(str:String):String
	{
		if (null == this._connection) {
			this._connect();
		}
		return this._connection.quote(str);
	}
	
	/**
	 * Escapes illegal characters in the passed String value.
	 */
	public function escape(str:String):String
	{
		if (null == this._connection) {
			this._connect();
		}
		return this._connection.escape(str);
	}
	
	/**
	 * Set default db adapter
	 */
	public static function setDefaultAdapter(adapter:AbstractAdapter):Void
	{
		AbstractAdapter._defaultAdapter = adapter;
	}
	
	/**
	 * Get default db adapter
	 */
	public static function getDefaultAdapter():AbstractAdapter
	{
		return AbstractAdapter._defaultAdapter;
	}
	
	/**
	 * Force default db adapter connection to close.
	 */
	public static function closeDefault():Void
	{
		var adapter:AbstractAdapter = AbstractAdapter.getDefaultAdapter();
		if (null != adapter) {
			adapter.close();
		}		
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(?options:Dynamic):Void
	{
		if (Type.getClass(this) == AbstractAdapter) {
			throw "Abstract class, no instantiation";
		}
	}

	/* abstract */ public function isConnected():Bool
	{
		return throw "Abstract method";
	}
	
	/**
	 * Query database and return ResultSet.
	 */
	public function request(query:String):ResultSet
	{
		// Lazy connection
		this._connect();
		
		var result:ResultSet = this._connection.request(query);
		return result;
	}
	
	/* abstract */ public function close():Void
	{
		return throw "Abstract method";
	}
	
	/* abstract */ private function _connect():Void
	{
		return throw "Abstract method";
	}
	
}