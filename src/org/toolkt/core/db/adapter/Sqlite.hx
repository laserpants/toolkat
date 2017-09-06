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

class Sqlite extends AbstractAdapter
{

	private static inline var DB_TYPE = 'Sqlite';
	
	/**
	 * Filesystem path to Sqlite file storage.
	 */
	private var _path:String;

	override public function getDbType():String
	{
		return Sqlite.DB_TYPE;
	}
	
	/**
	 * Constructor. Required options are:
	 * 
	 *     database: Name of database
	 *     path:     Path to Sqlite file storage
	 *     --
	 */
	public function new(options:Dynamic):Void
	{
		// Call super constructor
		super(options);
		
		if (null != options.database) {
			this._database = options.database;
		} else {
			// Required value
			throw new DbException("No value provided for required field 'database'.");
		}
		if (null != options.path) {
			this._path    = options.path;
		} else {
			// Required value
			throw new DbException("No value provided for required field 'path'.");
		}
	}

    /**
     * Test if a connection is active
     */
	override public function isConnected():Bool
	{
		return (null != this._connection);
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
		this._connection = null;
	}
	
    /**
     * Creates a connection to the database.
	 */ 
	override private function _connect():Void
	{
		if (this.isConnected()) {
			return;
		}

		if (null == this._database) {
			throw new DbException('No database specified.');
		}

		/**
		 * Check if database exists in file system.
		 */
		var dbFile:String = this._path + this._database;
		
		if (!comp.FileSystem.exists(dbFile)) {
			throw new DbException('Sqlite database file not found.');
		}
		
		this._connection = comp.db.Sqlite.open(dbFile);		
	}
	
}