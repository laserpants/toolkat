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
package org.toolkt.core.view.abstract;

import org.toolkt.core.application.Application;
import org.toolkt.core.view.helper.ViewHelperBroker;
import org.toolkt.core.view.interfaces.IView;
import org.toolkt.core.view.interfaces.IViewHelperBroker;

enum TemplEngine 
{
	Templo;
	Phtml;
	Custom;
}

/* abstract */ class AbstractView implements IView
{

	/**
	 * Name of layout script (without extension).
	 */
	private var _layout:String;
	
	/**
	 * Application script directory in the local filesystem.
	 */
	private var _applicationPath:String;
	
	/**
	 * View helper broker instance.
	 */
	private var _helperBroker:IViewHelperBroker;
	
	/**
	 * Set application script directory.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setApplicationPath(path:String):IView
	{
		this._applicationPath = path;
		return this;
	}
	
	/**
	 * Assign a layout script to view.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setLayout(layout:String):IView
	{
		this._layout = layout;
		return this;
	}
	
	/**
	 * Get layout script name.
	 */
	public function getLayout():String
	{
		return this._layout;
	}
	
	/**
	 * @return	True if a layout script has been assigned
	 */
	public function hasLayout():Bool
	{
		return (null != this._layout);
	}
	
	public function getHelperBroker():IViewHelperBroker
	{
		return this._helperBroker;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(path:String):Void
	{
		if (Type.getClass(this) == AbstractView) {
			throw "Abstract class, no instantiation";
		}
		
		this.setApplicationPath(path);
		
		// Instansiate helper broker and assign it to view variable 'helper'
		this._helperBroker = new ViewHelperBroker(this);
		this.assignVar('helper', this._helperBroker);
	}

	/**
	 * AbstractView factory method
	 * 
	 * @todo	Custom
	 */
	public static function factory(viewType:TemplEngine, ?path:String):AbstractView
		// ?klass<IView> = null
	{
		switch (viewType) {
			case Phtml:
				return new org.toolkt.core.view.ViewPhtml(path);

			case Templo:
				return new org.toolkt.core.view.ViewTemplo(path);
			
			case Custom:
			
				/*
				if (null == klass) {
					throw 'Error';
				}
				*/
				return throw 'Not implemented';
			
			default:
				return throw "Error, unsupported template engine";
		}
	}
	
	/* abstract */ public function render(script:String):String
	{
		return throw "Abstract method";
	}
	
	/* abstract */ public function getVars():Dynamic
	{
		return throw "Abstract method";
	}

	/* abstract */ public function assign(vars:Dynamic):Void
	{
		return throw "Abstract method";
	}

	/* abstract */ public function assignVar(variable:String, value:Dynamic):Void
	{
		return throw "Abstract method";
	}

	/* abstract */ public function clearVars():IView
	{
		return throw "Abstract method";
	}
	
}