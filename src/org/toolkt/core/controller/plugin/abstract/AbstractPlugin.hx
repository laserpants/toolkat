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
package org.toolkt.core.controller.plugin.abstract;

import org.toolkt.core.controller.response.abstract.AbstractResponse;
import org.toolkt.core.controller.request.abstract.AbstractRequest;

/* abstract */ class AbstractPlugin
{

	private var _request:AbstractRequest;
	
	private var _response:AbstractResponse;
	
	private var _options:Hash<Dynamic>;
	
    /**
	 * @return Provides a fluent interface
	 */
	public function setRequest(request:AbstractRequest):AbstractPlugin
	{
		this._request = request;
		return this;
	}
	
	public function getRequest():AbstractRequest
	{
		return this._request;
	}

    /**
	 * @return Provides a fluent interface
	 */
	public function setResponse(response:AbstractResponse):AbstractPlugin
	{
		this._response = response;
		return this;
	}
	
	public function getResponse():AbstractResponse
	{
		return this._response;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(?options:Hash<Dynamic>):Void
	{
		if (Type.getClass(this) == AbstractPlugin) {
			throw "Abstract class, no instantiation";
		}
		
		this._options = options;
	}
	
	/* abstract */ public function registerPlugin(plugin:AbstractPlugin):Void
	{
		return throw "Abstract method";
	}

	/* abstract */ public function hasPlugin(plugin:Class<AbstractPlugin>):Bool
	{
		return throw "Abstract method";
	}
	
	public function routeStartup(request:AbstractRequest):Void;

	public function routeShutdown(request:AbstractRequest):Void;

	public function preDispatch(request:AbstractRequest):Void;

	public function postDispatch(request:AbstractRequest):Void;
	
}