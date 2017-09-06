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
package org.toolkt.core.controller.action.helper.abstract;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.controller.interfaces.IActionController;

/* abstract */ class AbstractHelper 
{

	private var _actionController:IActionController<Dynamic, Dynamic>;
	
	private var _frontController:FrontController;
	
	/**
	 * @return	Provides a fluent interface
	 */
	public function setActionController(controller:IActionController<Dynamic, Dynamic>):AbstractHelper
	{
		this._actionController = controller;
		return this;
	}
	
	public function getActionController():IActionController<Dynamic, Dynamic>
	{
		return this._actionController;
	}
	
	public function getFrontController():FrontController
	{
		if (null == this._frontController) {
			this._frontController = FrontController.getInstance();
		}
		return this._frontController;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractHelper) {
			throw "Abstract class, no instantiation";
		}
	}

    /**
     * Hook into action controller preDispatch() workflow.
	 * (Not abstract, since implementation is not required in helpers.)
     */
    public function preDispatch():Void;

    /**
     * Hook into action controller postDispatch() workflow.
	 * (Not abstract, since implementation is not required in helpers.)
     */
    public function postDispatch():Void;
	
}