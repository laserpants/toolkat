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
package org.toolkt.post.comment.form;

import org.toolkt.post.comment.Comment;
import org.toolkt.core.form.element.Submit;
import org.toolkt.core.form.element.Hidden;
import org.toolkt.core.form.element.TextArea;
import org.toolkt.core.form.element.TextField;
import org.toolkt.core.form.filter.StripTags;
import org.toolkt.core.form.filter.Trim;
import org.toolkt.core.form.validate.Email;
import org.toolkt.core.form.validate.StringLength;

class CommentForm extends org.toolkt.core.form.Form
{

	/**
	 * Comment object
	 */
	private var _comment:Comment;
	
	/**
	 * Is this a form for editing an existing comment?
	 */
	private var _isEdit:Bool;
	
	public function setComment(comment:Comment):CommentForm
	{
		this._comment = comment;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void 
	{
		super();
	}
	
	public function build(?comment:Comment):CommentForm
	{
		this._isEdit = (comment != null);
		
		if (null == comment) {
			comment = new Comment();
		}
		
		this.setComment(comment)
		    ._buildElements();
		
		return this;
	}
	
	private function _buildElements():Void
	{
		var email:TextField = new TextField('email');
		
		email.setRequired(true)
		     .setLabel('Email address')
			 .addValidator(Email, {
				message: 'Value is not a valid email address.',
			 });
		
		var content:TextArea = new TextArea('content');

		content.setRequired(true)
		       .setLabel('Comment')
		   	   .addFilter(Trim)
			   .addFilter(StripTags)
			   .addValidator(StringLength, { min:3 });
		
		var postId:Hidden = new Hidden('postId');
		
		postId.setRequired(true);
//		      .addFilter(Int)						// @todo	!!!!
	
		var submit:Submit = new Submit('submit');
		
		this.addElement(email)
		    .addElement(content)
			.addElement(postId)
			.addElement(submit);

		var action:String = this.getBaseUrl() + 'comment'; 
		
		if (this._isEdit) {
			action += '/' + this._comment.id;
		} 
		this.setAction(action);
	}
	
}