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
package org.toolkt.core.controller.request;

import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;

class RequestHttp extends AbstractRequestHttp
{

	/**
	 * Get request param from hash of merged parameters.
	 */
	override public function getParam(key:String):String
	{
		var params:Hash<String> = this.getParams();
		var param:String = params.get(key);
		/*
		if (null == param) {
			return '';
		}
		*/
		return param;
	}
	
	/**
	 * Get merged userland, GET and POST parameters.
	 */
	override public function getParams():Hash<String>
	{
		var params:Hash<String> = comp.Web.getParams();
		for (key in this._params.keys()) {
			var val:String = this._params.get(key);
			params.set(key, val);
		}

		return params;
	}
	
    /**
     * Set the request uri on which the instance operates.
	 * 
	 * @return	Provides a fluent interface
	 */ 
	override public function setRequestUri(?requestUri:String):AbstractRequestHttp
	{
		if (null == requestUri) {
			requestUri = comp.Web.getURI();
			var params:String = comp.Web.getParamsString();
			if ('null' != params) {
				requestUri += '?' + params; 
			}
		}
		this._requestUri = requestUri;
		return this;
	}

    /**
     * Return the method by which the request was made.
	 */
	override public function getMethod():String
	{
		var method:String = comp.Web.getMethod();
		return method;
	}
	
    /**
     * Return hash with all POST parameters.
	 */ 
	override public function getPost():Hash<String>
	{
		if (null == this._postData) {
			var query:String = comp.Web.getPostData();
			this._postData = this._parseQuery(query);
		}
		return this._postData;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super();
		
		if (null != options) {
			this.setBaseUrl(options.baseUrl);
		}
	}
	
	private function _parseQuery(query:String):Hash<String>
	{
		var hash:Hash<String> = new Hash();
		
		if (null == query) {
			return hash;
		}
		
		var parts:Array<String> = query.split('&');
		for (part in parts) {
			var pair:Array<String> = part.split('=');
			hash.set(pair[0], pair[1]);
		}
		return hash;
	}
	
}
