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
package org.toolkt.core.auth;

import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.auth.interfaces.IAuthStorage;
import org.toolkt.core.auth.interfaces.IAuthAdapter;

class Auth
{
	
    /**
     * Singleton instance
	 */
	private static var _instance:Auth;
	
    /**
     * Persistent storage handler
	 */
	private var _storage:IAuthStorage;
	
	/**
	 * Constructor
	 * 
	 * Use Auth.getInstance(), Auth is singleton.
	 */
	private function new():Void;
	
	/**
	 * Get singleton instance.
	 */
	public static function getInstance():Auth
	{
		if (null == Auth._instance) {
			Auth._instance = new Auth();
		}
		return Auth._instance;
	}	

    /**
     * Sets the persistent storage handler.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setStorage(storage:IAuthStorage):Auth
	{
		this._storage = storage;
		return this;
	}
	
    /**
     * @return	The persistent storage handler
	 */
	public function getStorage():IAuthStorage
	{
		if (null == this._storage) {
			// Lazy-load session storage as default
			var storage:IAuthStorage = new org.toolkt.core.auth.storage.SessionStorage();
			this.setStorage(storage);
		}
		return this._storage;
	}
		
    /**
     * Authenticates against the supplied adapter.
	 * 
	 * @return	Authentication result object
	 */
	public function authenticate(adapter:IAuthAdapter):AuthResult
	{		
		var result:AuthResult = adapter.authenticate();

		if (true == result.isValid()) {
			var identity:AuthIdentity = result.getIdentity();
			this.getStorage().write(identity);
		}

		return result;
	}
	
    /**
     * Returns true if, and only if an identity is available from storage.
     */
    public function hasIdentity():Bool
	{
		return !this.getStorage().isEmpty();
	}
	
    /**
     * Returns the identity from storage or null if no identity is available.
	 */
    public function getIdentity():Dynamic
	{
		var storage:IAuthStorage = this.getStorage();

		if (storage.isEmpty()) {
			return null;
		}
	
		return storage.read();
	}
	
    /**
     * Clears the identity from persistent storage.
     */
    public function clearIdentity():Void
    {
		this.getStorage().clear();
	}
	
}