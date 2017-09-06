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
package org.toolkt.core.application.bootstrap.abstract;

import org.toolkt.core.application.Application;
import org.toolkt.core.application.interfaces.IBootstrapper;
import org.toolkt.core.application.resource.abstract.AbstractResource;
import org.toolkt.core.controller.FrontController;
import org.toolkt.core.session.Session;

/* abstract */ class AbstractBootstrap implements IBootstrapper
{

	/**
	 * Application object
	 */
	private var _application:Application;
	
    /**
     * Set application object.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setApplication(app:Application):IBootstrapper
	{
		this._application = app;
		return this;
	}
	
    /**
     * Retrieve application object.
	 */
	public function getApplication():Application
	{
		return this._application;
	}
	
	/**
	 * Abstract class, no instantiation.
	 */
	private function new(app:Application):Void
	{
		if (Type.getClass(this) == AbstractBootstrap) {
			throw "Abstract class, no instantiation";
		}

		this.setApplication(app);
	}
	
	/* abstract */ public function setOptions():Void
	{
		return throw "Abstract method";
	}
	
	public function bootstrap():Void
	{
		this._init();
	}

	/**
	 * Dispatch the front controller
	 */
	public function run():Void
	{
		Session.start('haXe_session');
		try {		
			FrontController.getInstance().setParam('baseUrl',    this._getAppOption('baseUrl'))
										 .setParam('appPath',    this._getAppOption('appPath'))
										 .setParam('templEn',    this._getAppOption('templEn'))
										 .setParam('mmcd',       this._getAppOption('mmcd'))
										 .setParam('layout',     this._getAppOption('layout'))
										 .setParam('encryptKey', this._getAppOption('encryptKey'))
										 .dispatch();
			Session.end();
		} 
		catch (e:org.toolkt.core.controller.exceptions.DispatchExitException) {
			// Exception thrown by plugin during preDispatch
		}
		
		// Close any default db connection
		org.toolkt.core.db.adapter.abstract.AbstractAdapter.closeDefault();
	}

	/**
	 * @return	Value from Application options hash, 
	 *          or null if value is not set.
	 */
	private function _getAppOption(key:String):Dynamic
	{
		try {
			var option:Dynamic = 
				this.getApplication().getOption(key);
			return option;
		} catch (e:org.toolkt.core.application.exceptions.OpNotSetException) {
			// Not set
			return null;
		} 
	}

	/* abstract */ private function _init():Void
	{
		return throw "Abstract method";
	}

	private function _initResource(resourceCl:Class<AbstractResource>, 
	                               ?options:Hash<Dynamic>):AbstractResource
	{
		var resource:AbstractResource = Type.createInstance(resourceCl, []);

		// Initialize resource
		resource.init(options);
		
		return resource;
	}
	
}