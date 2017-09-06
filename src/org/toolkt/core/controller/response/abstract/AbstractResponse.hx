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
package org.toolkt.core.controller.response.abstract;

import org.toolkt.core.controller.interfaces.IResponse;

/* abstract */ class AbstractResponse
	implements IResponse
{
	
    /**
     * Headers in the format {name => value}.
	 */
	private var _headers:Hash<String>;
	
    /**
     * Body content
	 */
	private var _body:String;
	
    /**
     * Is this response a redirect?
     */
	private var _isRedirect:Bool;
	
    /**
     * Exception stack
	 */
	private var _exceptions:Array<org.toolkt.core.Exception>;
	
    /**
     * Is this a redirect?
     */
	public function isRedirect():Bool
	{
		return this._isRedirect;
	}
		
	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractResponse) {
			throw "Abstract class, no instantiation";
		}
		
		this._body       = '';
		this._isRedirect = false;
		this._headers    = new Hash<String>();
		this._exceptions = [];
	}
	
    /**
     * Append content to the body content.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function appendBody(content:String):IResponse
	{
		this._body += content;
		return this;
	}
	
	/* abstract */ public function sendResponse():Void
	{
		return throw "Abstract method";
	}

	/**
	 * Print out the response body.
	 */
	private function _outputBody()
	{
		// Remove blank lines
		var body:String = StringTools.replace(this._body, '\n\n' , '\n');
		
		comp.Lib.print(body);
	}
	
    /**
     * Register an exception with the response.
     */
	public function setException(e:Dynamic):Void
	{
		var klass:Class<Dynamic> = Type.getClass(e);
		
		if (org.toolkt.core.Exception != klass &&
		    org.toolkt.core.Exception != Type.getSuperClass(klass)) 
		{
//			this._exceptions.push(new org.toolkt.core.Exception());
			this._exceptions.push(new org.toolkt.core.Exception(e));
			return;
		}
		this._exceptions.push(e);
	}
	
    /**
     * Retrieve the exception stack
     */
	public function getExceptions():Array<org.toolkt.core.Exception>
	{
		return this._exceptions;
	}
	
    /**
     * Has an exception been registered with the response?
     */
	public function isException():Bool
	{
		return (this._exceptions.length != 0);
	}
	
}