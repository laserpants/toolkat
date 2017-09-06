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

import org.toolkt.core.view.helper.abstract.AbstractHelper;
import org.toolkt.core.view.interfaces.IView;
import org.toolkt.core.view.interfaces.IViewHelper;
import org.toolkt.core.view.interfaces.IViewHelperBroker;

class ViewHelperBroker 
	implements IViewHelper, 
	implements IViewHelperBroker
{

	/**
	 * View instance
	 */
	private var _view:IView;

	/**
	 * Registered view helpers
	 */
	private var _helpers:Hash<IViewHelper>;
		
	/**
	 * Constructor
	 */
	public function new(view:IView):Void
	{
		this._view = view;
		this._helpers = new Hash<IViewHelper>();
	}

	/**
	 * Register a view helper, unless a helper with provided name already exists.
	 */
	public function addHelper(name:String, helper:IViewHelper):IViewHelperBroker
	{
		if (this.hasHelper(name)) {
			return this;
			//throw 'ViewHelper with provided name already exists.';
		}
		this._helpers.set(name, helper);
		return this;
	}
	
	/**
	 * @return  Whether a helper exists with provided name
	 */
	public function hasHelper(name:String):Bool
	{
		return this._helpers.exists(name);
	}
	
	/**
	 * @return	Helper matching provided name
	 */
	public function getHelper(name:String):IViewHelper
	{
		return this._helpers.get(name);
	}
	
	/**
	 * GetSetGo implementation: ...
	 * 
	 * If no helper exists with provided name, returns self (ViewHelperBroker)
	 * which also implements IViewHelper to avoid errors in view scripts when
	 * non-existing helpers are called with 'get().set().go()'.
	 */
	public function get(name:String):IViewHelper
	{
		if (this.hasHelper(name)) {
			var helper:IViewHelper = this.getHelper(name);
			helper.init();
			
			return helper;
		} else {
			return this;
		}
	}
	
	public function set(param:String, value:Dynamic):IViewHelper
	{
		return this;
	}
	
	public function go():String
	{
		return '';
	}

	public function init():Void
	{
	}
	
}