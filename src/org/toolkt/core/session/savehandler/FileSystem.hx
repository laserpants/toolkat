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
package org.toolkt.core.session.savehandler;

import comp.FileSystem;
import org.toolkt.core.session.interfaces.ISessionSaveHandler;
import org.toolkt.core.session.SessionNamespace;

/**
 * File system session save handler.
 */
class FileSystem implements ISessionSaveHandler
{

	/**
	 * Time before cookies become available for 
	 * garbage collection (in seconds).
	 */
	private static inline var SESSION_KEEP_TIME = 3600;
	
	/**
	 * Probability divisor used to determine if cleanup-script to run.
	 */
	private static inline var CLEANUP_INTERVAL  = 100;
	
	/**
	 * Path to session storage in local file system.
	 */
	private var _filePath:String;
	
	/**
	 * Set path to session storage.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setFilePath(path:String):ISessionSaveHandler
	{
		this._filePath = path;
		return this;
	}
	
	/**
	 * Get path to session storage.
	 */
	public function getFilePath():String
	{
		if (null == this._filePath) {
			throw "No session storage path specified.";
		}
		return this._filePath;
	}
	
	/**
	 * Constructor
	 * 
	 * @todo
	 */
	public function new(?options:Dynamic):Void
	{
		if (null == options.filePath) {
			throw 'Missing required option \'filePath\' for FileSystem session save handler';
		}
		
		// @todo	Create folder if not existing
		
		this.setFilePath(options.filePath);
	}
	
	public function populate(sessionId:String):Void
	{
		if (!this.exists(sessionId)) {
			throw "No session data";
		}
		
		var file:String = this.getFilePath() + sessionId;
		var str:String;
		
		if (!comp.FileSystem.exists(file)) {
			return;
		}

		var stream:comp.io.FileInput;
		try {
			stream = comp.io.File.read(file, false);
			var data:haxe.io.Bytes = stream.readAll();
			str = data.toString();
		} catch (e:Dynamic) {
			// File i/o error
			return;
		}		
		stream.close();

		// Cleanup old session files
		this._cleanup();
		
		var sessionObject:Hash<Dynamic> = haxe.Unserializer.run(str);
		
		for (key in sessionObject.keys()) {
			var namespace:SessionNamespace = SessionNamespace.get(key);
			var obj:Dynamic = sessionObject.get(key);
			namespace.write(obj);
		}
	}
	
	/**
	 * Determine if session with specified id exists in storage.
	 */
	public function exists(sessionId:String):Bool
	{
		var file:String = this.getFilePath() + sessionId;
		return comp.FileSystem.exists(file);
	}

	/**
	 * Serialize namespace data objects and save to storage.
	 */
	public function save(sessionId:String):Void
	{
		var file:String = this.getFilePath() + sessionId;
		
		var namespaces:Hash<SessionNamespace> = 
			SessionNamespace.getSingleInstances();
			
		var sessionObject:Hash<Dynamic> = new Hash();
		var hasData:Bool = false;
		for (key in namespaces.keys()) {
			var namespace:SessionNamespace = namespaces.get(key);
			
			if (!namespace.storageIsEmpty()) {
				var storage:Dynamic;
				try {
					storage = namespace.read();
					hasData = true;
				} catch (e:org.toolkt.core.session.exceptions.StorageEmptyException) {
					continue;
				}
				sessionObject.set(key, storage);
			}
		}
		
		if (!hasData) {
			// If no file, we're done already
			if (!comp.FileSystem.exists(file))
				return;
			
			try {
				comp.FileSystem.deleteFile(file);
				return;
			} catch (e:Dynamic) {
				// ...
			}
		}

		var str:String = 
			haxe.Serializer.run(sessionObject);
		try {
			var stream:comp.io.FileOutput = 
				comp.io.File.write(file, false);
			var bytes:haxe.io.Bytes = haxe.io.Bytes.ofString(str);

			stream.write(bytes);
			stream.flush();
			stream.close();
			
		} catch (e:Dynamic) {
			// File i/o error
		}
	}
	
	/**
	 * Garbage collect old session files in /data/session/
	 */
	private function _cleanup():Void
	{
		var rand:comp.Random = new comp.Random();
		var i:Int = rand.int(FileSystem.CLEANUP_INTERVAL);
		
		if (1 == i) {			
			
			var files:Array<String> = 
				comp.FileSystem.readDirectory(this.getFilePath());
				
			// Get current time
			var ts:Float = Date.now().getTime();
			for (file in files) {
				
				var fname:String = this.getFilePath() + file;

				if (comp.FileKind.kfile != comp.FileSystem.kind(fname)) {
					continue;
				}

				var filestat:FileStat = comp.FileSystem.stat(fname);				
				var mtime:Float = filestat.mtime.getTime();
				
				// Get the time since file was modified (in ms)
				var interval:Float = ts - mtime;
				
				if (interval > FileSystem.SESSION_KEEP_TIME * 1000) {					
					try {
						comp.FileSystem.deleteFile(fname);
					} catch (e:Dynamic) {
						// File error, write to log?
					}
				}
			}			
		} 
	}
	
}