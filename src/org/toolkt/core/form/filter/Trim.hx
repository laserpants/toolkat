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
package org.toolkt.core.form.filter;

import org.toolkt.core.form.filter.abstract.AbstractFilter;

class Trim extends AbstractFilter<String>
{

	/**
	 * Characters to trim from beginning and end of string.
	 */
	private static inline var TRIM_CHARS = ['+', ' '];
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super(options);
	}
	
	override public function filter(value:String):String
	{
		while (this._inArray(value.charAt(0), Trim.TRIM_CHARS)) {
			value = this._ltrim(value);
		}
		while (this._inArray(value.charAt(value.length - 1), Trim.TRIM_CHARS)) {
			value = this._rtrim(value);
		}
		return value;
	}
	
	private function _inArray(value:String, array:Array<String>):Bool
	{
		for (str in array) {
			if (value == str)  
				return true;
		}
		return false;
	}
	
	private function _ltrim(value:String):String
	{
		return value.substr(1);
	}

	private function _rtrim(value:String):String
	{
		return value.substr(0, -1);
	}
	
}