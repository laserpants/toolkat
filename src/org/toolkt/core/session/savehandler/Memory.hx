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
package org.toolkt.core.session.savehandler;

import org.toolkt.core.session.SessionNamespace;
import org.toolkt.core.session.interfaces.ISessionSaveHandler;
import org.toolkt.mmcd.Memcached;
import org.toolkt.mmcd.MemcachedNamespace;

class Memory implements ISessionSaveHandler
{

	/**
	 * Memcached namespace prefix
	 */
	private static inline var MEMCACHED_NAMESPACE = 'session';
	
	private var _memcachedClient:MemcachedNamespace;
	
	public function getMemcachedClient():MemcachedNamespace
	{
		if (null == this._memcachedClient) {
			this._memcachedClient = 
				Memcached.createNamespace(Memory.MEMCACHED_NAMESPACE);
		}
		return this._memcachedClient;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void;
	
	/**
	 * Determine if session with specified id exists in storage.
	 */
	public function exists(sessionId:String):Bool
	{
		return (null != this.getMemcachedClient().get(sessionId));
	}
	
	/**
	 * Populate namespaces from data in session storage.
	 */
	public function populate(sessionId:String):Void
	{
		if (!this.exists(sessionId)) {
			throw "No session data";
		}

		var item:memcached.Item;
		var str:String = null;
		
		try {
			item = this.getMemcachedClient().get(sessionId);
			
			var data:haxe.io.Bytes = item.data;
			str = data.readString(0, data.length);
			
		} catch (e:Dynamic) {
			// this.getMemcachedClient().closeConnection();
			throw e;
		}

		var sessionObject:Hash<Dynamic> = haxe.Unserializer.run(str);
		
		for (key in sessionObject.keys()) {
			var namespace:SessionNamespace = SessionNamespace.get(key);
			var obj:Dynamic = sessionObject.get(key);
			namespace.write(obj);
		}
	}

	/**
	 * Serialize namespace data objects and save to storage.
	 */
	public function save(sessionId:String):Void
	{
		var namespaces:Hash<SessionNamespace> = 
			SessionNamespace.getSingleInstances();
			
		var sessionObject:Hash<Dynamic> = new Hash();
//		var hasData:Bool = false;
		for (key in namespaces.keys()) {
			var namespace:SessionNamespace = namespaces.get(key);
			if (!namespace.storageIsEmpty()) {
				var storage:Dynamic = namespace.read();
				sessionObject.set(key, storage);
//				hasData = true;
			}
		}
		
//		if (!hasData) {
//			this.getMemcachedClient().delete(sessionId);			// doesn't work !?
//			this.getMemcachedClient().set(sessionId, null);
//			return;
//		}

		var str:String = 
			haxe.Serializer.run(sessionObject);
		
		this.getMemcachedClient().set(sessionId, 
			comp.Lib.bytesReference(str));
	}
	
}