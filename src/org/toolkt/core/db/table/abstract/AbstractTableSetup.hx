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
package org.toolkt.core.db.table.abstract;

import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.db.interfaces.IDbTableSetup;

typedef SqlSequence = Array<String>;

/* abstract */ class AbstractTableSetup implements IDbTableSetup
{

	/**
	 * Db adapter
	 */
	private var _adapter:AbstractAdapter;
	
	private var _sqlSequence:SqlSequence;

	/**
	 * Get db adapter. Lazy-load default adapter if none set.
	 */
	public function getDbAdapter():AbstractAdapter
	{
		if (null == this._adapter) {
			this._adapter = AbstractAdapter.getDefaultAdapter();
		}
		return this._adapter;
	}
	
	/**
	 * @return	Keywords used for primary key in CREATE TABLE statement
	 */
	public function getPrimaryKeywords():String
	{
		switch (this.getDbAdapter().getDbType()) {
			
			case 'Mysql':
				return 'INT NOT NULL AUTO_INCREMENT PRIMARY KEY';
			
			case 'Sqlite':
				return 'INTEGER PRIMARY KEY';
				
			default:
				throw 'Unknown db type';
		}
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		this._sqlSequence = new SqlSequence();
		this._init();
	}
	
	public function setup():IDbTableSetup
	{
		for (q in this._sqlSequence) {
			this.getDbAdapter().request(q);
		}
		return this;
	}
	
	private function _addSql(sql:String):Void
	{
		this._sqlSequence.push(sql);
	}
	
	/* abstract */ private function _init():Void
	{
		return throw "Abstract method";
	}

}