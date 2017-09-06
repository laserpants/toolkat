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
package org.toolkt.core.controller.plugin;

import org.toolkt.core.controller.request.abstract.AbstractRequest;
import org.toolkt.core.controller.plugin.abstract.AbstractPlugin;
import org.toolkt.core.controller.response.abstract.AbstractResponse;

class ErrorHandler extends AbstractPlugin
{

    /**
     * Exception count logged at first invocation of plugin.
	 */
	private var _initialExceptionCount:Int;
	
	private var _insideLoop:Bool;
	
	public function isInsideLoop():Bool
	{
		return this._insideLoop;
	}
	
	/**
	 * Constructor
	 */
	public function new(?options:Hash<Dynamic>):Void
	{
		super(options);
		
		this._initialExceptionCount = 0;
		this._insideLoop = false;
	}

	override public function postDispatch(request:AbstractRequest):Void
	{
		var response:AbstractResponse = this.getResponse();
		var exceptions:Array<org.toolkt.core.Exception> = response.getExceptions();
		
		if (this.isInsideLoop()) {
			if (exceptions.length > this._initialExceptionCount) 
			{
                // Exception thrown by error handler; tell the front controller to throw it
				org.toolkt.core.controller.FrontController.getInstance().setThrowExceptions(true);
				var e:Dynamic = exceptions.pop();
				throw e;
			}
		}

		if (response.isException() && !this.isInsideLoop()) {
			
			this._insideLoop = true;
			
			var e:org.toolkt.core.Exception = exceptions[0];
			
			this.getRequest().module     = 'default';
			this.getRequest().controller = 'error';
			this.getRequest().action     = 'index';
			
			this.getRequest().setDispatched(false);

            // Get count of the number of exceptions encountered
            this._initialExceptionCount = exceptions.length;

			var errorClass:String   = Type.getClassName(Type.getClass(e));
			var errorMessage:String = e.getMessage();
			var errorSource:String  = e.getSource(true);
			
			request.setParam('errorClass', errorClass)
			       .setParam('errorMsg', errorMessage)
                   .setParam('errorSrc', errorSource);
		}
	}
	
}