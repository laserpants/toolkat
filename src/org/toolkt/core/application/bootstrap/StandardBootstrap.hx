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
package org.toolkt.core.application.bootstrap;

import org.toolkt.core.application.Application;
import org.toolkt.core.application.bootstrap.abstract.AbstractBootstrap;
import org.toolkt.core.cache.abstract.AbstractCache;
import org.toolkt.core.db.Db;
import org.toolkt.core.session.Session;
import org.toolkt.node.controller.action.helper.NodeHelper;

class StandardBootstrap extends AbstractBootstrap
{
	
	/**
	 * Constructor
	 */
	public function new(app:Application):Void
	{
		super(app);
	}
	
	private function _initView():StandardBootstrap
	{
		this._initResource(org.toolkt.core.application.resource.View, 
			new org.toolkt.core.helper.QuickHash({
				path:   this._getAppOption('appPath'),
				layout: this._getAppOption('layout'),
				engine: this._getAppOption('templEn')
			})
		);
		
		return this;
	}
	
	private function _initSessionHandler():StandardBootstrap
	{
		var saveHandler:SaveHandlers;
		var params:Dynamic = {};
		
		if (true == this._getAppOption('mmcd')) {
			
			// Use Memcached memory save handler, if active
			saveHandler = SaveHandlers.Memory;
		} else {
			saveHandler = SaveHandlers.FileSystem;
			params = {
				filePath: this._getAppOption('appPath') + 'data/session/'
			};
		}
		
		this._initResource(org.toolkt.core.application.resource.Session, 
			new org.toolkt.core.helper.QuickHash({
				saveHandler: saveHandler,
				params:      params
			})
		);
		return this;
	}
	
	private function _initDb():StandardBootstrap
	{
		var opts:Dynamic = this._getAppOption('db');
		
		if (null != opts) {
			this._initResource(org.toolkt.core.application.resource.Db, opts);
		}
		
		/*
		// SQLite setup
		this._initResource(org.toolkt.core.application.resource.Db,
			new org.toolkt.core.helper.QuickHash({
				adapter: Sqlite,
				params:  {
					database: 'testdb2.s3db',
					path:     this._getAppOption('appPath') + 'db/'
				}
			})
		);
		
		// MySQL setup
		this._initResource(org.toolkt.core.application.resource.Db,
			new org.toolkt.core.helper.QuickHash({
				adapter: Mysql,
				params:  {
					database: 'noodle'
				}
			})
		);
		*/
		
		return this;
	}
	
	private function _initPlugins():StandardBootstrap
	{
		// Register NodeHelper action helper		
		var nodeHelper:NodeHelper = new NodeHelper();
		org.toolkt.core.controller.action.helper.HelperBroker.addHelper('NodeHelper', nodeHelper);
		
		return this;
	}
	
	private function _initRoutes():StandardBootstrap
	{
		return this;
	}
	
	override private function _init():Void
	{
		this._initPlugins()
		    ._initSessionHandler()
		    ._initDb()
		    ._initRoutes()
			._initView();
	}
	
}