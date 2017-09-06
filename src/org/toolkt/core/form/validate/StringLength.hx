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
package org.toolkt.core.form.validate;

import org.toolkt.core.form.validate.abstract.AbstractValidator;

class StringLength extends AbstractValidator<String>
{
	
	private static inline var ERROR_TOO_SHORT = 'too_short';

	private static inline var ERROR_TOO_LONG  = 'too_long';
	
    /**
     * Minimum length.
	 */
	private var _minLength:Int;
	
    /**
     * Maximum length. If null, there is no maximum length
	 */
	private var _maxLength:Int;
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super(options);
		
		if (null == options.min) {
			throw "Option minLength required for validator StringLength";
		}
		this._minLength = options.min;
		
		if (null != options.max) {
			this._maxLength = options.max;
		}
	}

	/**
	 * Returns true if, and only if the string length of 'value' is at least
	 * the min option and no greater than the max option (when the max option is set).
	 */
	override public function isValid(value:String, ?context:Hash<String>):Bool
	{
		this._value = value;
		var length:Int = this._value.length;
		
		if (length < this._minLength) {
			this._error(StringLength.ERROR_TOO_SHORT, 
				'Value too short, must be at least ' + this._minLength + ' characters.');
			return false;
		}
		
		if (null == this._maxLength) {
			return true;
		}
			
		if (length > this._maxLength) {
			this._error(StringLength.ERROR_TOO_LONG, 
				'Value too long, must not be more than ' + this._maxLength + ' characters.');
			return false;
		}
		
		return true;
	}
	
}