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
package org.toolkt.core.controller.router;

import org.toolkt.core.controller.exceptions.RouterException;
import org.toolkt.core.controller.interfaces.IRoute;
import org.toolkt.core.controller.interfaces.IRouter;
import org.toolkt.core.controller.interfaces.IRouterHttp;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;
import org.toolkt.core.controller.router.abstract.AbstractRouter;

class RewriteRouter extends AbstractRouter,
	implements IRouterHttp
{
	
    /**
     * Hash of routes to match against.
     */
	private var _routes:Hash<IRoute>;
	
	/**
	 * Array of route names, with first added first. 
	 */
	private var _routeIndex:Array<String>;
	
    /**
     * Currently matched route.
	 */ 
	private var _currentRoute:String;

    /**
     * Invocation parameters to use when instantiating action controllers.
	 */
	private var _invokeParams:Hash<Dynamic>;

    /**
     * Set parameters to pass to helper object constructors.
	 * 
	 * @return	Provides a fluent interface
	 */
	override public function setParams(params:Hash<Dynamic>):IRouter
	{
		this._invokeParams = params;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
		
		this._routes = new Hash<IRoute>();
		this._routeIndex = [];
	}
	
    /**
     * Add route to the route chain.
     */ 
	public function addRoute(name:String, route:IRoute):Void
	{
		this._routes.set(name, route);
		this._routeIndex.push(name);
	}
	
    /**
     * Find a matching route to the current PATH_INFO and inject
     * returning values to the request object.
     */
	override public function route(request_:AbstractRequest):AbstractRequest
	{
		var request:AbstractRequestHttp;
		try {
			request = cast(request_, AbstractRequestHttp);
		} catch (e:Dynamic) {
			throw new RouterException('RewriteRouter expects instance of AbstractRequestHttp.');
		}
			
		var routes:Hash<IRoute> = this._routes;
	
		for (routeName in this._routeIndex) {
			
			var route:IRoute = routes.get(routeName);
			var match:String = request.getPathInfo();
			
			if (true == route.match(match)) {
				var values:Hash<String> = route.getMatchedValues();
				this._setRequestParams(request, values)
				    ._setCurrentRoute(routeName);
					
				break;
			}
		}
		return request;
	}
	
	private function _setRequestParams(request:AbstractRequestHttp, 
	                                   params:Hash<String>):RewriteRouter
	{
		for (paramKey in params.keys()) {
			var value:String = params.get(paramKey);
			request.setParam(paramKey, value);
			
			if (paramKey == request.moduleKey) {
				request.module = value;
			}
			if (paramKey == request.controllerKey) {
				request.controller = value;
			}
			if (paramKey == request.actionKey) {
				request.action = value;
			}
		}
		return this;
	}
	
	private function _setCurrentRoute(name:String):RewriteRouter
	{
		this._currentRoute = name;
		return this;
	}
	
}