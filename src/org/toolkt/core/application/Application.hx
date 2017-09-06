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
package org.toolkt.core.application; 

import Bootstrap;
import org.toolkt.core.application.bootstrap.abstract.AbstractBootstrap;
import org.toolkt.core.cache.abstract.AbstractCache;
import org.toolkt.core.cache.front.abstract.AbstractCacheFront;
import org.toolkt.core.helper.QuickHash;
import org.toolkt.core.view.abstract.AbstractView;
import org.toolkt.core.db.Db;

/**
 * Main application class
 */
class Application
{
	
//	private static var _cacheFront:AbstractCacheFront;
	
	/**
	 * Application bootstrap
	 */
	private var _bootstrap:AbstractBootstrap;
	
	/**
	 * Application options
	 */
	private var _options:Hash<Dynamic>;
	
	/**
	 * Path to current script directory
	 */
	private var _path:String;
	
	public function setBootstrap(bootstrap:AbstractBootstrap):Application
	{
		this._bootstrap = bootstrap;
		return this;
	}
	
    /**
     * Get bootstrap object. Lazy-instatiation of new object if null.
	 */
	public function getBootstrap():AbstractBootstrap
	{
		if (null == this._bootstrap) {
			this._bootstrap = new Bootstrap(this);
		}
		return this._bootstrap;
	}
	
	/**
	 * Get application option.
	 */
	public function getOption(option:String):Dynamic
	{
		if (false == this._options.exists(option)) {
			throw new org.toolkt.core.application.exceptions.OpNotSetException();
		}
		return this._options.get(option);
	}
	
	public function setPath(path:String):Application
	{
		this._path = path;
		return this;
	}
	
	/**
	 * Get the current script directory.
	 */
	public function getPath():String
	{
		if (null == this._path) {
			var path:String = comp.Web.getCwd();
			var cat:String  = '';
			
			path = org.toolkt.core.helper.StrTrim.rtrimChar(path, '/') + '/';
			
			switch (comp.Target.PLATFORM) {
				case 'neko':
					cat = 'bin/';
				case 'php':
					cat = 'www/';
				default:
			}
			if (StringTools.endsWith(path, cat)) {
				path = path.substr(0, path.length - cat.length);
			}
			
			this._path = path;
		}
		return this._path;
	}

	/*
	public static function getCache():AbstractCacheFront
	{
		if (null == Application._cacheFront) {
			Application._cacheFront = AbstractCache.factory(Object, {prefix: 'application'}, {});
		}
		return Application._cacheFront;
	}
	*/
	
	/**
	 * Constructor
	 */
	public function new(?path:String):Void
	{
		if (null != path) {
			this.setPath(path);
		}
		this._setOptions();
	}
	
	/**
	 * Initialize application.
	 */
	public static function main():Void
	{
		var app:Application = new Application();
		app.bootstrap()
		   .run();
	}
	
	/**
	 * Bootstrap application.
	 */
	public function bootstrap():Application
	{
		this.getBootstrap()
		    .bootstrap();
		return this;
	}

	/**
	 * Run the application.
	 */
	public function run():Void
	{
		this.getBootstrap()
		    .run();
	}
	
    /**
     * Set application options.
	 */
	private function _setOptions():Void
	{
		this._readXmlConfig();
	}
	
	/**
	 * @todo	Move param. read logic to Config class?
	 */
	private function _readXmlConfig():Void
	{
		var xml:Xml = null;
		
		/*
		try {
			this._options = Application.getCache().load('app_options');
			
		} catch (e:Dynamic) {
		*/
		
		var filo = 
		
		/*
		 * 
		 * 
	
		var stream:comp.io.FileInput;
		try {
			stream = comp.io.File.read(file, false);
		} catch (e:Dynamic) {
			// File error
			throw e;
		}
		var data:haxe.io.Bytes = stream.readAll();
		var xmlString:String = data.toString();
		stream.close();
		
		*/
		
		try {
//			xml = Xml.parse(xmlString);
			xml = Xml.parse(haxe.Resource.getString('config_xml'));
			// Config.getInstance().init(xml);							// ??
		} catch (e:Dynamic) {
			throw new org.toolkt.node.exceptions.NodeException(
				'Error parsing config.xml');
		}
		
		var tree:Xml          = xml.firstElement();
		var encryptKey:String = this._getInnerXmlData('key', tree);
//		var nodetree:String   = this._getInnerXmlData('nodetree', tree);
		var layout:String     = this._getInnerXmlData('layout', tree);
			
		var targetTree:Xml    = tree.elementsNamed(comp.Target.PLATFORM).next();
		var baseUrl:String    = this._getInnerXmlData('base', targetTree);
		
		if (null == baseUrl) {
			baseUrl = '';
		}
		var templType:String  = this._getInnerXmlData('template', targetTree);
		var mmcd:Bool         = ('true' == this._getInnerXmlData('mmcd', targetTree));

		var engine:TemplEngine;
		switch (templType) {
			case 'templo':
				engine = Templo;
				
			case 'phtml':
				engine = Phtml;
			
			default:
				throw 'Error, invalid template engine specified in application config';
		}
		
		var dbTree:Xml           = targetTree.elementsNamed('db').next();
		var db:Dynamic           = null;
		var adapter:AdapterType  = null;
		var dbOpts:Hash<Dynamic> = null;
		
		if (null != dbTree) {
			db = {};
			for (i in dbTree.elements()) {
				var data:String = this._getInnerXmlData(i.nodeName, dbTree);
				if (i.nodeName == 'adapter') {
					switch (data) {
						case 'mysql':
							adapter = Mysql;
							
						case 'sqlite':
							adapter = Sqlite;
							Reflect.setField(db, 'path', this.getPath() + 'db/');
						
						default:
							throw 'Error, invalid db adapter specified in application config';
					}
				} else {
					Reflect.setField(db, i.nodeName, data);
				}
			}
			
			dbOpts = new org.toolkt.core.helper.QuickHash<Dynamic>({
				adapter: adapter,
				params:  db
			});				
		}
		
		baseUrl = org.toolkt.core.helper.StrTrim.rtrimChar(baseUrl, '/') + '/';
		
		this._options = new QuickHash<Dynamic>({
			appPath:    this.getPath(),
			baseUrl:    baseUrl,
			db:         dbOpts,
			encryptKey: encryptKey,
			layout:     layout,
			mmcd:       mmcd,
			templEn:    engine
		});
		
			/*
			try {
				// Save to cache
				Application.getCache().save(this._options, 'app_options');
			} catch (e:Dynamic) {
				// ...
				trace(e);
			}
		}		
			*/
	}

	private function _getInnerXmlData(name:String, tree:Xml):String
	{
		var content:Xml = tree.elementsNamed(name).next();
		
		if (null == content)
			return null;
		
		var data:String = '';
		for (n in content.iterator()) {
			
			var str:String = n.nodeValue;
			str = StringTools.replace(str, '\t', '');
			str = StringTools.replace(str, '\n', '');
			str = StringTools.replace(str, '\r', '');
			
			if ('' == str) 
				continue;

			if (n.nodeType == Xml.CData) {
				data = str;
				break;
			}
			if (n.nodeType == Xml.PCData) {
				data = str;
			}
		}
		return data;
	}
	
}