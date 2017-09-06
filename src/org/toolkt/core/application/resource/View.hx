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
package org.toolkt.core.application.resource;

import org.toolkt.core.application.resource.abstract.AbstractResource;
import org.toolkt.core.controller.action.helper.HelperBroker;
import org.toolkt.core.controller.action.helper.ViewRenderer;
import org.toolkt.core.view.abstract.AbstractView;
import org.toolkt.core.view.interfaces.IView;

class View extends AbstractResource
{

	private static inline var REQUIRED_OPTIONS = ['path', 'engine'];
	
	/**
	 * Application script directory in the local filesystem.
	 */
	private var _path:String;
	
	/**
	 * View template engine.
	 */
	private var _viewEngine:TemplEngine;
	
	/**
	 * Name of layout script (without extension).
	 */
	private var _layout:String;

	/**
	 * Returns array of required options for initialization.
	 */
	override public function getRequiredOptions():Array<String>
	{
		return View.REQUIRED_OPTIONS;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
    /**
     * Initialize resource
	 */
	override public function init(?options:Hash<Dynamic>):Void
	{
		super.init(options);
		
		var view:IView = AbstractView.factory(this._viewEngine, this._path);
		
		if (null != this._layout) {
			view.setLayout(this._layout);
		}
		
		var viewRenderer:ViewRenderer = new ViewRenderer();
		viewRenderer.setView(view);
		
		if (null == this._layout) {
			viewRenderer.noLayout();
		}
		HelperBroker.addHelper('ViewRenderer', viewRenderer);
	}

	/**
	 * Override defaults with values from options hash.
	 * 
	 * Called from init() in AbstractResource.
	 */
	override private function _assignOptions():Void
	{
		this._path       = this.getOption('path');
		this._viewEngine = this.getOption('engine');
		this._layout     = this.getOption('layout');
	}
	
}