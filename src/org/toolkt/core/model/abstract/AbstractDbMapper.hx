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
package org.toolkt.core.model.abstract;

import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.model.interfaces.IDataMapper;

/* abstract */ class AbstractDbMapper<T> implements IDataMapper<T>
{

	/**
	 * Db adapter
	 */
	private var _adapter:AbstractAdapter;
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractDbMapper) {
			throw "Abstract class, no instantiation";
		}
	}

	/**
	 * Set db adapter.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setDbAdapter(adapter:AbstractAdapter):AbstractDbMapper<T>
	{
		this._adapter = adapter;
		return this;
	}
	
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

	/* abstract */ public function fetchAll():Array<T>
	{
		return throw "Abstract method";
	}

	/* abstract */ public function find(item:T, id:Int):Void
	{
		return throw "Abstract method";
	}

	/* abstract */ public function save(item:T):Void
	{
		return throw "Abstract method";
	}
	
	private function _getSafeDate(date:Date):String
	{
		var d:String;
		try {
			d = date.toString();
		} catch (e:Dynamic) {
			d = '0000-00-00 00:00:00';
		}
		return d;
	}
	
}