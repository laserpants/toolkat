﻿/**
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
package org.toolkt.core.auth.form;

import org.toolkt.core.form.element.PasswordField;
import org.toolkt.core.form.element.Submit;
import org.toolkt.core.form.element.TextField;

/**
 * Builds a simple login form.
 */
class SessionForm extends org.toolkt.core.form.Form
{

	/**
	 * Constructor
	 */
	public function new():Void 
	{
		super();
		
		this._buildElements();
	}
	
	/**
	 * Creates the login form.
	 */
	private function _buildElements():Void
	{
		var username:TextField = new TextField('username');
		
		username.setRequired(true)
				.addFilter(org.toolkt.core.form.filter.Trim)
				.setLabel('Username');

		var password:PasswordField = new PasswordField('password');
		
		password.setRequired(true)
		        .setLabel('Password');

		var submit:Submit = new Submit('login');
		
		this.addElement(username)
		    .addElement(password)
			.addElement(submit);
			
		this.setAction(this.getBaseUrl() + 'session');
	}
	
}