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
package org.toolkt.core.form;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.form.element.FormElement;

class Form
{
	
	/**
	 * Method type constants
	 */
	public static inline var METHOD_DELETE      = 'delete';
	public static inline var METHOD_GET         = 'get';
	public static inline var METHOD_POST        = 'post';
	public static inline var METHOD_PUT         = 'put';
	
	/**
	 * Encoding type constants
	 */
	public static inline var ENCTYPE_URLENCODED = 'application/x-www-form-urlencoded';
	public static inline var ENCTYPE_MULTIPART  = 'multipart/form-data';
	
    /**
     * Form elements
	 */
	private var _elements:Hash<FormElement>;
	
	/**
	 * Form attributes
	 */
	private var _attributes:Hash<String>;
	
	private var _baseUrl:String;
	
    /**
     * Retrieve all form elements.
     */
	public function getElements():Hash<FormElement>
	{
		return this._elements;
	}
	
    /**
     * Retrieve a single form element.
     */
	public function getElement(name:String):FormElement
	{
		if (!this._elements.exists(name)) {
			throw 'Error, field named \'' + name + '\' does not exist';
		}
		return this._elements.get(name);
	}
	
	public function getBaseUrl():String
	{
		if (null == this._baseUrl) {
			this._baseUrl = FrontController.getInstance().getParam('baseUrl');
		}
		return this._baseUrl;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		this.clearElements();
		this._attributes = new Hash<String>();
	}
	
	public function setAttribute(key:String, value:String):Void
	{
		this._attributes.set(key, value);
	}
	
	public function getAttribute(key:String):String
	{
		return this._attributes.get(key);
	}
	
	public function setAction(action:String):Void
	{
		this.setAttribute('action', action);
	}
	
	public function getAction():String
	{
		if (null == this.getAttribute('action')) {
			this.setAttribute('action', '');
		}
		return this.getAttribute('action');
	}
	
	public function setMethod(method:String):Void
	{
		this.setAttribute('method', method);
	}
	
	public function getMethod():String
	{
		if (null == this.getAttribute('method')) {
			var method:String = Form.METHOD_POST;
			this.setAttribute('method', method);
		}
		return this.getAttribute('method');
	}
	
	public function setEnctype(value:String):Void
	{
		this.setAttribute('enctype', value);
	}
	
	public function getEnctype():String
	{
		if (null == this.getAttribute('enctype')) {
			var enctype:String = Form.ENCTYPE_MULTIPART;
			this.setAttribute('enctype', enctype);
		}
		return this.getAttribute('enctype');
	}
	
	public function getLabel(element:String):String
	{	
		var element:FormElement = this.getElement(element);
		
		if (null == element) {
			return '';
		}
		return element.getLabel();
	}
	
    /**
     * Add a new element.
	 * 
	 * @return	Provides a fluent interface
     */
	public function addElement(element:FormElement, ?name:String):Form
	{
		if (null == name) {
			name = element.getName();
		}
		
		this._elements.set(name, element);
		
		return this;
	}
	
	/**
	 * @todo
	 */
	public function removeElement(name:String):Bool
	{
		return throw 'Not implemented';
	}
	
    /**
     * Remove all form elements.
     */
	public function clearElements():Void
	{
		this._elements = new Hash<FormElement>();
	}
	
    /**
     * Validate the form.
     */
	public function isValid(data:Hash<String>):Bool
	{
		if (null == this._elements) {
			this._elements = new Hash<FormElement>();
			return true;
		}
		
		var valid:Bool = true;
		
		// Validate elements
		for (elementKey in this._elements.keys()) {
			
			var element:FormElement = this._elements.get(elementKey);
			
			var elementData:String = null;
			if (data.exists(elementKey)) {
				elementData = data.get(elementKey);
			}
			
			// Also assigns the value
			valid = element.isValid(elementData, data) && valid;
		}
		
		return valid;
	}
	
    /**
     * Retrieve value for single element.
     */ 
	public function getValue(name:String):Dynamic
	{
		var element:FormElement = this.getElement(name);
		return element.getValue();
	}
	
	/**
	 * @todo
	 */
	public function getValues():Void
	{
		return throw 'Not implemented';
	}
	
	/**
	 * Populate form elements with data (from model).
	 * 
	 * @param	data	Hash with data in format: {element => value}
	 */
	public function populate(data:Hash<String>):Void
	{
		for (elementKey in data.keys()) {
			var element:FormElement = this.getElement(elementKey);
			if (null == element) {
				continue;
			}
			element.setValue(data.get(elementKey));
		}
	}
	
	/**
	 * @todo
	 */
	public function render():String
	{
		return throw 'Not implemented';
	}
	
}