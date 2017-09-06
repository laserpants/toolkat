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
package org.toolkt.core.controller.plugin;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.controller.plugin.abstract.AbstractPlugin;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.response.abstract.AbstractResponse;

class PluginBroker extends AbstractPlugin
{

    /**
     * Array of AbstractPlugin instances.
	 */
	private var _plugins:Array<AbstractPlugin>;

    /**
     * Set request object, and register with each plugin.
	 * 
	 * @return	Provides a fluent interface
	 */
	override public function setRequest(request:AbstractRequest):AbstractPlugin
	{
		this._request = request;
		
		for (plugin in this._plugins) {
			plugin.setRequest(request);
		}
		return this;
	}

    /**
     * Set response object, and register with each plugin.
	 * 
	 * @return	Provides a fluent interface
	 */
	override public function setResponse(response:AbstractResponse):AbstractPlugin
	{
		this._response = response;
		
		for (plugin in this._plugins) {
			plugin.setResponse(response);
		}
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		this._plugins = new Array<AbstractPlugin>();
		
		// Call super constructor
		super();
	}

    /**
     * Register a plugin.
     */
	override public function registerPlugin(plugin:AbstractPlugin):Void
	{
		this._plugins.push(plugin);
	}
	
	override public function hasPlugin(plugin:Class<AbstractPlugin>):Bool
	{
		for (current in this._plugins) {
			if (Type.getClass(current) == plugin) {
				return true;
			}
		}
		return false;
	}
	
    /**
     * Called before FrontController begins evaluating the
     * request against its routes.
	 */
	override public function routeStartup(request:AbstractRequest):Void
	{
		for (plugin in this._plugins) {
			try {
				plugin.routeStartup(request);
			} catch (e:Dynamic) {
				this._handleException(e);
			}
		}
	}

    /**
     * Called before FrontController exits its iterations over
     * the route set.
	 */
	override public function routeShutdown(request:AbstractRequest):Void
	{
		for (plugin in this._plugins) {
			try {
				plugin.routeShutdown(request);
			} catch (e:Dynamic) {
				this._handleException(e);
			}
		}
	}

    /**
     * Called before an action is dispatched by AbstractDispatcher instance.
     */
	override public function preDispatch(request:AbstractRequest):Void
	{
		for (plugin in this._plugins) {
			try {
				plugin.preDispatch(request);
			} catch (e:Dynamic) {
				this._handleException(e);
			}
		}
	}

    /**
     * Called after an action is dispatched by AbstractDispatcher instance.
	 */
	override public function postDispatch(request:AbstractRequest):Void
	{
		for (plugin in this._plugins) {
			try {
				plugin.postDispatch(request);
			} catch (e:Dynamic) {
				this._handleException(e);
			}
		}
	}
	
	private function _handleException(e:org.toolkt.core.Exception):Void
	{
		if (Type.getClass(e) == 
			org.toolkt.core.controller.exceptions.DispatchExitException) {
			throw e;	
		}
		
		//throw e;		// ?

		if (FrontController.getInstance().getThrowExceptions()) {
			throw e;
		} else {
			this.getResponse().setException(e);
		}
	}
	
}