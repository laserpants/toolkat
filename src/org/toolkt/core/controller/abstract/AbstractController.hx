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
package org.toolkt.core.controller.abstract;

import org.toolkt.core.controller.action.abstract.AbstractActionController;
import org.toolkt.core.controller.action.helper.abstract.AbstractHelper;
import org.toolkt.core.controller.action.helper.FlashMessenger;
import org.toolkt.core.controller.action.helper.HelperBroker;
import org.toolkt.core.controller.action.helper.ViewRenderer;
import org.toolkt.core.controller.interfaces.IRequestHttp;
import org.toolkt.core.controller.interfaces.IResponseHttp;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;
import org.toolkt.core.controller.response.abstract.AbstractResponse;
import org.toolkt.core.controller.response.abstract.AbstractResponseHttp;
import org.toolkt.core.session.SessionNamespace;
import org.toolkt.core.view.helper.FormFieldErrorHelper;
import org.toolkt.core.view.helper.JsDisplayMessageHelper;
import org.toolkt.node.controller.action.helper.NodeHelper;

/* abstract */ class AbstractController extends AbstractActionController<IRequestHttp, IResponseHttp>
{
	
	public static inline var AUTH_REDIRECT_NS    = '__auth_redirect';
	
	public static inline var CACHE_NO_TRIGGER_NS = '__cache';
	
	/**
	 * AbstractRequestHttp request object
	 */
	public var request(_getRequest, null):IRequestHttp;
	
	/**
	 * ResponseHttp response object
	 */
	public var response(_getResponse, null):IResponseHttp;
	
	/**
	 * FlashMessenger helper instance
	 */
	private var _flashMessenger:FlashMessenger;
	
	/**
	 * ViewRenderer helper instance
	 */
	private var _viewRenderer:ViewRenderer;

	/**
	 * NodeHelper instance
	 */
	private var _nodeHelper:NodeHelper;
	
	/**
	 * Assign FlashMessenger instance.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setFlashMessenger(helper:AbstractHelper):AbstractController
	{
		try {
			this._flashMessenger = cast(helper, FlashMessenger);
		} catch (e:Dynamic) {			
			throw "Provided helper object is not instance of FlashMessenger";
		}
		return this;
	}
	
	/**
	 * Retrieve FlashMessenger instance.
	 */
	public function getFlashMessenger():FlashMessenger
	{		
		if (null == this._flashMessenger) {		
			
			if (HelperBroker.hasHelper('FlashMessenger')) {
				this.setFlashMessenger(HelperBroker.getStaticHelper('FlashMessenger'));
			} else {
				// Register FlashMessenger action helper
				var flashMessenger:FlashMessenger = new FlashMessenger();
				flashMessenger.setActionController(this);
				
				HelperBroker.addHelper('FlashMessenger', flashMessenger);
				this.setFlashMessenger(flashMessenger);
			}
		}		
		return this._flashMessenger;
	}
	
	/**
	 * Adds message to FlashMessenger, and assigns prevent = true to __cache
	 * session namespace to prevent caching of following request.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function addFlashMessage(message:String):AbstractController
	{
		this.getFlashMessenger().addMessage(message);
		
		// Make sure caching is not triggered on following request
		var ns:SessionNamespace = SessionNamespace.get(AbstractController.CACHE_NO_TRIGGER_NS);
		ns.write({
			prevent: true
		});
		
		return this;
	}
	
	/**
	 * Get ViewRenderer helper instance. 
	 * 
	 * @return	ViewRenderer instance, or null if none registered with the HelperBroker
	 */
	public function getViewRenderer():ViewRenderer
	{
		if (null == this._viewRenderer && HelperBroker.hasHelper('ViewRenderer')) {
			this._viewRenderer = 
				cast(this._helperBroker.getHelper('ViewRenderer'), ViewRenderer);
		}
		return this._viewRenderer;
	}
	
	/**
	 * Assign NodeHelper instance.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setNodeHelper(helper:AbstractHelper):AbstractController
	{
		try {
			this._nodeHelper = cast(helper, NodeHelper);
		} catch (e:Dynamic) {			
			throw "Provided helper object is not instance of NodeHelper";
		}
		return this;
	}
	
	/**
	 * Retrieve NodeHelper instance.
	 */
	public function getNodeHelper():NodeHelper
	{
		if (null == this._nodeHelper) {			

			if (HelperBroker.hasHelper('NodeHelper')) {
				this.setNodeHelper(HelperBroker.getStaticHelper('NodeHelper'));
			} else {
				// Register NodeHelper action helper		
				var nodeHelper:NodeHelper = new NodeHelper();
				nodeHelper.setActionController(this);
				
				HelperBroker.addHelper('NodeHelper', nodeHelper);
				this.setNodeHelper(nodeHelper);
			}
		}		
		return this._nodeHelper;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(request:IRequestHttp, response:IResponseHttp, 
						 invokeParams:Hash<Dynamic>):Void
	{
		if (Type.getClass(this) == AbstractController) {
			throw "Abstract class, no instantiation";
		}		
		super(request, response, invokeParams);
	}
	
	/**
	 * Prevents ViewRenderer helper from automatic rendering
	 * of view script on postDispatch of controller action.
	 */
	public function noAutoRender():Void
	{
		if (!HelperBroker.hasHelper('ViewRenderer')) {
			return;
		}		
		this.getViewRenderer().noRender();
	}
	
	/**
	 * Instructs ViewRenderer helper to not use layout 
	 * script when rendering view.
	 */
	public function noLayout():Void
	{
		if (!HelperBroker.hasHelper('ViewRenderer')) {
			return;
		}
		this.getViewRenderer().noLayout();
	}
			
    /**
     * Called before action method execution.
	 */ 
	override public function preDispatch():Void
	{
		// Assign baseUrl to template variables
		this.view.assignVar('baseUrl',
			this.request.getBaseUrl());

		// Assign FlashMessenger
		this.view.assignVar('flash', 
			this.getFlashMessenger());

		// Flag indicating whether user is authenticated or not
		this.view.assignVar('hasIdentity', 
			org.toolkt.core.auth.Auth.getInstance().hasIdentity());

		// Add view helpers to render AJAX related JavaScripts, output form errors etc.
		var jsHelper:JsDisplayMessageHelper = new JsDisplayMessageHelper();
		jsHelper.setFlashMessenger(this.getFlashMessenger());
		
		var errHelper:FormFieldErrorHelper = new FormFieldErrorHelper();

		this.view.getHelperBroker().addHelper('JsDisplayMessageHelper', jsHelper)
								   .addHelper('FormFieldErrorHelper', errHelper);		
	}
	
	override public function init():Void
	{
		// Delete auth_redirect namespace
		SessionNamespace.unset(AbstractController.AUTH_REDIRECT_NS);
	}
	
	override public function render(script:String, 
									?vars:Dynamic, 
									?useLayout:Bool = false):Void
	{
		// Prevent auto-rendering if render is manually called from action
		if (HelperBroker.hasHelper('ViewRenderer')) {
			this.getViewRenderer().noRender();
		}
		
		super.render(script, vars, useLayout);
	}
	
    /**
     * Is the request a Javascript XMLHttpRequest?
	 */
	public function isAjaxRequest():Bool
	{
		return this.request.isAjaxRequest();
	}

	/*
	private function _getRequest():AbstractRequestHttp
	{
		if (null == this.request) {
			this.request = cast(this.getRequest(), AbstractRequestHttp);
		}
		return this.request;
	}

	private function _getResponse():AbstractResponseHttp
	{
		if (null == this.response) {
			this.response = cast(this.getResponse(), AbstractResponseHttp);
		}
		return this.response;
	}
	*/
	
	/**
	 * Internal getter for the 'request' property.
	 */
	private function _getRequest():IRequestHttp
	{
		if (null == this.request) {
			this.request = this.getRequest();
		}
		return this.request;
	}

	/**
	 * Internal getter for the 'response' property.
	 */
	private function _getResponse():IResponseHttp
	{
		if (null == this.response) {
			this.response = this.getResponse();
		}
		return this.response;
	}
	
	/**
	 * Attempt redirect back (after successful authentication).
	 * 
	 * First looks for saved url in AUTH_REDIRECT_NS session namespace
	 * from request that initiated previous redirect. As second option
	 * uses url parameter, if one provided.
	 */
	private function _redirectToPreviousOr(?url:String):Void
	{
		if (SessionNamespace.exists(AbstractController.AUTH_REDIRECT_NS)) 
		{
			var ns:SessionNamespace = 
				SessionNamespace.get(AbstractController.AUTH_REDIRECT_NS);
			
			if (!ns.storageIsEmpty()) {
				this._redirect(ns.read().url);
			}
		}
		
		if (null != url) {
			this._redirect(url);
		}
	}
	
	/**
	 * Saves request uri in session to enable redirect after successful authentication.
	 * 
	 * @return	Provides a fluent interface
	 */
	private function _setAuthRedirectPath():AbstractController
	{
		var ns:SessionNamespace = SessionNamespace.get(AbstractController.AUTH_REDIRECT_NS);
		ns.write({
			url: request.getBaseUrl() + request.getPathInfo()
		});
		return this;
	}

	private function _redirect(url:String):Void
	{
		if ('' == url)
			url = '/';
			
		this.response.setRedirect(url);
		throw new org.toolkt.core.controller.exceptions.ActionRedirectException();
	}
	
}