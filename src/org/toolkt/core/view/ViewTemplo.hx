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

import mtwin.templo.Loader;
import org.toolkt.core.Exception;
import org.toolkt.core.view.interfaces.IView;
import org.toolkt.core.view.abstract.AbstractView;

class ViewTemplo extends AbstractView
{
	
	/**
	 * Base template directory relative to application root.
	 */
	private static inline var BASE_DIR  = 'app/views/templo';

	/**
	 * Compiled template directory relative to application root.
	 * This folder needs to be writable.
	 */
	private static inline var TMP_DIR   = 'data/layouts/compiled';
	
	/**
	 * Template file extension.
	 */
	private static inline var EXTENSION = '.mtt';
	
	/**
	 * Variables {name: value} that are passed on to the template.
	 */
	private var _variables:Dynamic;
	
	/**
	 * Constructor
	 */
	public function new(path:String):Void
	{
		this._variables = {};
		super(path);
		this._initTemplo();
	}

    /**
     * Processes a view script and returns the output.
	 */
	override public function render(script:String):String
	{
		var out:String = '';
		try {
			var t:Loader = new Loader(script + ViewTemplo.EXTENSION);
			out = t.execute(this._variables);
		} catch (e:Dynamic) {
			throw new Exception('Templo error. [Script file name: ' + script + ']');
		}
		return out;
	}
	
	/**
	 * Assign variables that are passed on to the template.
	 */
	override public function assign(vars:Dynamic):Void
	{
		for (field in Reflect.fields(vars)) {
			Reflect.setField(this._variables, field, 
				Reflect.field(vars, field));
		}
	}
	
	/**
	 * @return	Template vars. object
	 */
	override public function getVars():Dynamic
	{
		return this._variables;
	}
	
	/**
	 * Assign single variable to variables passed on to template.
	 */
	override public function assignVar(variable:String, value:Dynamic):Void
	{
		Reflect.setField(this._variables, variable, value);
	}
	
	/**
	 * Clear template variables.
	 * 
	 * @return	Provides a fluent interface
	 */
	override public function clearVars():IView
	{
		this._variables = {};
		return this;
	}
	
	/**
	 * Setting Templo Loader vars.
	 */
	private function _initTemplo():Void
	{
		var baseDir:String = ViewTemplo.BASE_DIR;
		var tmpDir:String  = ViewTemplo.TMP_DIR;
		
		// Trailing slash needed
		if (baseDir.charAt(baseDir.length) != '/') {
			baseDir += '/';
		}
		if (tmpDir.charAt(tmpDir.length) != '/') {
			tmpDir += '/';
		}

		Loader.BASE_DIR  = this._applicationPath + baseDir;
		Loader.TMP_DIR   = this._applicationPath + tmpDir;
		Loader.MACROS    = null;
		Loader.OPTIMIZED = false;
	}
	
}
