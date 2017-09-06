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
package org.toolkt.user.form.validate;

import org.toolkt.core.auth.interfaces.IAuthAdapter;
import org.toolkt.core.form.validate.abstract.AbstractValidator;
import org.toolkt.user.abstract.AbstractUser;
import org.toolkt.user.interfaces.IUserMapper;

class CurrentPassword<T:AbstractUser<IUserMapper<T>, IAuthAdapter>> extends AbstractValidator<String>
{
	
	private static inline var ERROR_PASSWORD_MISMATCH = 'current_password_mismatch';

	private static inline var ERROR_GENERAL           = 'password_authentication_error';

	private var _user:T;
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super(options);
		
		if (null == options.user) {
			throw "Option user required for validator CurrentPassword";
		}
		this._user = options.user;
	}

	override public function isValid(value:String, ?context:Hash<String>):Bool
	{
		try {
			this._user.authenticate(this._user.username, context.get('current'));
		} catch (e:org.toolkt.core.auth.exceptions.AuthException) { 
			this._error(CurrentPassword.ERROR_PASSWORD_MISMATCH, 'Incorrect password');
			return false;
		} catch (e:Dynamic) {
			this._error(CurrentPassword.ERROR_GENERAL, 'Couldn\'t verify password');
			return false;
		}
		return true;
	}
	
}