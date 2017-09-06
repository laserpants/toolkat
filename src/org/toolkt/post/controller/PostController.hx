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
import org.toolkt.post.form.PostForm;
import org.toolkt.post.Post;
import org.toolkt.user.User;

class PostController extends AbstractController,
	implements IRestController
{

	/**
	 * Responds to:
	 * 
	 * GET /post
	 */
	public function indexAction():Void
	{
		var paginator:Paginator<Post> = Post.paginateAll();
		var page:Int = Std.parseInt(this.getRequest().getParam('page'));
		
		paginator.setCurrentPage(page)
		         .setItemCountPerPage(10);
		
		var posts:Array<Post> = paginator.fetchItems();
		
		// Eager-load specific number of comments per post
		Comment.fetchForPosts(posts, 4);

		this.view.assign({
			posts:    posts,
			pages:    paginator.getPages(this.request.getBaseUrl() + '/post')
		});
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /post/:id
	 */
	public function getAction():Void
	{
		var post:Post = new Post();
		var id:Int = Std.parseInt(this.request.getParam('id'));
		
		try {
			post.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('Post not found');
		}
		post.fetchComments();
		
		// Create comment form
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

		this.render('post/get', {
			post: post,
			form: form
		}, true);
	}

	/**
	 * Responds to:
	 * 
	 * GET /post/new
	 */
	public function newAction():Void
	{
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			// Create session namespace to enable redirect back, on successful login
			this._setAuthRedirectPath()
			    ._redirect(request.getBaseUrl() + '/login');
		}
		
		var form:PostForm = new PostForm();
		form.build();

		this.view.assignVar('form', form);
	}
	
	/**
	 * Responds to:
	 * 
	 * POST /post
	 */
	public function postAction():Void
	{
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			this._redirect(request.getBaseUrl() + '/login');
		}
		
		var identity:AuthIdentity = Auth.getInstance().getIdentity();		
		var userId:Int = identity.id;
		
		var form:PostForm = new PostForm();
		var post:Post = new Post();
		form.build();
		
		if (form.isValid(this.request.getPost())) 
		{			
			post.title      = form.getValue('title');
			post.content    = form.getValue('content');
			post.userId     = userId;
			
			try {
				post.save();
				
				this.addFlashMessage('Your post has been saved.');
				
				// Redirect
				this._redirect(this.request.getBaseUrl() + '/post/' + post.id);
				
			} catch (e:Dynamic) {
				// Show errors
			}
		}
		this.render('post/new', {form: form}, true);		
	}
	
	/**
	 * Responds to:
	 * 
	 * GET /post/edit/:id
	 */
	public function editAction():Void
	{
		var post:Post = this._buildPost(Std.parseInt(
			this.request.getParam('edit')));
		
		var form:PostForm = new PostForm();
		form.build(post);
		
		form.populate(new org.toolkt.core.helper.QuickHash({
			title:   post.title,
			content: post.content
		}));
		
		this.view.assignVar('form', form);
	}
	
	/**
	 * Responds to:
	 * 
	 * PUT /post/:id
	 */
	public function putAction():Void
	{
		var post:Post = this._buildPost(Std.parseInt(
			this.request.getParam('id')));
		
		var form:PostForm = new PostForm();
		form.build(post);
				
		if (form.isValid(this.request.getPost())) 
		{	
			post.title      = form.getValue('title');
			post.content    = form.getValue('content');
			
			try {
				post.save();
				this.addFlashMessage('Post has been updated.');
				
				// Redirect
				this._redirect(this.request.getBaseUrl() + '/post/' + post.id);
				
			} catch (e:Dynamic) {
				// Show errors
			}
		}
		this.render('post/edit', {
			form: form
		}, true);
	}
	
	/**
	 * Responds to:
	 * 
	 * DELETE /post/:id
	 */
	public function deleteAction():Void
	{		
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			// Create session namespace to enable redirect back, on successful login
			this._setAuthRedirectPath()
			    ._redirect(request.getBaseUrl() + '/login');
		}
		var identity:AuthIdentity = Auth.getInstance().getIdentity();		
		var userId:Int = identity.id;

		var id:Int = Std.parseInt(this.request.getParam('id'));
		
		if (userId != id) {
			throw new org.toolkt.core.auth.exceptions.NotAuthorizedException('Not authorized');
		}
		
		var post:Post = new Post();
		try {
			post.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('Post not found');
		}
		
		try {
			post.delete();
			this.addFlashMessage('Post has been deleted.');
			
		} catch (e:Dynamic) {
			// ...
		}
		
		// Redirect
		this._redirect(this.request.getBaseUrl() + '/post');
	}
	
	private function _buildPost(id:Int):Post
	{
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			this._setAuthRedirectPath()
			    ._redirect(request.getBaseUrl() + '/login');
		}
		var identity:AuthIdentity = Auth.getInstance().getIdentity();		
		var userId:Int = identity.id;
		
		//
		
		var form:PostForm = new PostForm();
		var post:Post = new Post();
		
		try {
			post.find(id);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.IdentityNotFoundException('Post not found');
		}
		
		if (userId != post.userId) {
			throw new org.toolkt.core.auth.exceptions.NotAuthorizedException('Not authorized');
		}
		
		return post;
	}
	
}