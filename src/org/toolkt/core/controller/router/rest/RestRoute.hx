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
package org.toolkt.core.controller.router.rest;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.controller.interfaces.IDispatcher;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;
import org.toolkt.core.controller.router.abstract.AbstractRoute;
import org.toolkt.core.helper.StrTrim;

/**
 * Request-aware route for RoR-style, RESTful modular routing.
 */
class RestRoute extends AbstractRoute
{

	private static inline var URL_DELIMITER = '/';
	
	/**
	 * Front controller instance
	 */
	private var _frontController:FrontController;
	
	/**
	 * Dispatcher
	 */
	private var _dispatcher:IDispatcher;
	
    /**
     * Default values for the route
	 */
	private var _defaults:Hash<String>;

    /**
     * Specific [modules] to receive RESTful routes
     */ 
    private var _restfulModules:Array<String>; 
 
    /**
     * Specific {module => [controllers]} to receive RESTful routes
     */ 
    private var _restfulControllers:Hash<Array<String>>;
	
	private var _moduleKey:String;
	private var _controllerKey:String;
	private var _actionKey:String;
	
    /**
     * Set modules to receive RESTful routes as 
	 *      ['module', 'module', etc]
     */ 
	public function setRestfulModules(modules:Array<String>):Void
	{
		this._restfulModules = modules;
	}
	
    /**
     * Set controllers to receive RESTful routes as 
	 *      {module => ['controller', 'controller'], module => etc}
     */ 
	public function setRestfulControllers(controllers:Hash<Array<String>>):Void
	{
		this._restfulControllers = controllers;
	}

	/**
	 * Constructor
	 */
	public function new(front:FrontController, ?route:String, ?defaults:Dynamic):Void
	{
		// Call super constructor
		super();

		this._frontController    = front;
		this._dispatcher         = front.getDispatcher();
		this._defaults           = new Hash<String>();
		this._restfulModules     = new Array<String>();
		this._restfulControllers = new Hash<Array<String>>();
	}

    /**
     * Matches a user submitted request.
	 */
	override public function match(path:String):Bool
	{
		path = StrTrim.trimChar(path, RestRoute.URL_DELIMITER);

		var request:AbstractRequestHttp = cast(this._frontController.request, AbstractRequestHttp);
		this._setRequestKeys(request);
		
		var values:Hash<String> = new Hash();
		var params:Hash<String> = new Hash();
		
		if ('' != path) {			
			var parts:Array<String> = path.split(RestRoute.URL_DELIMITER);

            // Determine Module 
			var moduleName:String = this._defaults.get(this._moduleKey);
			if (this._dispatcher.isValidModule(parts[0])) {				
				moduleName = parts[0];
				if (true == this._checkRestfulModule(moduleName)) {
					values.set(this._moduleKey, parts.shift());
				}
			}

            // Determine Controller 
			var controllerName:String = this._defaults.get(this._controllerKey);
			if (parts.length > 0 && null != parts[0]) {
				if (true == this._checkRestfulController(moduleName, parts[0])) {
					controllerName = parts[0];
					values.set(this._controllerKey, parts.shift());
					values.set(this._actionKey, 'get');
				} else {
                    // If Controller in URI is not found to be a RESTful 
                    // Controller, return false to fall back to other routes 
					return false;
				}
			}
			
            // Store path count for method mapping
            var pathElementCount:Int = parts.length;

            // Check for leading "special get" URI's 
			var specialGetTarget:String = '';
			if (parts[0] == 'index' || parts[0] == 'new') {
				specialGetTarget = parts.shift();
			} else if (pathElementCount == 1) {
				params.set('id', parts.shift());
			} else if (pathElementCount == 0 || pathElementCount > 1) {
				specialGetTarget = 'index';
			}
			
            // Digest URI params 
			var numSegs:Int = parts.length;
			var i:Int = 0;
			while (i < numSegs) {
				var key:String = StringTools.urlDecode(parts[i]);
				var val:String = parts[i + 1];
				params.set(key, val);
				i++;
			}

			// Check for trailing "special get" URI 
			if (true == params.exists('edit')) {
				specialGetTarget = 'edit';
			}

            // Determine Action 
			var method:String = request.getMethod().toLowerCase();
			if ('get' != method) {
				var restMethod:String = request.getParam('_method');
				var val:String = (null == restMethod) ? method : restMethod.toLowerCase();
				values.set(this._actionKey, val);

                // Map PUT and POST to actual create/update actions
                // based on parameter count (posting to resource or collection)
				
				switch (values.get(this._actionKey)) {
					case 'post':
						var str:String = (pathElementCount > 0) ? 'put' : 'post'; 
						values.set(this._actionKey, str);
					case 'put':
						values.set(this._actionKey, 'put');
					default:
						// ?
				}
			} else if ('' != specialGetTarget) {
				values.set(this._actionKey, specialGetTarget);
			}
		}

		var result:Hash<String> = this._defaults;
		for (key in params.keys()) {
			var value:String = params.get(key);
			result.set(key, value);
		}
		for (key in values.keys()) {
			var value:String = values.get(key);
			result.set(key, value);
		}

		this.setMatchedValues(result);
		return true;
	}
	
    /**
     * Set request keys based on values in request object
	 */
	private function _setRequestKeys(request:AbstractRequest):Void
	{
		this._moduleKey     = request.moduleKey;
		this._controllerKey = request.controllerKey;
		this._actionKey     = request.actionKey;
		
		if (null != this._dispatcher) {
			this._defaults.set(this._moduleKey,     
				this._dispatcher.getDefaultModule());
			this._defaults.set(this._controllerKey, 
				this._dispatcher.getDefaultController());
			this._defaults.set(this._actionKey,     
				this._dispatcher.getDefaultAction());
		}
	}

    /**
     * Determine if a specified module supports RESTful routing
     */
    private function _checkRestfulModule(moduleName:String):Bool
	{
		if (true == this._allRestful()
			|| true == this._fullRestfulModule(moduleName))
			return true;

		for (key in this._restfulControllers.keys()) {
			if (key == moduleName)
				return true;
		}
		return false;
	}

    /**
     * Determine if a specified module + controller combination
     * supports RESTful routing
	 */
    private function _checkRestfulController(moduleName:String, 
	                                         controllerName:String):Bool
    {
		if (true == this._allRestful()
			|| true == this._fullRestfulModule(moduleName))
			return true;
			
		if (true == this._checkRestfulModule(moduleName)) {
			for (val in this._restfulControllers.get(moduleName)) {
				if (val == controllerName)
					return true;
			}
		}
		return false;
	}

    /**
     * Determines if RESTful routing applies to the entire application
	 */
    private function _allRestful():Bool
	{
		return (this._restfulControllers.toString() == '{}' 
		        && this._restfulModules.length == 0);
	}

    /**
     * Determines if RESTful routing applies to an entire module
	 */
    private function _fullRestfulModule(moduleName:String):Bool
	{
		for (val in this._restfulModules) {
			if (val == moduleName)
				return true;
		}
		return false;
	}
	 
}