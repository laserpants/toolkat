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
package org.toolkt.core.cache.storage;

import comp.FileSystem;
import org.toolkt.core.cache.storage.abstract.AbstractCacheStorage;

class CacheFileStorage extends AbstractCacheStorage
{

	/**
	 * Time to keep cache in filesystem before garbage collection (in seconds).
	 */
//	private static inline var FILE_KEEP_TIME   = 1209600;		// problem when compiling on Unix
	
	/**
	 * Probability divisor used to determine if cleanup-script to run.
	 */
	private static inline var CLEANUP_INTERVAL = 100;
	
	/**
	 * Path to cache storage in local file system.
	 */
	private var _filePath:String;
	
	/**
	 * Set file system path.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function setCacheDir(path:String):AbstractCacheStorage
	{
		this._filePath = path;
		return this;
	}

	/**
	 * Constructor
	 * 
	 * @todo
	 */
	public function new(?options:Dynamic):Void
	{
		super();
		
		var filePath:String = options.filePath;
		
		if (null == filePath) {
			throw 'Error, path not set for cache file storage.';
		}
		
		// @todo	Check if folder exists, otherwise create it?
		
		this.setCacheDir(filePath);
	}
	
    /**
     * Return true if cache exists for given id.
	 */
	override public function exists(id:String):Bool
	{
		var file:String = this._filePath + id;
		return comp.FileSystem.exists(file);
	}
	
    /**
     * Return cache for the given id.
	 * Note: Unserialization is done by the front handler.
	 */
	override public function load(id:String):String
	{
		var file:String = this._filePath + id;
		var str:String;
		
		if (!comp.FileSystem.exists(file)) {
			throw new org.toolkt.core.cache.exceptions.CacheFileStorageIoException(
				'File not found');
		}
		
		var stream:comp.io.FileInput;
		try {
			stream = comp.io.File.read(file, false);
			var data:haxe.io.Bytes = stream.readAll();
			str = data.toString();

		} catch (e:Dynamic) {
			// File i/o error
			throw new org.toolkt.core.cache.exceptions.CacheFileStorageIoException(
				'File i/o error');
		}
		stream.close();
		
		return str;
	}

    /**
     * Save string into a cache record.
	 * Note: Serialization is done by the front handler.
     */
	override public function save(data:String, id:String):Void
	{
		var file:String = this._filePath + id;

		try {
			var stream:comp.io.FileOutput = 
				comp.io.File.write(file, false);
			var bytes:haxe.io.Bytes = haxe.io.Bytes.ofString(data);

			stream.write(bytes);
			stream.flush();
			stream.close();

		} catch (e:Dynamic) {
			// File i/o error
			throw new org.toolkt.core.cache.exceptions.CacheFileStorageIoException(
				'File i/o error');
		}
		
		// Cleanup old cache files
		this._cleanup();
	}
	
	/**
	 * Clear cache directory.
	 * 
	 * @todo	Should return true/false depending on success status?
	 */
	override public function clear():Void
	{
		var files:Array<String> = 
			comp.FileSystem.readDirectory(this._filePath);
			
		for (file in files) {
			var fname:String = this._filePath + file;

			if (comp.FileKind.kfile != comp.FileSystem.kind(fname)) {
				continue;
			}			
			try {
				comp.FileSystem.deleteFile(fname);
			} catch (e:Dynamic) {
				// Error, log and continue anyway?
			}
		}
	}
	
	/**
	 * Garbage collect old cache storage files, based on last file access.
	 */
	private function _cleanup():Void
	{
		var rand:comp.Random = new comp.Random();
		var i:Int = rand.int(CacheFileStorage.CLEANUP_INTERVAL);
		
		if (1 == i) {			
			var files:Array<String> = 
				comp.FileSystem.readDirectory(this._filePath);
			
			// Get current time
			var ts:Float = Date.now().getTime();
			for (file in files) {
				
				var fname:String = this._filePath + file;

				if (comp.FileKind.kfile != comp.FileSystem.kind(fname)) {
					continue;
				}
				
				// Get last access (not modification) time
				var filestat:FileStat = comp.FileSystem.stat(fname);
				var atime:Float = filestat.atime.getTime();

				// Get the time since file was accessed (in ms)
				var interval:Float = ts - atime;
				
				var kTime:Int = 1209600;		 //	Int32.toNativeInt(CacheFileStorage.FILE_KEEP_TIME);
				
				if (interval > kTime * 1000) {
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