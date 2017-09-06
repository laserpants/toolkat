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
import org.toolkt.core.controller.interfaces.IRequestHttp;

/* abstract */ class AbstractRequestHttp extends AbstractRequest,
	implements IRequestHttp
{
	
    /**
     * Request uri
	 */
	private var _requestUri:String;
	
    /**
     * Base url of request
	 */
	private var _baseUrl:String;
	
    /**
     * Path info
	 */
	private var _pathInfo:String;
	
	/**
	 * Hash with all POST parameters
	 */
	private var _postData:Hash<String>;
	
	/* abstract */ public function setRequestUri(?requestUri:String):AbstractRequestHttp
	{
		return throw "Abstract method";
	}
	
    /**
     * @return	Request uri
	 */ 
	public function getRequestUri():String
	{
		if (null == this._requestUri) {
			this.setRequestUri();
		}
		return this._requestUri;
	}
	
    /**
     * Set the base url of the request; 
	 * i.e., the segment leading to the script name.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setBaseUrl(baseUrl:String):AbstractRequestHttp
	{
		var requestUri:String = this.getRequestUri();
		
		// Directory part of baseUrl
		var i:Int = baseUrl.lastIndexOf('/');
		var dirname:String = ( -1 == i) ? '' : baseUrl.substr(0, i);
		
		if (0 != requestUri.indexOf(baseUrl) && 0 == requestUri.indexOf(dirname)) {
			baseUrl = dirname;
		} else if (0 != requestUri.indexOf(baseUrl)) {
			baseUrl = '';
		}
		
		baseUrl = org.toolkt.core.helper.StrTrim.rtrimChar(baseUrl, '/');
		
		this._baseUrl = baseUrl;
		return this;
	}
	
    /**
     * Everything in request uri before path info.
	 * 
	 * @return	Base url
	 */
	public function getBaseUrl():String
	{
		return this._baseUrl;
	}
	
    /**
	 * Set path info.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setPathInfo(?pathInfo:String):AbstractRequestHttp
	{
		if (null == pathInfo) {

			var requestUri:String = this.getRequestUri();
			var baseUrl:String    = this.getBaseUrl();
			
			if (null == requestUri) {
				return this;
			}
			
			var pos:Int = requestUri.indexOf('?');
			if ( -1 != pos) {
				// Remove the query string from request uri
				requestUri = requestUri.substr(0, pos);
			}

			pathInfo = requestUri.substr(baseUrl.length);
			if (null == baseUrl && '' != pathInfo) {
				pathInfo = requestUri;
			}
		} 
		this._pathInfo = pathInfo;
		return this;
	}
	
	/**
	 * @return	Path info
	 */
	public function getPathInfo():String
	{
		if (null == this._pathInfo) {
			this.setPathInfo();
		}
		return this._pathInfo;
	}

	/* abstract */ public function getMethod():String
	{
		return throw "Abstract method";
	}

	/**
	 * Implicitely assign POST data to postData hash.
	 */
	public function setPostData(data:Hash<String>):IRequest
	{
		this._postData = data;
		return this;
	}
	
	/* abstract */ public function getPost():Hash<String>
	{
		return throw "Abstract method";
	}
	
    /**
     * Return the value of the given HTTP header.
	 */
	public function getHeader(header:String):String
	{
		return comp.Web.getClientHeader(header);		
	}

    /**
     * Is the request a Javascript XMLHttpRequest?
	 */
	public function isAjaxRequest():Bool
	{
		return 'XMLHttpRequest' == this.getHeader('X-Requested-With');
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(?options:Dynamic):Void
	{
		if (Type.getClass(this) == AbstractRequestHttp) {
			throw "Abstract class, no instantiation";
		}

		// Call super constructor
		super();
		
		this.setRequestUri();
	}
	
}