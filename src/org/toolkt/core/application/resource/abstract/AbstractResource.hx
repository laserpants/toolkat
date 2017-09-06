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
package org.toolkt.core.application.resource.abstract;

import org.toolkt.core.application.interfaces.IResource;

/* abstract */ class AbstractResource implements IResource
{
	
    /**
     * Options for the resource
	 */
	private var _options:Hash<Dynamic>;

	/* abstract */ public function getRequiredOptions():Array<String>
	{
		return throw "Abstract method";
	}
	
	/**
     * Set resource options.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setOptions(options:Hash<Dynamic>):IResource
	{
		this._options = options;
		return this;
	}

    /**
     * Retrieve resource options
	 */
	public function getOptions():Hash<Dynamic>
	{
		return this._options;
	}

	/**
	 * Retrieve single option from options hash
	 */
	public function getOption(option:String):Dynamic
	{
		return this._options.get(option);
	}

	public function init(?options:Hash<Dynamic>):Void
	{
		this._checkRequiredOptions(options)
		    ._setDefaults()
			._assignOptions();
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractResource) {
			throw "Abstract class, no instantiation";
		}
	}
	
	/**
	 * Set default values.
	 */
	private function _setDefaults():AbstractResource
	{
		return this;
	}

	/**
	 * Override defaults with values from options hash.
	 */
	private function _assignOptions():Void;
	
	private function _checkRequiredOptions(options:Hash<Dynamic>):AbstractResource
	{
		this._options = options;
		
		if (null == this._options) {
			this._options = new Hash();
		}
		
		for (option in this.getRequiredOptions()) {
			if (null == this._options.get(option)) {
				throw new org.toolkt.core.application.resource.exceptions.OptionRequiredException(
					"Missing required option '" + option + "'");
			}
		}
		
		return this;
	}
	
}