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
package org.toolkt.core.session;

import org.toolkt.core.session.interfaces.ISessionSaveHandler;

enum SaveHandlers
{
	FileSystem;
	Memory;
	Custom;
}

class Session 
{

	/**
	 * Session is started?
	 */
	private static var _isStarted:Bool = false;
	
	/**
	 * Session identifier
	 */
	private static var _id:String;
	
	/**
	 * Save handler
	 */
	private static var _saveHandler:ISessionSaveHandler;
	
	public static function setId(id:String):Void
	{
		Session._id = id;
	}
	
	public static function getId():String
	{
		return Session._id;
	}
	
	public static function setSaveHandler(saveHandler:ISessionSaveHandler):Void
	{
		Session._saveHandler = saveHandler;
	}
	
	/**
	 * @return	Save handler
	 */
	public static function getSaveHandler():ISessionSaveHandler
	{
		return Session._saveHandler;
	}
	
	/**
	 * Constructor. Disabled, use Session.start()
	 */
	private function new():Void
	{
		throw "No instantiation, use Session.start()";
	}
	
	/**
	 * Determine if session is started or not.
	 */
	public static function isStarted():Bool
	{
		return Session._isStarted;
	}
	
	/**
	 * Start session
	 */
	public static function start(name:String):Void
	{
		if (Session.isStarted()) {
			// Session already started
			return;
		}		
		
		if ('' == name) {
			throw "Session name must not be blank.";
		}
		
		Session._isStarted = true;
		
		if (null != Session._id) {
			// Session id has been assigned 'manually'
			try {
				Session.populate();
			} catch (e:Dynamic) {
				Session._id = null;
			}
		}

		var cookies:Hash<String> = comp.Web.getCookies();
		if (true == cookies.exists(name) && null == Session._id) {
			try {
				Session._id = cookies.get(name);
				Session.populate();
				return;
				
			} catch (e:Dynamic) {
				
				// @todo: Write to log ...
			}
		}

		// Set session cookie
		if (null == Session._id) {
			var id:String;
			var i:Int = 0;
			do {
				var rand:comp.Random = new comp.Random();
				var str:String = Std.string(rand.float());
				id = haxe.Md5.encode(str);
				if (i++ > 24) throw "Application error";
			} while (true == Session.getSaveHandler().exists(id));
			Session._id = id;
		}
		comp.Web.setCookie(name, Session._id, null, null, '/');			// ?
	}
	
	/**
	 * Populate namespaces from data in session storage.
	 */
	public static function populate():Void
	{
		Session.getSaveHandler().populate(Session._id);
	}
	
	/**
	 * End (close) session. Serialize namespace storage objects and save.
	 */
	public static function end():Void
	{
		if (!Session.isStarted()) {
			return;
		}		

		Session.getSaveHandler().save(Session._id);
		Session._isStarted = false;
		Session._id = null;
	}
	
	/**
	 * Session save handler factory method
	 * 
	 * @return	ISessionSaveHandler instance
	 * @todo	Custom
	 */
	public static function saveHandlerFactory(saveHandler:SaveHandlers, 
	                                          ?options:Dynamic):ISessionSaveHandler
											  // ?klass:Class = null
	{
		switch (saveHandler) {
			case FileSystem:
				return new org.toolkt.core.session.savehandler.FileSystem(options);
				
			case Memory:
				return new org.toolkt.core.session.savehandler.Memory(options);
			
			case Custom:
				/*
				if (null == klass) {
					throw 'Error';
				}
				 */
				return throw 'Not implemented';
				
			default:
				return throw "Unsupported session save handler.";
		}
	}
	
}