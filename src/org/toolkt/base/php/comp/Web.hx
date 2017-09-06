﻿/**
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
package comp;

class Web 
{

	public static inline function getCwd():String
	{
		return php.Web.getCwd();
	}
	
	public static inline function getURI():String
	{
		return php.Web.getURI();
	}
	
	public static inline function getParams():Hash<String>
	{
		return php.Web.getParams();
	}
	
	public static inline function getParamsString():String
	{
		return php.Web.getParamsString();
	}
	
	public static inline function getMethod():String
	{
		return untyped __php__("$_SERVER['REQUEST_METHOD']");
	}
	
	public static inline function getPostData():String
	{
		return php.Web.getPostData();
	}
	
	public static inline function setHeader(h:String, v:String):Void
	{
		php.Web.setHeader(h, v);
	}

	public static inline function setReturnCode(r:Int):Void
	{
		php.Web.setReturnCode(r);
	}

	public static inline function setCookie(key:String, 
	                                        value:String, 
											?expire:Date, 
											?domain:String, 
											?path:String, 
											?secure:Bool):Void
	{
		php.Web.setCookie(key, value, expire, domain, path, secure);
	}
	
	public static inline function getCookies():Hash<String>
	{
		return php.Web.getCookies();
	}
	
	public static inline function getClientHeader(str:String):String
	{
		return php.Web.getClientHeader(str);
	}

	public static function getMultipart(maxSize:Int):Hash<String>
	{
		return php.Web.getMultipart(maxSize);
	}
	
}