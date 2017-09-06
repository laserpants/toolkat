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
package org.toolkt.core.controller.response;

import org.toolkt.core.controller.response.abstract.AbstractResponse;
import org.toolkt.core.controller.response.abstract.AbstractResponseHttp;
import org.toolkt.core.controller.interfaces.IResponseHttp;

class ResponseHttp extends AbstractResponseHttp
{
	
    /**
     * HTTP response code to use in headers
	 */
	private var _httpResponseCode:Int;

	/**
	 * Set the HTTP response code.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setHttpResponseCode(code:Int):AbstractResponseHttp
	{
		if (code < 100 || code > 599) {
			throw 'Invalid HTTP response code';
		}
		
		if (300 <= code && code <= 307) {
			this._isRedirect = true;
		} else {
			this._isRedirect = false;
		}
		
		this._httpResponseCode = code;
		return this;
	}
	
    /**
     * Retrieve HTTP response code.
	 */
	public function getHttpResponseCode():Int
	{
		return this._httpResponseCode;
	}

	public function setHeader(name:String, value:String):ResponseHttp
	{
		//this.canSendHeaders(true);
		
		this._headers.set(name, value);
		
		return this;
	}
	
	/**
	 * @return	Provides a fluent interface
	 */
	override public function setRedirect(url:String, ?code:Int = 302):IResponseHttp
	{
		//this.canSendHeaders(true);

		return this.setHeader('Location', url)
		           .setHttpResponseCode(code);
	}
	
	public function new():Void
	{
		super();
		
		// Standard response for successful HTTP requests.
		this._httpResponseCode = 200;
	}
	
    /**
     * Send all headers.
	 * 
	 * @return	Provides a fluent interface
     */
	public function sendHeaders():ResponseHttp
	{
		if (200 == this._httpResponseCode) {
			return this;
		}
	
		comp.Web.setReturnCode(this._httpResponseCode);
		
		for (key in this._headers.keys()) {
			var header:String = this._headers.get(key);
			comp.Web.setHeader(key, header);
		}
		
		return this;
	}

    /**
     * Send the response, including all headers. 
	 */
	override public function sendResponse():Void
	{
		this.sendHeaders()
		    ._outputBody();
	}
	
}