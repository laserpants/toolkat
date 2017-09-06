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
package org.toolkt.core.controller.action.abstract;

import org.toolkt.core.controller.interfaces.IRequest;
import org.toolkt.core.controller.interfaces.IResponse;
import org.toolkt.core.controller.action.helper.HelperBroker;
import org.toolkt.core.controller.action.helper.ViewRenderer;
import org.toolkt.core.controller.interfaces.IActionController;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.response.abstract.AbstractResponse;
import org.toolkt.core.view.abstract.AbstractView;
import org.toolkt.core.view.interfaces.IView;

/* abstract */ class AbstractActionController<Q:IRequest, R:IResponse> implements IActionController<Q, R>
{

    /**
     * View object
	 */
	public var view:IView;
	
    /**
     * Request object wrapping the request environment.
	 */
	private var _request:Q;
	
	/**
	 * Response object wrapping the response.
	 */
	private var _response:R;

	/**
     * Invocation parameters
	 */
	private var _invokeParams:Hash<Dynamic>;
	
	/**
     * HelperBroker to assist in routing help requests to the proper object.
	 */
	private var _helperBroker:HelperBroker;
	
	/**
	 * Get request object
	 */
	public function getRequest():Q
	{
		return this._request;
	}
	
	/**
	 * Get response object
	 */
	public function getResponse():R
	{
		return this._response;
	}
	
	/**
	 * Get invocation parameters
	 */
	public function getParams():Hash<Dynamic>
	{
		return this._invokeParams;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(request:Q, response:R, 
						 invokeParams:Hash<Dynamic>):Void
	{
		if (Type.getClass(this) == AbstractActionController) {
			throw "Abstract class, no instantiation";
		}

		this._request      = request;
		this._response     = response;
		this._invokeParams = invokeParams;
		
		this._helperBroker = new HelperBroker(this);
		this.init();
	}
	
	/* abstract */ public function init():Void
	{
		return throw "Abstract method";
	}
	
    /**
     * Initialize view object and assign to this.view.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function initView():IView
	{
		if (null == this.view && HelperBroker.hasHelper('ViewRenderer')) {
			var viewRenderer_:org.toolkt.core.controller.action.helper.abstract.AbstractHelper
				= this._helperBroker.getHelper('ViewRenderer');
				
			var viewRenderer:ViewRenderer;
			try {
				viewRenderer = cast(viewRenderer_, ViewRenderer);
			} catch (e:Dynamic) {
				throw new org.toolkt.core.Exception('Invalid ViewRenderer instance');
			}					
			this.view = viewRenderer.getView();
		}
		
		if (null == this.view) {
			var path:String = this._invokeParams.get('appPath');
			var viewEngine:TemplEngine = this._invokeParams.get('templEn');
			this.view = AbstractView.factory(viewEngine, path);
			
			var layout:String = this._invokeParams.get('layout');
			if (null != layout) {
				this.view.setLayout(layout);
			}
		}
		
		return this.view;
	}
	
    /**
     * Render a view.
	 */
	public function render(script:String, ?vars:Dynamic, ?useLayout:Bool = false):Void
	{
		var out:String = this._render(script, vars, useLayout);
		this.getResponse().appendBody(out);
	}
	
	/**
	 * Same as render, but instead returns output as a string.
	 */
	public function renderToStr(script:String, ?vars:Dynamic, ?useLayout:Bool = false):String
	{
		return this._render(script, vars, useLayout);
	}
	 
    /**
     * Dispatch the requested action.
	 */
	public function dispatch(action:String):Void
	{
		// Notify helpers of action preDispatch state
		this._helperBroker.notifyPreDispatch();
		
		this.preDispatch();

		if (this._request.isDispatched()) {
			
			var field:Dynamic = Reflect.field(this, action);
			
			if (null == field) {
				throw new org.toolkt.core.controller.exceptions.InvalidActionException();
			}
						
			try {
				Reflect.callMethod(this, field, []);
			} catch (e:org.toolkt.core.controller.exceptions.ActionRedirectException) {
				// Exception thrown to prevent further script execution 
				// when a redirect is initiated.
			}
			this.postDispatch();
		}
		
		this._helperBroker.notifyPostDispatch();
	}
	
    /**
     * Called before action method execution.
	 */ 
	public function preDispatch():Void;
	
    /**
     * Called after action method execution.
	 */ 
	public function postDispatch():Void;
	
	private function _render(script:String, ?vars:Dynamic, ?useLayout:Bool = false):String
	{
		this.initView();
		
		if (null != vars) {
			this.view.assign(vars);
		}
		var out:String = this.view.render(script);

		if (true == useLayout && this.view.hasLayout()) {
//			this.view.clearVars()
//				.assign({content: out});
			
			// Render template file
			this.view.assign({content: out});
			out = this.view.render(this.view.getLayout());
		}
		
		return out;
	}
	
}