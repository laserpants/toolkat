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
package org.toolkt.core.controller.action.helper;

import org.toolkt.core.controller.action.helper.abstract.AbstractHelper;
import org.toolkt.core.controller.action.helper.exception.BrokerException;
import org.toolkt.core.controller.interfaces.IActionController;

class HelperBroker
{

	/**
	 * ActionController reference
	 */
	private var _actionController:IActionController<Dynamic, Dynamic>;
	
	/**
	 * Action helper stack
	 */
	private static var _helperStack:Hash<AbstractHelper> = new Hash();
	
	/**
	 * Constructor
	 */
	public function new(actionController:IActionController<Dynamic, Dynamic>):Void
	{
		this._actionController = actionController;
		
		// Assign ActionController to registered helpers in stack
		for (helper in HelperBroker._helperStack) {
			helper.setActionController(actionController);
		}
	}
	
    /**
     * Add helper objects.
     */
	public static function addHelper(name:String, helper:AbstractHelper):Void
	{
		if (HelperBroker._helperStack.exists(name)) {
			throw new BrokerException(
				"Action helper with specified name already exists.");
		}
		HelperBroker._helperStack.set(name, helper);
	}
	
	/**
	 * Remove helper from helper stack. If no helper exists,
	 * with specified name, return false. Otherwise return true.
	 */
	public static function removeHelper(name:String):Bool
	{
		if (!HelperBroker._helperStack.exists(name)) {
			return false;
		}
		
		HelperBroker._helperStack.remove(name);
		return true;
	}
	
    /**
     * Is a particular helper loaded in the broker?
     */
	public static function hasHelper(name:String):Bool
	{
		return HelperBroker._helperStack.exists(name);
	}
	
    /**
     * Get helper by name.
     */
	public function getHelper(name:String):AbstractHelper
	{
		if (!HelperBroker._helperStack.exists(name)) {
			throw new BrokerException(
				'Action helper \''+name+'\' not registered with broker.');
		}
		
		var helper:AbstractHelper = HelperBroker._helperStack.get(name);
		return helper;
	}
	
    /**
     * Retrieve or initialize a helper statically.
     */
	public static function getStaticHelper(name:String):AbstractHelper
	{
		if (!HelperBroker._helperStack.exists(name)) {			
			throw new BrokerException(
				'Action helper \'' + name + '\' not registered with broker.');
		}
		
		var helper:AbstractHelper = HelperBroker._helperStack.get(name);
		return helper;
	}	
	
	/**
	 * Called by action controller dispatch method.
	 */
	public function notifyPreDispatch():Void
	{
		for (helper in HelperBroker._helperStack) {
			helper.preDispatch();
		}
	}

	/**
	 * Called by action controller dispatch method.
	 */
	public function notifyPostDispatch():Void
	{
		for (helper in HelperBroker._helperStack) {
			helper.postDispatch();
		}
	}
	
}