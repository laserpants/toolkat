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
package org.toolkt.user.form;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.form.element.PasswordField;
import org.toolkt.core.form.element.Submit;
import org.toolkt.core.form.element.TextField;
import org.toolkt.core.form.filter.StripTags;
import org.toolkt.core.form.filter.Trim;
import org.toolkt.core.form.validate.Email;
import org.toolkt.core.form.validate.Identical;
import org.toolkt.core.form.validate.StringLength;
import org.toolkt.core.form.validate.ValueIntegrity;
import org.toolkt.user.form.validate.CurrentPassword;
import org.toolkt.user.User;

/**
 * Form to create/edit user.
 */
class UserForm extends org.toolkt.core.form.Form
{

	/**
	 * User object
	 */
	private var _user:User;
	
	/**
	 * Is this a form for editing an existing user?
	 */
	private var _isEdit:Bool;
	
	/**
	 * Whether form should update user's password.
	 */
	private var _changePwd:Bool;
	
	/**
	 * Assign user object that form operates on.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setUser(user:User):UserForm
	{
		this._user = user;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void 
	{
		super();
	}
	
	public function build(?user:User, ?changePdw:Bool = true):Void
	{
		this._isEdit = (user != null);
		
		if (null == user) {
			user = new User();
		}
		
		this._changePwd = changePdw;
		
		this.setUser(user)
		    ._buildElements();
	}
	
	private function _buildElements():Void
	{
		var name:TextField = new TextField('name');
		
		name.setRequired(true)
		    .setLabel('Name')
			.addFilter(Trim)
			.addFilter(StripTags);
		
		var username:TextField = new TextField('username');
		
		username.setRequired(true)
		        .setLabel('Username')
				.addFilter(Trim)
			    .addValidator(ValueIntegrity, {
					mapper:  this._user.getMapper(),
					field:   'username',
					message: 'The username is already taken.',
					exclude: this._user.username
				})
				.addValidator(StringLength, { min:4, max:16 });
		
		var email:TextField = new TextField('email');

		email.setRequired(true)
		     .setLabel('Email')
			 .addFilter(Trim)
			 .addValidator(ValueIntegrity, {
				mapper:  this._user.getMapper(),
				field:   'email',
				message: 'A user with this email address already exists.',
				exclude: this._user.email})
			 .addValidator(Email, {
				message: 'Value is not a valid email address.',
			 });
		
		var password:PasswordField = new PasswordField('password');

		password.setRequired(true)
		        .setLabel('Password')
				.addValidator(StringLength, { min:8 });

		var confirmation:PasswordField = new PasswordField('confirmation');

		confirmation.setRequired(true)
		            .setLabel('Password confirmation')
					.addValidator(Identical, { 
						field:   'password',
						message: 'Password confirmation doesn\'t match password.'
					});
		
		var submit:Submit = new Submit('submit');
		
		this.addElement(name)
		    .addElement(username)
		    .addElement(email)
			.addElement(password)
			.addElement(confirmation)
			.addElement(submit);

		if (this._isEdit && !this._changePwd) 
		{
			// Ignore password fields if 'update password' is not checked
			password.setRequired(false)
			        .removeFilters()
					.removeValidators();
					
			confirmation.setRequired(false)
						.removeFilters()
						.removeValidators();
		}
		
		var action:String = this.getBaseUrl() + 'user'; 
		
		if (this._isEdit) {
			var current:PasswordField = new PasswordField('current');
			current.setLabel('Current password');
				   
			if (this._changePwd) {
				current.setRequired(true)
				       .addValidator(CurrentPassword, {
						   user: this._user
					   });
			}
				   
			this.addElement(current);
			action += '/' + this._user.id;
		} 
		this.setAction(action);
	}
	
}