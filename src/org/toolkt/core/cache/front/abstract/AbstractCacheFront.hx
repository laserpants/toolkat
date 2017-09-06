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
package org.toolkt.core.cache.front.abstract;

import org.toolkt.core.cache.storage.abstract.AbstractCacheStorage;
import org.toolkt.core.controller.abstract.AbstractController;

/* abstract */ class AbstractCacheFront 
{
	/**
	 * @todo
	 * 
	 * Hash to keep track of keys for each front instance
	 * to make it possible to delete them individually.
	 * 
	 * Each time data is written, an id needs to be set
	 * here as well (if not already existing)
	 * 
	 *    front name => [id, id, id ...]
	 */
//	private static var _frontData:Hash<Array<String>>;
	
	/**
	 * Prefix used to separate cache fronts of same class
	 */
	private var _frontName:String;
	
	/**
	 * Storage handler instance
	 */
	private var _storage:AbstractCacheStorage;
	
	/**
	 * Set storage handler
	 */
	public function setStorage(storage:AbstractCacheStorage):Void
	{
		this._storage = storage;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(?options:Dynamic):Void
	{
		if (Type.getClass(this) == AbstractCacheFront) {
			throw "Abstract class, no instantiation";
		}
		
		// Set instance prefix, if one provided
		if (null != options.prefix) {
			this._frontName = options.prefix;
		}
	}
	
    /**
     * @return	True if cache exists for given id, otherwise false.
	 */
	public function exists(id:String):Bool
	{
		return this._storage.exists(
			this._getNamespacedId(id));
	}
	
    /**
     * Unserialize cache string for the given id  
	 * and return stored object.
	 */
	public function load(id:String):Dynamic
	{
		var str:String = this._storage.load(this._getNamespacedId(id));
		return haxe.Unserializer.run(str);			
	}
	
    /**
     * Save data in cache.
     */
	public function save(data:Dynamic, id:String):Void
	{
		if (null == data)  { return; }
		var str:String = haxe.Serializer.run(data);		
		this._storage.save(str, this._getNamespacedId(id));
	}
	
	/**
	 * Clear cached data.
	 */
	public function clear():Void
	{
		this._storage.clear();
	}

	/**
	 * Prepend lower-case class name + optional frontName prefix to 
	 * storage identifier to avoid namespace collisions between cache
	 * front handlers.
	 * 
	 * @return	Id in format: prefix_page_c13d88cb4cb02003daedb8a84e5d272a
	 */
	private function _getNamespacedId(id:String):String
	{
		var className:String    = Type.getClassName(Type.getClass(this)).toLowerCase();
		var parts:Array<String> = className.split('.');
		var prefix:String       = parts[parts.length - 1];
		
		if (null != this._frontName) {
			prefix = this._frontName + '_' + prefix;
		}
		return prefix + '_' + id;
	}
	
}