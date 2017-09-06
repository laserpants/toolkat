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
package org.toolkt.mmcd;

import org.toolkt.mmcd.interfaces.IMemcachedClient;

class MemcachedNamespace implements IMemcachedClient
{

	private var _namespace:String;
	
	public function new(namespace:String):Void
	{
		this._namespace = namespace;
	}

	public function get(key:String):Dynamic
	{
		var nsKey:String = this._getNamespacedKey(key);
		return Memcached.getClientInstance().getConnection().get(nsKey);
	}
	
	public function set(key:String, any:Dynamic, ?expiresSeconds:Int):Bool
	{
		var nsKey:String = this._getNamespacedKey(key);
		return Memcached.getClientInstance().getConnection().set(nsKey, any, expiresSeconds);
	}
	
	public function delete(key:String):Bool
	{
		return Memcached.getClientInstance().getConnection().delete(key);
	}
	
	public function flushAll(?delay:Int):Bool 
	{
		return Memcached.getClientInstance().getConnection().flushAll(delay);
	}
	
//	public function closeConnection():Void
//	{
//		Memcached.getClientInstance().closeConnection();
//	}
	
	private function _getNamespacedKey(key:String):String
	{
		if (null == this._namespace) {
			throw "Error, namespace is blank";
		}
		return this._namespace + '_' + key;
	}
	
}