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
package org.toolkt.core.cache.storage;

import org.toolkt.core.cache.storage.abstract.AbstractCacheStorage;
import org.toolkt.mmcd.Memcached;
import org.toolkt.mmcd.MemcachedNamespace;

class CacheMemoryStorage extends AbstractCacheStorage
{
	
	private static inline var MEMCACHED_NAMESPACE = 'cache';
	
	private var _memcachedClient:MemcachedNamespace;
	
	public function getMemcachedClient():MemcachedNamespace
	{
		if (null == this._memcachedClient) {
			var client:MemcachedNamespace;
			var ns:String = CacheMemoryStorage.MEMCACHED_NAMESPACE;
			
			client = Memcached.hasNamespace(ns) ? 
				Memcached.getClientNamespace(ns) : Memcached.createNamespace(ns);
			
			this._memcachedClient = client;
		}
		return this._memcachedClient;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super();		
	}

	override public function exists(id:String):Bool
	{	
		return (null != this.getMemcachedClient().get(id));
	}
	
	override public function load(id:String):String
	{
		var item:memcached.Item;
		var str:String = null;
		
		try {
			item = this.getMemcachedClient().get(id);
			
			if (null == item) {
				throw new org.toolkt.core.cache.exceptions.InvalidDataException(
					'Memcached item is null');
			}
			
			var data:haxe.io.Bytes = item.data;
			str = data.readString(0, data.length);
			
		} catch (e:Dynamic) {
			// this.getMemcachedClient().closeConnection();
			throw e;
		}
		
		if (null == str) {
			throw new org.toolkt.core.cache.exceptions.InvalidDataException(
				'Empty string return from Memcached data');
		}
		return str;
	}

	/**
	 * @todo
	 */
	override public function save(data:String, id:String):Void
	{	
		if (null == data || null == id)
			return;

		try {
			var bytes:haxe.io.Bytes = comp.Lib.bytesReference(data);
			if (this.getMemcachedClient().set(id, bytes)) {
				return;
			}
		} catch (e:Dynamic) {
			// ...
		}
		
		// @todo: Write error to log
	}

	override public function clear():Void
	{
		this.getMemcachedClient().flushAll();
	}
	
}