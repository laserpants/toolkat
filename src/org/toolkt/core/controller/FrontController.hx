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
package org.toolkt.core.controller;

import org.toolkt.core.application.Application;
import org.toolkt.core.controller.dispatcher.StandardDispatcher;
import org.toolkt.core.controller.interfaces.IDispatcher;
import org.toolkt.core.controller.interfaces.IRouterHttp;
import org.toolkt.core.controller.plugin.abstract.AbstractPlugin;
import org.toolkt.core.controller.plugin.ErrorHandler;
import org.toolkt.core.controller.plugin.PluginBroker;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.request.RequestHttp;
import org.toolkt.core.controller.response.abstract.AbstractResponse;
import org.toolkt.core.controller.response.ResponseHttp;
import org.toolkt.core.controller.router.RewriteRouter;

class FrontController
{

	/**
	 * Request object
	 */
	public var request:AbstractRequest;
	
	/**
	 * Response object
	 */
	public var response:AbstractResponse;
	
    /**
     * Singleton instance
     */
	private static var _instance:FrontController;
	
    /**
     * Invocation parameters to use when instantiating action controllers.
	 */
	private var _invokeParams:Hash<Dynamic>;
	
    /**
     * Router
	 */
	private var _router:IRouterHttp;
	
	/**
	 * Dispatcher
	 */
	private var _dispatcher:IDispatcher;
	
	/**
	 * Plugin broker instance
	 */
	private var _pluginBroker:PluginBroker;
	
	/**
	 * Whether or not exceptions should be thrown or trapped in the response object
	 */
	private var _throwExceptions:Bool;
	
	public function setThrowExceptions(flag:Bool):Void
	{
		this._throwExceptions = flag;
	}
	
	public function getThrowExceptions():Bool
	{
		return this._throwExceptions;
	}
	
	public function getParam(name:String):Dynamic 
	{
		if (!this._invokeParams.exists(name)) {
			throw new org.toolkt.core.controller.exceptions.NoInvokeParamException(
				"Parameter not set");
		}
		return this._invokeParams.get(name);
	}
	
    /**
     * Add or modify a parameter to use when instantiating an action controller.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setParam(name:String, value:Dynamic):FrontController
	{
		this._invokeParams.set(name, value);
		return this;
	}
	
	/**
	 * Constructor
	 * 
	 * Use FrontController.getInstance(), FrontController is singleton.
	 */
	private function new():Void
	{
		this._invokeParams = new Hash<String>();
		this._pluginBroker = new PluginBroker();
		this._throwExceptions = false;
	}
	
	/**
	 * Get singleton instance
	 */
	public static function getInstance():FrontController
	{
		if (null == FrontController._instance) {
			FrontController._instance = new FrontController();
		}
		return FrontController._instance;
	}
	
    /**
     * Instantiates org.toolkt.core.controller.router.RewriteRouter
	 * object if no router currently set.
	 */
	public function getRouter():IRouterHttp
	{
		if (null == this._router) {
			this._router = new RewriteRouter();
		}
		return this._router;
	}
	
	/**
	 * Instantiates default dispatcher if one is not set.
	 */
	public function getDispatcher():IDispatcher
	{
		if (null == this._dispatcher) {
			this._dispatcher = new StandardDispatcher();
		}
		return this._dispatcher;
	}
	
    /**
     * Register a plugin.
     */
	public function registerPlugin(plugin:AbstractPlugin):Void
	{
		this._pluginBroker.registerPlugin(plugin);
	}
	
	/**
	 * Dispatch HTTP request to a controller/action.
	 */
	public function dispatch(?request:AbstractRequest):Void
	{
		// Register error handler
		
		if (!this._pluginBroker.hasPlugin(ErrorHandler)) 
		{
			var errorHandler:AbstractPlugin = new ErrorHandler();
			this.registerPlugin(errorHandler);
		}
		
        // Instantiate default request object (HTTP version) if none provided

		if (null == request) {
			request = new RequestHttp({
				baseUrl: this._invokeParams.get('baseUrl')
			});
		} 
		this.request = request;

        // Instantiate default response object (HTTP version) if none provided

		var response:AbstractResponse = new ResponseHttp();
		this.response = response;
		
        // Register request and response objects with plugin broker

		this._pluginBroker.setRequest(this.request)
		                  .setResponse(this.response);

        // Initialize router

		var router:IRouterHttp = this.getRouter();
		router.setParams(this._invokeParams);
		
        // Initialize dispatcher

		var dispatcher:IDispatcher = this.getDispatcher();
		dispatcher.setParams(this._invokeParams)
		          .setResponse(this.response);
		
		// Begin dispatch
		
		try {
			
            // Notify plugins of router startup
            this._pluginBroker.routeStartup(this.request);
			
			router.route(this.request);
			
            // Notify plugins of router completion
            this._pluginBroker.routeShutdown(this.request);

			var i:Int = 0;
			do {
				this.request.setDispatched(true);

				// Notify plugins of dispatch startup.
				this._pluginBroker.preDispatch(this.request);
				
				if (!this.request.isDispatched()) 
					continue;

				// Dispatch request
				try {
					dispatcher.dispatch(this.request, this.response);
					
				} catch (e:Dynamic) {
					
					if (true == this._throwExceptions) {
						throw e;
					}
					this.response.setException(e);
				}
				// Notify plugins of dispatch completion
				this._pluginBroker.postDispatch(this.request);
			
			} while (false == this.request.isDispatched() && i++ < 2);
			
		} catch (e:org.toolkt.core.controller.exceptions.DispatchExitException) {
			throw e;
			
		} catch (e:Dynamic) {
			
			if (true == this._throwExceptions) {
				throw e;
			}
			this.response.setException(e);
		}
		this.response.sendResponse();
	}
		
}