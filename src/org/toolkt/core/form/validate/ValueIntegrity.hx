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

import org.toolkt.core.form.interfaces.IValueIntegrityMapper;
import org.toolkt.core.form.validate.abstract.AbstractValidator;

class ValueIntegrity extends AbstractValidator<String>
{

	private static inline var ERROR_VALUE_NOT_UNIQUE = 'value_not_unique';
	
	/**
	 * A data mapper instance that performs the validation.
	 */
	private var _mapper:IValueIntegrityMapper;
	
	/**
	 * Name of the field to check
	 */
	private var _field:String;
	
	/**
	 * Message to display when validation fails.
	 */
	private var _message:String;
	
	/**
	 * Value to exclude from validation, such as the present value when editing a resource.
	 */
	private var _exclude:String;
	
	public function setMapper(mapper:IValueIntegrityMapper):ValueIntegrity
	{
		this._mapper = mapper;
		return this;
	}
	
	public function setField(field:String):ValueIntegrity
	{
		this._field = field;
		return this;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Dynamic):Void
	{
		super(options);
		
		this._message = 'Value is not unique.';
		
		if (null == options.mapper) {
			throw "Option 'mapper' required for validator ValueIntegrity";
		}
		if (null == options.field) {
			throw "Option 'field' required for validator ValueIntegrity";
		}
		
		if (null != options.message) {
			this._message = options.message;
		}
		
		if (null != options.exclude) {
			this._exclude = options.exclude;
		}

		this.setMapper(options.mapper)
		    .setField(options.field);
	}

	override public function isValid(value:String, ?context:Hash<String>):Bool
	{
		this._value = value;
		
		if ((null != this._exclude && value == this._exclude) ||
			true == this._mapper.valueIsUnique(this._field, value)) {
			return true;
		}
		
		this._error(ValueIntegrity.ERROR_VALUE_NOT_UNIQUE, this._message);
		return false;
	}
	
}