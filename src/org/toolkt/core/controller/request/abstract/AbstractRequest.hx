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
package org.toolkt.core.controller.request.abstract;

import org.toolkt.core.controller.interfaces.IRequest;

/* abstract */ class AbstractRequest
	implements IRequest
{

    /**
     * Module key for retrieving module from params.
	 */
	public var moduleKey:String;
	
    /**
     * Controller key for retrieving controller from params.
	 */
	public var controllerKey:String;

    /**
     * Action key for retrieving action from params.
	 */
	public var actionKey:String;
	
	/**
	 * Module name
	 */
	public var module(null, default):String;
	
	/**
	 * Controller name
	 */
	public var controller(null, default):String;
	
	/**
	 * Action name
	 */
	public var action(null, default):String;
	
    /**
     * Has the action been dispatched?
	 */
	private var _dispatched:Bool;
	
    /**
     * Request parameters
	 */
	private var _params:Hash<String>;
	
	/**
	 * Get module name
	 */
	public function getModule():String
	{
		if (null == this.module) {
			this.module = this.getParam(this.moduleKey);
		}
		return this.module;
	}
	
	/**
	 * Get controller name
	 */
	public function getController():String
	{
		if (null == this.controller) {
			this.controller = this.getParam(this.controllerKey);
		}
		return this.controller;
	}
	
	/**
	 * Get action name
	 */
	public function getAction():String
	{
		if (null == this.action) {
			this.action = this.getParam(this.actionKey);
		}
		return this.action;
	}
	
    /**
     * Set an action parameter.
	 * 
	 * @return	Provides a fluent interface
     */
	public function setParam(key:String, value:String):IRequest
	{
		this._params.set(key, value);
		return this;
	}
	
    /**
     * Get an action parameter.
     */
	public function getParam(key:String):String
	{
		var param:String = this._params.get(key);
		/*
		if (null == param) {
			return '';
		}
		*/
		return param;
	}
	
	/* abstract */ public function getParams():Hash<String>
	{
		return throw "Abstract method";
	}
	
    /**
     * Set flag indicating whether or not request has been dispatched.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setDispatched(flag:Bool):AbstractRequest
	{
		this._dispatched = flag;
		return this;
	}
	
    /**
     * Determine if the request has been dispatched
	 */
	public function isDispatched():Bool
	{
		return this._dispatched;
	}
		
	/**
	 * Abstract class, no instantiation
	 */
	private function new(?options:Dynamic):Void
	{
		if (Type.getClass(this) == AbstractRequest) {
			throw "Abstract class, no instantiation";
		}
		
		this.moduleKey     = 'module';
		this.controllerKey = 'controller';
		this.actionKey     = 'action';
		this._dispatched   = false;
		this._params       = new Hash<String>();		
		this.controller    = '';
		this.action        = '';
		this.module        = '';
	}
	
}