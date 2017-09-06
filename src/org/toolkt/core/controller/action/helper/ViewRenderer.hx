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
package org.toolkt.core.controller.action.helper;

import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.action.abstract.AbstractActionController;
import org.toolkt.core.controller.action.helper.abstract.AbstractHelper;
import org.toolkt.core.controller.interfaces.IActionController;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.view.interfaces.IView;

class ViewRenderer extends AbstractHelper
{

	/**
	 * View instance
	 */
	private var _view:IView;
	
	/**
	 * Prevent auto-rendering at end of controller action call?
	 */
	private var _noRender:Bool;
	
	/**
	 * Disable layout on auto-render?
	 */
	private var _noLayout:Bool;

	/**
	 * Path to script file without file extension
	 */
	private var _script:String;
	
	/**
	 * Prevents auto-rendering at end of controller action call.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function noRender():ViewRenderer
	{
		this._noRender = true;
		return this;
	}
	
	/**
	 * Disable layout on render (two-step view).
	 * 
	 * @return	Provides a fluent interface
	 */
	public function noLayout():ViewRenderer
	{
		this._noLayout = true;
		return this;
	}
	
	/**
	 * Set view instance
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setView(view:IView):ViewRenderer
	{
		this._view = view;
		return this;
	}
	
	/**
	 * @return	View instance
	 */
	public function getView():IView
	{
		return this._view;
	}
	
	/**
	 * Assign script to render
	 */
	public function setScript(script:String):ViewRenderer
	{
		this._script = script;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void 
	{
		super();
		
		this._noRender = false;
		this._noLayout = false;
	}

    /**
     * Hook into action controller workflow.
	 */
    override public function postDispatch():Void
    {
		var controller:AbstractController;
		try {
			controller = cast(this._actionController, AbstractController);
		} catch (e:Dynamic) {
			return;
		}
		
		if (true == this._noRender 
			|| null == this._actionController 
			|| true == controller.response.isRedirect()) {
			return;
		}
		
		var request:AbstractRequest = this.getFrontController().request;
		var moduleName:String       = request.getModule();
		var controllerName:String   = request.getController();
		var actionName:String       = request.getAction();
		
		if (null == this._script) {
		
			var script:String = controllerName + '/' + actionName;
			
			if ('default' != moduleName) {
				script = moduleName + '/' + script;
			}
			this._script = script;
		}
		
		this._actionController.render(this._script, {}, !this._noLayout);
    }	
	
}