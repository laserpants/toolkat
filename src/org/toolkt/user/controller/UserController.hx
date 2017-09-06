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
package org.toolkt.user.controller;

import org.toolkt.core.auth.Auth;
import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.interfaces.IRestController;
import org.toolkt.user.form.UserForm;
import org.toolkt.user.User;

class UserController extends AbstractController,
	implements IRestController
{

	/**
	 * Responds to:
	 * 
	 * GET /user
	 */
	public function indexAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /user/:id
	 */
	public function getAction():Void
	{
		var user:User = new User();
		var id:Int = Std.parseInt(this.request.getParam('id'));
		
		try {
			user.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('User not found');
		}
		
		this.render('user/get', {user: user}, true);
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /user/new
	 */
	public function newAction():Void
	{
		var form:UserForm = new UserForm();
		form.build();

		this.view.assignVar('form', form);
	}

	/**
	 * Responds to:
	 * 
	 * POST /user
	 */
	public function postAction():Void
	{
		var form:UserForm = new UserForm();
		var user:User = new User();
		form.build();
		
		if (form.isValid(this.request.getPost())) 
		{			
			user.name     = form.getValue('name');
			user.username = form.getValue('username');
			user.email    = form.getValue('email');
			user.password = form.getValue('password');
			
			try {
				user.save();
				
				this.addFlashMessage('You have successfully registered.');
				
				// Redirect
				this._redirect(this.request.getBaseUrl() + '/user/' + user.id);
				
			} catch (e:Dynamic) {
				// Show errors
			}
		}
		this.render('user/new', {form: form}, true);
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /user/edit/:id
	 */
	public function editAction():Void
	{
		// Make sure authenticated user corresponds to resource matching the uri
		var id:Int = this._verifyIdentity('edit');

		var form:UserForm = new UserForm();
		var user:User = new User();
		
		try {
			user.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('User not found');
		}
		
		form.build(user);
		
		form.populate(new org.toolkt.core.helper.QuickHash({
			name:     user.name,
			username: user.username,
			email:    user.email
		}));
		
		this.view.assignVar('form', form);
	}
	
	/**
	 * Responds to:
	 * 
	 * PUT /user/:id
	 */
	public function putAction():Void
	{
		// Make sure authenticated user corresponds to resource matching the uri
		var id:Int = this._verifyIdentity('id');
		
		var form:UserForm = new UserForm();
		var user:User = new User();
		
		try {
			user.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('User not found');
		}
		
		var changePwd:Bool = (null != this.request.getParam('password_change'));
		form.build(user, changePwd);
				
		if (form.isValid(this.request.getPost())) 
		{	
			user.name     = form.getValue('name');
			user.username = form.getValue('username');
			user.email    = form.getValue('email');
			
			if (true == changePwd) {
				user.password = form.getValue('password');
			}
			
			try {
				user.save();
				this.addFlashMessage('User profile has been updated.');
				
				// Redirect
				this._redirect(this.request.getBaseUrl() + '/user/' + user.id);
				
			} catch (e:Dynamic) {
				// Show errors
			}
		}
		this.render('user/edit', {
			form:      form, 
			changePwd: changePwd
		}, true);
	}
	
	/**
	 * Responds to:
	 * 
	 * DELETE /user/:id
	 * 
	 * @todo
	 */
	public function deleteAction():Void
	{
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();		// temporarily
		

		// Make sure authenticated user corresponds to resource matching the uri
		var id:Int = this._verifyIdentity('edit');
		
		// delete the user...
		// User.delete(id);
	}
	
	/**
	 * @return	The resource id
	 */
	private function _verifyIdentity(param:String):Int
	{
		// Make sure user is logged in, otherwise redirect to login page
		this._hasIdentityOrRedirect();
		
		var identity:AuthIdentity = org.toolkt.core.auth.Auth.getInstance().getIdentity();		
		var id:Int = Std.parseInt(this.request.getParam(param));
		
		if (id != identity.id) {	
			throw new org.toolkt.core.auth.exceptions.NotAuthorizedException('Not authorized');
		}
		return id;
	}
	
	private function _hasIdentityOrRedirect():Void
	{
		if (!Auth.getInstance().hasIdentity()) 
		{
			this._setAuthRedirectPath()
			    ._redirect(this.request.getBaseUrl() + '/login');
		}
	}
	
}