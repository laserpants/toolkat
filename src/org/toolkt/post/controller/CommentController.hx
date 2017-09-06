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
package org.toolkt.post.controller;

import org.toolkt.core.auth.Auth;
import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.interfaces.IRestController;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.paginator.Paginator;
import org.toolkt.post.comment.Comment;
import org.toolkt.post.comment.form.CommentForm;
import org.toolkt.post.Post;
import org.toolkt.user.User;

class CommentController extends AbstractController,
	implements IRestController
{

	/**
	 * Responds to:
	 * 
	 * GET /comment
	 */
	public function indexAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /comment/:id
	 */
	public function getAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}

	/**
	 * Responds to:
	 * 
	 * GET /comment/new/post/:post
	 */
	public function newAction():Void
	{
		var id:Int = Std.parseInt(this.request.getParam('post'));
		
		if (null == id) {
			// Error 404
			throw new org.toolkt.core.controller.exceptions.InvalidActionException();
		}
		
		var post:Post = new Post();
		try {
			post.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('Post not found');
		}
		
		var form:CommentForm = new CommentForm();
		
		form.build()
		    .getElement('postId').setValue(Std.string(post.id));
		
		if (Auth.getInstance().hasIdentity()) {
			
			var identity:AuthIdentity 
			              = Auth.getInstance().getIdentity();		
			var id:Int    = identity.id;
			var user:User = new User();
			
			user.find(id);
			form.getElement('email').setValue(user.email);
		}

		this.view.assignVar('form', form);
	}
	
	/**
	 * Responds to:
	 * 
	 * POST /comment
	 */
	public function postAction():Void
	{
		var form:CommentForm = new CommentForm();
		var comment:Comment  = new Comment();
		form.build();
		
		if (form.isValid(this.request.getPost())) 
		{
			comment.email   = form.getValue('email');
			comment.content = form.getValue('content');
			comment.postId  = form.getValue('postId');
			
			try {
				comment.save();
				
				this.addFlashMessage('Your comment has been posted.');
				
				// Redirect
				this._redirect(this.request.getBaseUrl() + '/post/' + comment.postId);
				
			} catch (e:Dynamic) {
				// Show errors
			}
		}
		
		if (this._isInlineForm()) {
			// Form was submitted from a post page
			var post:Post = new Post();
			var id:Int    = Std.parseInt(form.getValue('postId'));
			
			post.find(id);
			post.fetchComments();
			
			this.render('post/get', {
				post: post,
				form: form
			}, true);
			
			return;
		}
		
		this.render('comment/new', {form: form}, true);	
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /comment/edit/:id
	 */
	public function editAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Responds to:
	 * 
	 * PUT /comment/:id
	 */
	public function putAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Responds to:
	 * 
	 * DELETE /comment/:id
	 */
	public function deleteAction():Void
	{		
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	private function _isInlineForm():Bool
	{
		return ('true' == this.request.getParam('_inline'));		
	}
	
}