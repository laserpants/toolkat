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
package org.toolkt.core.auth.controller;

import org.toolkt.core.auth.Auth;
import org.toolkt.core.auth.form.SessionForm;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.interfaces.IRestController;
import org.toolkt.user.User;

/**
 * RESTful authentication controller
 */
class SessionController extends AbstractController,
	implements IRestController
{

	/**
	 * Overrides AbstractController.init to prevent AUTH_REDIRECT_NS
	 * session namespace from being deleted.
	 */
	override public function init():Void
	{
	}
	
	public function indexAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	public function getAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Login form, normally responds to: GET /session/new
	 * for convenience routed to:        GET /login
	 */
	public function newAction():Void
	{
		if (Auth.getInstance().hasIdentity()) {
			// Already logged in
			this._redirect(this.request.getBaseUrl());
		}
		
		var form:SessionForm = new SessionForm();
		
		this.render('login', 
			{
				title: 'Log in',
				form:  form
			},
			true
		);
	}

	/**
	 * Login action, responds to:
	 * 
	 * POST /session
	 */
	public function postAction():Void
	{
		var form:SessionForm  = new SessionForm();
		var post:Hash<String> = this.request.getPost();
		
		if (form.isValid(this.request.getPost())) {
			var user:User = new User();

			try {
				var username:String = form.getValue('username');
				var password:String = form.getValue('password');
				
				user.authenticate(username, password);			
				this.addFlashMessage('You have been successfully logged in.');
				
				// Redirect
				this._redirectToPreviousOr(this.request.getBaseUrl());
			} catch (e:org.toolkt.core.auth.exceptions.AuthException) {
				this.addFlashMessage('Authentication failed.');
			}
		}
		
		this.render('login', 
			{
				title: 'Log in',
				form:  form
			}, 
			true
		);
	}
	
	public function putAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Logout action, responds to:
	 * 
	 * DELETE /session
	 */
	public function deleteAction():Void
	{
		if (!Auth.getInstance().hasIdentity()) {
			this._redirect(this.request.getBaseUrl());
		}
		
		Auth.getInstance().clearIdentity();
		this.addFlashMessage('You have now logged out.');

		this._redirectToPreviousOr(this.request.getBaseUrl());
	}
	
}