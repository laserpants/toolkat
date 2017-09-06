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
package org.toolkt.core.session;

class SessionNamespace
{

	/**
	 * Hash with namespace instances.
	 */
	private static var _singleInstances:Hash<SessionNamespace> = new Hash();
	
	/**
	 * Namespace instance identifier.
	 */
	private var _namespace:String;
	
	/**
	 * Session storage
	 */
	private var _storage:Dynamic;
	
	/**
	 * Whether storage has data.
	 */
	private var _hasData:Bool;
	
	/**
	 * @return	Hash with namespace instances
	 */
	public static function getSingleInstances():Hash<SessionNamespace>
	{
		return SessionNamespace._singleInstances;
	}
	
	/**
	 * Write data to session storage.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function write(data:Dynamic):SessionNamespace
	{
		this._storage = data;
		this._hasData = true;
		
		return this;
	}
	
	/**
	 * Retrieve data from storage.
	 * 
	 * Throws an exception if storage is empty. Before reading storage
	 * a check should always be made with 'storageIsEmpty'.
	 * 
	 * @return	Session object
	 */
	public function read():Dynamic
	{
		if (true == this.storageIsEmpty()) {
			throw new org.toolkt.core.session.exceptions.StorageEmptyException();
		}
		
		return this._storage;
	}
	
	public function storageIsEmpty():Bool
	{
		if (null == this._storage) {
			return true;
		}
		
		return !this._hasData;
	}
	
	public function clear():Void
	{
		this._storage = {};
		this._hasData = false;
	}
	
	/**
	 * Constructor. Private, use static method SessionNamespace.get('namespace').
	 */
	private function new(namespace:String):Void
	{
		this._namespace = namespace;
		this._storage   = {};
		this._hasData   = false;
	}
	
	public static function get(namespace:String):SessionNamespace
	{
		if (!Session.isStarted()) {
			throw new org.toolkt.core.session.exceptions.SessionNotStartedException(
				'Session not started');
		}

		var session:SessionNamespace;
		if (SessionNamespace._singleInstances.exists(namespace)) {
			session = SessionNamespace._singleInstances.get(namespace);
		} else {
			session = new SessionNamespace(namespace);
			SessionNamespace._singleInstances.set(namespace, session);
		}
		
		return session;
	}
	
	public static function exists(namespace:String):Bool
	{
		return SessionNamespace._singleInstances.exists(namespace);
	}
	
	public static function unset(namespace:String):Bool
	{
		if (SessionNamespace._singleInstances.exists(namespace)) {
			SessionNamespace._singleInstances.remove(namespace);
			return true;
		}
		return false;
	}
	
}