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

class Memcached 
{

	/**
	 * MemcachedClient instance
	 */
	private static var _clientInstance:MemcachedClient;
	
	/**
	 * Individual Memcached client namespaces
	 */
	private static var _clientNamespaces:Hash<MemcachedNamespace> = new Hash();

	/**
	 * Get MemcachedClient instance.
	 */
	public static function getClientInstance():MemcachedClient
	{
		if (null == Memcached._clientInstance) {
			Memcached._clientInstance = new MemcachedClient('localhost');
		}
		if (null == Memcached._clientInstance.getConnection()) {
			throw "Memcached error: no connection";
		}
		return Memcached._clientInstance;
	}
		
	/**
	 * @return	Memcached namespace matching provided name
	 */
	public static function getClientNamespace(namespace:String):MemcachedNamespace
	{
		return Memcached._clientNamespaces.get(namespace);
	}
	
	/**
	 * Determine if Memcached client with provided namespace exists.
	 */
	public static function hasNamespace(namespace:String):Bool
	{
		return Memcached._clientNamespaces.exists(namespace);
	}
	
	/**
	 * Creates new Memcached client with unique namespace. Throws an 
	 * exception if namespace already exists. 
	 * 
	 * If successful, the namespace is added to _clientNamespaces
	 * hash and returned.
	 */
	public static function createNamespace(namespace:String):MemcachedNamespace
	{
		if (Memcached._clientNamespaces.exists(namespace)) {
			throw "Memcached client namespace already occupied.";
		}
		
		var client:MemcachedNamespace = new MemcachedNamespace(namespace);
		Memcached._clientNamespaces.set(namespace, client);
		return client;
	}
	
	/**
	 * Deletes a Memcached client namespace.
	 */
	public static function deleteNamespace(namespace:String):Void
	{
		if (!Memcached._clientNamespaces.exists(namespace)) {
			return;
		}
		
		Memcached._clientNamespaces.remove(namespace);
	}
	
	/**
	 * Constructor -- disabled.
	 */
	private function new():Void
	{
		throw "No instantiation";
	}
	
}