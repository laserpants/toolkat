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
package org.toolkt.core.view.helper;

import org.toolkt.core.controller.action.helper.FlashMessenger;
import org.toolkt.core.view.helper.abstract.AbstractHelper;
import org.toolkt.core.view.interfaces.IViewHelper;

class JsDisplayMessageHelper extends AbstractHelper
{

	/**
	 * FlashMessenger instance
	 */
	private var _flash:FlashMessenger;
	
	/**
	 * Output messages from current request?
	 */
	private var _current:Bool;
	
	/**
	 * Message type is error?
	 */
	private var _isError:Bool;
	
	public function setFlashMessenger(flash:FlashMessenger):JsDisplayMessageHelper
	{
		this._flash = flash;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}

	override public function init():Void
	{
		this._current = false;
		this._isError = false;
	}
	
	override public function set(param:String, value:Dynamic):IViewHelper
	{
		switch (param) {
			case 'error':
				this._isError = cast(value, Bool);
				
			case 'current':
				this._current = cast(value, Bool);
				
			default:
				// Invalid parameter
		}
		return this;
	}
	
	override public function go():String
	{
		return this._jsDisplayHelper(this._current, this._isError);
	}

	public function jsDisplayMessageHelper(current:Bool):String
	{
		return this._jsDisplayHelper(current);
	}

	public function jsDisplayErrorHelper(current:Bool):String
	{
		return this._jsDisplayHelper(current, true);
	}
	
	private function _jsDisplayHelper(current:Bool, ?isError = false):String
	{
		if (null == this._flash) {
			throw 'Error, no FlashMessenger assigned to JsDisplayMessageHelper instance.';
		}
		
		var messages:Array<String> = 
			(true == current) ? this._flash.flushCurrent() : this._flash.getMessages();
		var str:String = '';

		if (0 == messages.length) {
			return str;
		}
		
		var type:String = (isError) ? 'Error' : 'Message';
		
		str += '<script type="text/javascript">';
		str += 'display' + type + '([';
		var c:Int = 0;
		for (msg in messages) {
			if (c++ != 0) str += ',';
			str += '\'' + msg + '\'';
		}
		str += ']);';
		str += '</script>';
		
		return str;
	}
	
}
