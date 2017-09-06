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
package org.toolkt.core.helper;

class StrTrim 
{

	/**
	 * Constructor, disabled.
	 */
	private function new():Void
	{
		throw "Instantiation of class StrTrim not allowed.";
	}
	
	/**
	 * Trim character from beginning of string.
	 */
	public static function ltrimChar(str:String, char:String):String
	{
		if (char.length != 1) {
			char = char.charAt(0);
		}
		if (char == str.charAt(0)) {
			str = str.substr(1);
		}
		return str;
	}

	/**
	 * Trim character from end of string.
	 */
	public static function rtrimChar(str:String, char:String):String
	{
		if (char.length != 1) {
			char = char.charAt(0);
		}
		if (char == str.substr(-1)) {
			str = str.substr(0, str.length-1);
		}
		return str;
	}
	
	/**
	 * Trim character from beginning and end of string.
	 */
	public static function trimChar(str:String, char:String):String
	{
		str = StrTrim.rtrimChar(StrTrim.ltrimChar(str, char), char);
		return str;
	}	
	
}