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
package org.toolkt.core.controller.dispatcher;

import org.toolkt.core.controller.action.abstract.AbstractActionController;
import org.toolkt.core.controller.dispatcher.abstract.AbstractDispatcher;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.response.abstract.AbstractResponse;

/**
 * @todo	is valid module
 */
class StandardDispatcher extends AbstractDispatcher
{
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
		
    /**
     * Get controller class name.
	 */
	public function getControllerClass(request:AbstractRequest):String
	{
		var name:String = request.getController();
		
		if (null == name) {
			//name = this.getDefaultController();
			//request.controller = name;
			throw new org.toolkt.core.controller.exceptions.InvalidControllerException();
		}
		return this._formatControllerName(name);
	}
	
    /**
     * Determine the action name.
     */
	public function getActionMethod(request:AbstractRequest):String
	{
		var action:String = request.getAction();

		if (null == action) {
			action = this.getDefaultAction();
			request.action = action;
 		}
		action = this._formatActionName(action);
		return action;
	}
	
    /**
     * Dispatch to a controller/action.
	 */ 
	override public function dispatch(request:AbstractRequest, response:AbstractResponse):Void
	{
		this.setResponse(response);
		
		if (!this._isDispatchable(request)) {
			throw new org.toolkt.core.controller.exceptions.InvalidControllerException();
		}
		
		var className:String = this.getControllerClass(request);
		var controller:AbstractActionController<Dynamic, Dynamic> = null;
		
		try {			
			var controllerClass:Dynamic = Type.resolveClass('controllers.' + className);
			controller = Type.createInstance(controllerClass, 
				[request, response, this._invokeParams]);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.controller.exceptions.InvalidControllerException();
		}
		
        // Retrieve the action name
		var actionMethod:String = this.getActionMethod(request);
		
		// Dispatch the method call
        request.setDispatched(true);
		
		controller.initView();
		controller.dispatch(actionMethod);
		
		// Destroy reflection objects
		controller = null;
	}
	
    /**
     * Whether or not a given module is valid.
	 * 
	 * @todo
     */
    override public function isValidModule(module:String):Bool
	{
		if ('default' == module) {
			return true;
		} 
			
		// @todo

		return false;
	}
	
	private function _isDispatchable(request:AbstractRequest):Bool
	{
		var controller:String = request.getController();
		
		if ('' == controller || null == controller) {
			return false;
		}		
		return true;
	}
	
}