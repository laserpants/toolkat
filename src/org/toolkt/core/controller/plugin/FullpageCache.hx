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

import org.toolkt.core.cache.abstract.AbstractCache;
import org.toolkt.core.cache.front.abstract.AbstractCacheFront;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.plugin.abstract.AbstractPlugin;
import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;
import org.toolkt.core.session.SessionNamespace;

class FullpageCache extends AbstractPlugin
{

	/**
	 * Cache current page request?
	 */
	private static var _active:Bool = false;
	
	/**
	 * AbstractCacheFront instance
	 */
	private static var _frontHandler:AbstractCacheFront;
	
	/**
	 * Cache identifier
	 */
	private var _cacheKey:String;
	
	/**
	 * Hash of actions to cache in the format: 
	 * 
	 * 		{ controller => ['action', 'action', 'action'] }
	 */
	private var _cacheActions:Hash<Array<String>>;
	
	/**
	 * Static method to assign front handler.
	 */
	public static function setFrontHandler(front:AbstractCacheFront):Void
	{
		FullpageCache._frontHandler = front;
	}
	
	/**
	 * Lazy-loads default cache front handler.
	 */
	public static function getFrontHandler():AbstractCacheFront
	{
		if (null == FullpageCache._frontHandler) {
			FullpageCache._frontHandler = AbstractCache.factory(Page, {prefix: 'fullpage'}, {});
		}
		return FullpageCache._frontHandler;
	}
	
	/**
	 * Clear all cached data. Return true if successful.
	 */
	public static function clearData():Bool
	{
		var frontHandler:AbstractCacheFront = FullpageCache.getFrontHandler();
		
		if (null == frontHandler) {
			// No (default) front handler defined
			return false;
		}
		
		try {
			frontHandler.clear();
			return true;
		} catch (e:Dynamic) {
			// Error; return false
		}
		return false;
	}

	/**
	 * Constructor
	 */
	public function new(?options:Hash<Dynamic>):Void
	{
		super(options);
		
		this._cacheActions = new Hash();
		
		if (null == options) {
			return;
		}
		
		var actions:Hash<Array<String>> = options.get('actions');
		
		if (null != actions) {
			this._cacheActions = actions;
		}
	}
	
    /**
     * Start caching
     *
     * Determine if we have a cache hit. If so, send the response; 
	 * else, start caching.
	 */
	override public function preDispatch(r:AbstractRequest):Void
	{
		var request:AbstractRequestHttp;
		
		try {
			request = cast(r, AbstractRequestHttp);
		} catch (e:Dynamic) {
			throw new org.toolkt.core.Exception('Request must be http request object');
		}

		var module:String     = request.getModule();
		var controller:String = request.getController();
		var action:String     = request.getAction();

		// Only cache GET, and non-authenticated requests
		if ('get' != request.getMethod().toLowerCase()
			|| org.toolkt.core.auth.Auth.getInstance().hasIdentity()) {
			return;
		}
		
		// Determine if controller/action should be cached
		
		var actions:Array<String> = this._cacheActions.get(controller);
		if (null != actions) {
			// controller exists in hash
			
			var flag:Bool = false;
			if (0 == actions.length) {
				// Empty array, cache all actions
				flag = true;
			} else {
				// Check if action exists in array
				for (i in actions) {
					if (i == action) {
						flag = true;
						break;
					}
				}
			}
			
			FullpageCache._active = flag;
		}
		
		if (SessionNamespace.exists(AbstractController.CACHE_NO_TRIGGER_NS)) {
			
			var ns:SessionNamespace = SessionNamespace.get(AbstractController.CACHE_NO_TRIGGER_NS);
			if (!ns.storageIsEmpty()) {
				
				if (ns.read().prevent == true) {
					ns.clear();
					FullpageCache._active = false;
				}
			}
		}

		if (!FullpageCache._active) {
			return;
		}
		
		var uri:String = request.getRequestUri();
		
//		if (org.toolkt.core.auth.Auth.getInstance().hasIdentity()) {
//			uri = uri + '_auth';
//		}
		
		this._cacheKey = haxe.Md5.encode(uri);
		
		if (this._getCache()) {
			
			this._response.appendBody('<!-- ! -->')
			              .sendResponse();			
			// Tell FrontController to shutdown and exit
			throw new org.toolkt.core.controller.exceptions.DispatchExitException();
		}
	}
	
    /**
     * Store cache
	 */
	override public function postDispatch(request:AbstractRequest):Void
	{
		if ((false == FullpageCache._active)
		    || (null == this._cacheKey)
		    || this.getResponse().isRedirect() 
			|| this.getResponse().isException()) {
			return;	
		}
		
		FullpageCache.getFrontHandler().save(this.getResponse(), this._cacheKey);
	}
	
	/**
	 * Find out if cached data exists for given caheKey
	 * and if so, set response object and return true.
	 */
	private function _getCache():Bool
	{
		if (FullpageCache.getFrontHandler().exists(this._cacheKey)) {
			try {
				// Get cached response object
				this._response = FullpageCache.getFrontHandler().load(this._cacheKey);
				return true;
				
			} catch (e:Dynamic) {
				// In case of an error, return false. We don't want an exception
				// to be thrown, instead just proceed using non-cached response.
			}
		}
		return false;
	}
	
}