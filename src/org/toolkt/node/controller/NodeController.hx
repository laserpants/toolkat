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
package org.toolkt.node.controller;

import org.toolkt.core.auth.Auth;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.interfaces.IRestController;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.node.form.BlockWrapperForm;
import org.toolkt.node.Node;
import org.toolkt.node.NodeBlock;
import org.toolkt.node.Nodetree;

class NodeController extends AbstractController,
	implements IRestController 
{
	
	override public function init():Void
	{
		super.init();
		
		// Translate nodeUri to format expected by NodeHelper
		this.getNodeHelper().transformNodeUri(this.request);
	}
	
	/**
	 * Index action, responds to:
	 * 
	 * GET /node
	 */
	public function indexAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Get action, responds to:
	 * 
	 * GET /node/:id
	 */
	public function getAction():Void
	{
		// AJAX request? Disguise as POST and forward to putAction
		if (this.isAjaxRequest()) {
			
			this.request.setPostData(new org.toolkt.core.helper.QuickHash<String>({
				uri:     this.request.getParam('uri'),
				key:     this.request.getParam('key'),
				content: this.request.getParam('content'),
				_method: this.request.getParam('_method')
			}));
			
			this.putAction();
			return;
		}
		
		this.getNodeHelper().fetchNode(this.request.getParam('id'), this);
		
		this.view.assign({
			loggedIn: Auth.getInstance().hasIdentity(),
			nodeUri:  this.request.getParam('id')
		});
	}

	/**
	 * Post action, responds to:
	 * 
	 * POST /node
	 */
	public function postAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	/**
	 * Edit action, responds to:
	 * 
	 * GET /node/edit/:id
	 */
	public function editAction():Void
	{
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			// Create session namespace to enable redirect back, on successful login
			this._setAuthRedirectPath()
			    ._redirect(request.getBaseUrl() + '/login');
		}
		
		var uri:String = this.request.getParam('edit');
		
		var form:BlockWrapperForm = new BlockWrapperForm();
		form.setNodeUri(uri);
		
		this.getNodeHelper().setRenderWrappers(true)
		                    .setBlockWrapper('admin/block/wrapper')
							.setWrapperForm(form)
							.fetchNode(uri, this);
	}
	
	/**
	 * Put action, responds to:
	 * 
	 * PUT /node/:id
	 */
	public function putAction():Void
	{		
		// If not logged in, redirect to login form
		if (!Auth.getInstance().hasIdentity()) {
			
			// Create session namespace to enable redirect back, on successful login
			this._setAuthRedirectPath()
			    ._redirect(request.getBaseUrl() + '/login');
		}
		
		var uri:String = this.request.getParam('id');
		
		var form:BlockWrapperForm = new BlockWrapperForm();
		form.setNodeUri(uri);
		
		if (form.isValid(this.request.getPost())) {
			
			var contentKey:String   = form.getValue('key');			
			var blockUri:String     = form.getValue('uri');
			var nodeBlock:NodeBlock = new NodeBlock(uri, blockUri);
			
			nodeBlock.load()
			         .assign(contentKey, form.getValue('content'))
			         .save();

			this.addFlashMessage('Block content has been updated.');
			
			// Update cache after update
			var cacheId:String = 'block_' + haxe.Md5.encode(blockUri);
			
			try {
				Nodetree.getCache().save(nodeBlock.content, cacheId);
			} catch (e:Dynamic) {
				// Error saving to cache
			}
		}
		
		if (this.isAjaxRequest()) {
			
			this.view.assign({
				block: form.getValue('content'),
				form:  form,
				uri:   form.getValue('uri'),
				key:   form.getValue('key')
			});
			this.render('admin/block/wrapper');
			
		} else {
			
			this.getNodeHelper().setRenderWrappers(true)
								.setBlockWrapper('admin/block/wrapper')
								.setWrapperForm(form)
								.fetchNode(uri, this);
		}		
	}
	
	/**
	 * Delete action, responds to:
	 * 
	 * DELETE /node/:id
	 * 
	 * @todo
	 */
	public function deleteAction():Void
	{
	}
	
}