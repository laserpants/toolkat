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
package comp;

import neko.FileSystem.FileKind;
import neko.FileSystem.FileStat;

typedef FileStat = 
{
	var gid:Int;
	var uid:Int;
	var atime:Date;
	var mtime:Date;
	var ctime:Date;
	var dev:Int;
	var ino:Int;
	var nlink:Int;
	var rdev:Int;
	var size:Int;
	var mode:Int;
}

typedef FileKind = neko.FileKind;

class FileSystem 
{

	public static inline function exists(path:String):Bool
	{
		return neko.FileSystem.exists(path);
	}
	
	public static inline function readDirectory(path:String):Array<String>
	{
		return neko.FileSystem.readDirectory(path);
	}
	
	public static inline function deleteFile(path:String):Void
	{
		return neko.FileSystem.deleteFile(path);
	}

	public static function stat(path:String):FileStat 
	{
		return neko.FileSystem.stat(path);
	}
	
	public static function kind(path:String):FileKind
	{
		return neko.FileSystem.kind(path);
	}
		
}