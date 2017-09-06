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
package org.toolkt.core.form.element;

import org.toolkt.core.form.filter.abstract.AbstractFilter;
import org.toolkt.core.form.validate.abstract.AbstractValidator;

class FormElement
{

	private static inline var ERROR_VALUE_REQUIRED = 'value_required';

    /**
     * Element value
	 */
	private var _value:String;
	
	/**
	 * Element name
	 */
	private var _name:String;
	
	/**
	 * Is value required?
	 */
	private var _required:Bool;
	
    /**
     * Element filters
	 */
	private var _filters:Array<AbstractFilter<Dynamic>>;
	
    /**
     * Error messages
	 */
	private var _messages:Hash<String>;
	
	/**
	 * Element has errors?
	 */
	private var _errors:Bool;
	
	/**
	 * Element label
	 */
	private var _label:String;

    /**
     * Initialized validators
	 */
	private var _validators:Array<AbstractValidator<Dynamic>>;
	
	/**
	 * Set form element's value.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setValue(value:String):FormElement
	{
		this._value = value;
		return this;
	}
	
	/**
	 * Get the filtered value.
	 */
	public function getValue():String
	{
		var filteredValue:String = this._value;
		
		if (null == filteredValue) {
			filteredValue = '';
		}

		for (filter in this.getFilters()) {
			filteredValue = filter.filter(filteredValue);
		}
		
		return filteredValue;
	}
	
	/**
	 * @return	The element's name
	 */
	public function getName():String
	{
		return this._name;
	}
	
	/**
	 * @return	Provides a fluent interface
	 */
	public function setRequired(value:Bool):FormElement
	{
		this._required = value;
		return this;
	}
	
	public function getMessages():Hash<String>
	{
		return this._messages;
	}
	
	/**
	 * @return	Provides a fluent interface
	 */
	public function setLabel(label:String):FormElement
	{
		this._label = label;
		return this;
	}
	
	public function getLabel():String
	{
		if (null == this._label) {
			return '';
		}
		return this._label;
	}
	
    /**
     * Add a filter to the element.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function addFilter(filterClass:Class<Dynamic>, ?options:Dynamic):FormElement
	{
		var filter:AbstractFilter<Dynamic> = Type.createInstance(filterClass, [options]);

		this._filters.push(filter);
		return this;
	}
	
	public function getFilters():Array<Dynamic>
	{
		return this._filters;
	}
	
    /**
     * Add validator to validation chain.
	 * 
	 * @return	Provides a fluent interface
     */
	public function addValidator(validatorClass:Class<Dynamic>, ?options:Dynamic):FormElement
	{
		var validator:AbstractValidator<Dynamic> = Type.createInstance(validatorClass, [options]);
		
		this._validators.push(validator);
		return this;
	}

	public function removeFilters():FormElement
	{
		this._filters = [];
		return this;
	}
	
	public function removeValidators():FormElement
	{
		this._validators = [];
		return this;
	}
	
    /**
     * Are there errors registered?
     */
	public function hasErrors():Bool
	{
		return this._errors;
	}
	
	/**
	 * Constructor
	 */
	public function new(name:String):Void
	{		
		this._name       = name;
		this._required   = false;
		this._filters    = [];
		this._validators = [];
		this._messages   = new Hash<String>();
		this._errors     = false;
	}
		
	/**
	 * Validate the filtered element value and return
	 * true if successful.
	 */
	public function isValid(value:String, ?context:Hash<String>):Bool
	{
		if (null == value) {
			value = '';
		}
		
		this._value = StringTools.urlDecode(value);
		var filteredValue:Dynamic = this.getValue();
		
		// Return false if value is empty, but required
		if ('' == filteredValue && true == this._required) {
			this._errors = true;
			this._messages.set(FormElement.ERROR_VALUE_REQUIRED, 
				'Value must not be blank.');
			return false;
		}
		
		var result:Bool = true;
		
		for (validator in this._validators) {
			
			if (true == validator.isValid(filteredValue, context)) {
				continue;
			}
			
			result = false;
			this._errors = true;
			
			// Add validator messages to element's messages
			var messages:Hash<String> = validator.getMessages();
			for (messageKey in messages.keys()) {
				var message:String = messages.get(messageKey);
				this._messages.set(messageKey, message);
			}			
		}
		return result;
	}
	
}