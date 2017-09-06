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
package org.toolkt.user.abstract;

import org.toolkt.core.auth.adapter.Md5DigestAdapter;
import org.toolkt.core.auth.Auth;
import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.auth.exceptions.AuthException;
import org.toolkt.core.auth.interfaces.IAuthAdapter;
import org.toolkt.user.interfaces.IUserMapper;
import org.toolkt.core.model.abstract.AbstractModel;
import org.toolkt.user.UserMapper;

/**
 * Abstract base class for User model. 
 */
/* abstract */ class AbstractUser<T, E:IAuthAdapter> extends AbstractModel<T>
{

	public var id:Int;
	public var username:String;
	public var password:String;

	/**
	 * Adapter used for user authentication.
	 */
	private var _authAdapter:E;

	/* abstract */ public function getAuthAdapter():E
	{
		return throw "Abstract method";
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}

	/* abstract */ public function find(id:Int):Void
	{
		return throw "Abstract method";
	}
	
	/* abstract */ public function findByUsername(username:String):Void
	{
		return throw "Abstract method";
	}
	
	/* abstract */ public function save():Void
	{
		return throw "Abstract method";
	}
		
	/**
	 * Performs authentication attempt with the provided adapter.
	 * Throws org.toolkt.core.auth.exceptions.AuthException unless
	 * authentication adapter returns Success.
	 */
	public function authenticate(username:String, password:String):Void
	{
		// Set default result value; for unspecified errors
		var result:AuthResult = new AuthResult(FailureUnspecified, null);
		
		if ('' == username || '' == password) {
			// Missing username or password
			throw new AuthException(
				new AuthResult(FailureIncompleteCredentials, null), 
					'Username or password is blank');
		}
		this.username = username;
		
		if (!isLoaded()) {
			try {
				// Throws UserNotFoundException if user not found
				this.findByUsername(this.username);
				
			} catch (e:org.toolkt.user.exceptions.UserNotFoundException) {
				// User was not found
				throw new AuthException(
					new AuthResult(FailureIdentityNotFound, null), 
						'User not found');
						
			} catch (e:Dynamic) {
				// Other exceptions bubbles up
				throw e;
			}
		}		
		var identity:AuthIdentity = this.buildIdentity();
		
		// Get authentication adapter
		var adapter:IAuthAdapter = this.getAuthAdapter();
		adapter.setIdentity(identity)
		       .setPassword(password);
		
		try {
			result = Auth.getInstance()
			             .authenticate(adapter);										
						 
			if (result.isValid()) {
				return;
			}
		} catch (e:Dynamic) {
			// Continue and throw exception
		}
		throw new AuthException(result, 'Authentication failed');
	}
	
	/* abstract */ public function buildIdentity():AuthIdentity
	{
		return throw "Abstract method";
	}
	
}