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
package org.toolkt.core.controller.interfaces;

import org.toolkt.core.view.interfaces.IView;

interface IActionController<Q, R>
{

	/**
	 * Get request object
	 */
	public function getRequest():Q;
	
	/**
	 * Get response object
	 */
	public function getResponse():R;

	/**
	 * Get invocation parameters
	 */
	public function getParams():Hash<Dynamic>;
	
    /**
     * Dispatch the requested action.
	 */
	public function dispatch(action:String):Void;

    /**
     * Called before action method execution.
	 */ 
	public function preDispatch():Void;
	
    /**
     * Called after action method execution.
	 */ 
	public function postDispatch():Void;

    /**
     * Initialize and assign view object.
	 */
	public function initView():IView;
	
    /**
     * Render a view.
	 */
	public function render(script:String, ?vars:Dynamic, ?useLayout:Bool = false):Void;

    /**
     * Render a view and return output as string.
	 */
	public function renderToStr(script:String, ?vars:Dynamic, ?useLayout:Bool = false):String;
	
}