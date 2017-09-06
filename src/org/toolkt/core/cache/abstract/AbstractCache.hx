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
package org.toolkt.core.cache.abstract;

import org.toolkt.core.cache.front.abstract.AbstractCacheFront;
import org.toolkt.core.cache.storage.abstract.AbstractCacheStorage;
import org.toolkt.core.controller.FrontController;

enum CacheFront 
{
	Object;
	Page;
	Custom;
}

enum CacheStorage 
{
	File;
	Memory;
}

/* abstract */ class AbstractCache
{

	/**
	 * Abstract class, no instantiation.
	 */
	private function new():Void
	{
		if (Type.getClass(this) == AbstractCache) {
			throw "Abstract class, no instantiation";
		}
	}
	
	/**
	 * AbstractCacheFront factory method.
	 * 
	 * @todo	Custom
	 */
	public static function factory(frontType:CacheFront, 
								   frontOptions:Dynamic,
								   storageOptions:Dynamic,
								   ?storageType:CacheStorage):AbstractCacheFront
	{
		if (null == storageType) {
			storageType = 
				(true == FrontController.getInstance().getParam('mmcd')) 
					? Memory : File;
		}
		
		// Build storage
		var storage:AbstractCacheStorage;
		
		switch (storageType) {
			case File:
				if (null == storageOptions.filePath) {
					storageOptions.filePath = 
						FrontController.getInstance().getParam('appPath') + 'data/cache/';
				}
				storage = new org.toolkt.core.cache.storage.CacheFileStorage(storageOptions);

			case Memory:
				storage = new org.toolkt.core.cache.storage.CacheMemoryStorage(storageOptions);
				
			default:
				throw "Invalid cache storage.";
		}
				
		// Build front
		var front:AbstractCacheFront;

		switch (frontType) {
			case Object:
				front = new org.toolkt.core.cache.front.Object(frontOptions);
			
			case Page:
				front = new org.toolkt.core.cache.front.Page(frontOptions);
				
			case Custom:
				// @todo
				throw "Not implemented";
				
			default:
				throw "Invalid cache front.";
		}
		
		front.setStorage(storage);
		return front;
	}
	
}