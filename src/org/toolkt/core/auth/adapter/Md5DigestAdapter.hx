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
package org.toolkt.core.auth.adapter;

import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.auth.interfaces.IAuthAdapter;
import org.toolkt.core.controller.FrontController;

class Md5DigestAdapter implements IAuthAdapter
{

	/**
	 * Authentication identity
	 */
	private var _identity:AuthIdentity;

	/**
	 * Password hash
	 */
	private var _hashStr:String;
	
	/**
	 * Password salt
	 */
	private var _salt:String;
	
	/**
	 * Unencrypted password
	 */
	private var _plainPassword:String;
	
	/**
	 * Encryption key
	 */
	private var _key:String;
	
	/**
	 * Set authentication identity
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setIdentity(identity:AuthIdentity):IAuthAdapter
	{
		this._identity = identity;
		return this;
	}
	
	/**
	 * Set password hash
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setHash(hash:String):Md5DigestAdapter
	{
		this._hashStr = hash;
		return this;
	}
	
	/**
	 * @return	Password hash
	 */
	public function getHash():String
	{
		return this._hashStr;
	}

	/**
	 * Set password salt
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setSalt(salt:String):Md5DigestAdapter
	{
		this._salt = salt;
		return this;
	}
	
	/**
	 * @return	Password salt
	 */
	public function getSalt():String
	{
		return this._salt;
	}
	
	/**
	 * Set unencrypted password used for authentication.
	 * 
	 * @return 	Provides a fluent interface
	 */
	public function setPassword(pass:String):IAuthAdapter
	{
		this._plainPassword = pass;
		return this;
	}

	/**
	 * Constructor
	 */
	public function new():Void
	{
		this._key = FrontController.getInstance().getParam('encryptKey');
	}

    /**
     * Performs an authentication attempt and returns the result.
	 */
	public function authenticate():AuthResult
	{
		var result:AuthResult;

		if (null == this._hashStr
			|| null == this._salt
			|| null == this._plainPassword) {
			throw "Incomplete Md5DigestAdapter parameters";
		}
		
		if (this._digest() == this._hashStr) {
			result = new AuthResult(Success, this._identity);
			return result;
		}

		result = new AuthResult(FailureInvalidCredential, this._identity);
		return result;
	}
	
	/**
	 * Generates password hash from supplied plain-text
	 * password + random salt.
	 */
	public function calculateHash(password:String):Void
	{
		if ('' == password) {
			throw "Password is blank";
		}
		
		this._plainPassword 
			          = password;
		this._salt    = this._generateSalt();
		this._hashStr = this._digest();
	}
	
	private function _generateSalt():String
	{
		var str:String 
			      = '' + haxe.Timer.stamp();
		var c:Int = 0;
		while (c < 10) {
			str += '--'
			    +  Math.ceil(Math.random() * 100000);
			c++;
		}
		return haxe.Md5.encode(str);
	}
	
	private function _digest():String
	{
		if (null == this._key) {
			throw 'Error, no encryption key';
		}
		
		var plain:String  = this._plainPassword;
		var key:String    = this._key;
		var salt:String   = this._salt;
		var digest:String = key;		
		var c:Int         = 0;
		
		while (c < 10) {			
			var str:String = 
				  digest   + '--' 
				+ salt     + '--' 
				+ plain    + '--' 
				+ key;
				
			digest = haxe.Md5.encode(str);
			c++;
		}
		return digest;
	}
	
}