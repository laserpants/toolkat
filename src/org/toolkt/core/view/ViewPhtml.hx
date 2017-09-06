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
package org.toolkt.core.view;

import org.toolkt.core.view.abstract.AbstractView;
import org.toolkt.core.view.interfaces.IView;

class ViewPhtml extends AbstractView
{

	/**
	 * Base template directory relative to application root.
	 */
	private static inline var BASE_DIR  = 'app/views/phtml';
	
	/**
	 * Template file extension.
	 */
	private static inline var EXTENSION = '.phtml';
	
	/**
	 * Template variables
	 */
	public var vars:Dynamic;
	
	/**
	 * Filesystem path to template folder.
	 */
	private var _folderPath:String;
	
	/**
	 * Constructor
	 */
	public function new(path:String):Void
	{
		this.vars = {};
		
		super(path);
		
		var baseDir:String = ViewPhtml.BASE_DIR;		
		// Trailing slash needed
		if (baseDir.charAt(baseDir.length) != '/') {
			baseDir += '/';
		}
		
		this._folderPath = this._applicationPath + baseDir;
	}
	
    /**
     * Processes a view script and returns the output.
	 */
	override public function render(script:String):String
	{		
		var file:String = script + ViewPhtml.EXTENSION;
		
		var expr:String = this._folderPath + file;
		
		untyped __call__("ob_start");		
		untyped __call__("include", expr);
		var out:String = untyped __call__("ob_get_contents");
		untyped __call__("ob_end_clean");
		
		return out;
	}

	override public function assign(vars:Dynamic):Void
	{
		for (field in Reflect.fields(vars)) {
			Reflect.setField(this.vars, field, 
				Reflect.field(vars, field));
		}
	}

	override public function getVars():Dynamic
	{
		return this.vars;
	}
	
	override public function assignVar(variable:String, value:Dynamic):Void
	{
		Reflect.setField(this.vars, variable, value);
	}

	/**
	 * Clear template variables.
	 * 
	 * @return	Provides a fluent interface
	 */
	override public function clearVars():IView
	{
		this.vars = {};
		return this;
	}
	
}