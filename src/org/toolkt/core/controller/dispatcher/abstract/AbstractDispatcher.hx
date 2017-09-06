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
package org.toolkt.core.controller.dispatcher.abstract;

import org.toolkt.core.controller.interfaces.IDispatcher;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.response.abstract.AbstractResponse;

/* abstract */ class AbstractDispatcher 
	implements IDispatcher
{

    /**
     * Default module
	 */
	private var _defaultModule:String;
	
    /**
     * Default controller
	 */
	private var _defaultController:String;
	
    /**
     * Default action
	 */
	private var _defaultAction:String;
	
    /**
     * Response object to pass to action controllers, if any.
	 */
	private var _response:AbstractResponse;

    /**
     * Invocation parameters to use when instantiating action controllers.
	 */
	private var _invokeParams:Hash<Dynamic>;

    /**
     * Set params to pass to the Action Controller constructor.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setParams(params:Hash<Dynamic>):IDispatcher
	{
		this._invokeParams = params;
		return this;
	}	
	
    /**
     * Set response object to pass to action controllers.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setResponse(?response:AbstractResponse):IDispatcher
	{
		this._response = response;
		return this;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractDispatcher) {
			throw "Abstract class, no instantiation";
		}
		
		this._defaultModule     = 'default';
		this._defaultController = 'index';
		this._defaultAction     = 'index';
	}

	/* abstract */ public function isDispatchable(request:AbstractRequest):Bool
	{
		return throw "Abstract method";
	}
	
	/* abstract */ public function dispatch(request:AbstractRequest, response:AbstractResponse):Void
	{
		return throw "Abstract method";
	}

    /* abstract */ public function isValidModule(module:String):Bool
	{
		return throw "Abstract method";
	}
	
	public function getDefaultModule():String
	{
		return this._defaultModule;
	}
	
	public function getDefaultController():String
	{
		return this._defaultController;
	}
	
	public function getDefaultAction():String
	{
		return this._defaultAction;
	}
	
	/**
	 * Generates CamelCased controller name, e.g., 'index' => 'IndexController'.
	 */
	private function _formatControllerName(name:String):String
	{
		name = name.charAt(0).toUpperCase()
			+ name.substr(1)
			+ 'Controller';
			
		return name;
	}
	
	/**
	 * Generates mixedCased action name, e.g., 'index' => 'indexAction'.
	 */
	private function _formatActionName(name:String):String
	{
		return name + 'Action';
	}

}