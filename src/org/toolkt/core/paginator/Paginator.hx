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
package org.toolkt.core.paginator;

import org.toolkt.core.paginator.interfaces.IPaginatorMapper;

class Paginator<T>
{
	
	private static inline var DEFAULT_ITEM_COUNT_PER_PAGE = 10;
	
	private var _count:Int;
	
	private var _currentPage:Int;
	
	private var _itemCountPerPage:Int;
	
	private var _pageCount:Int;
	
	private var _mapper:IPaginatorMapper<T>;

	public function setCurrentPage(page:Int):Paginator<T>
	{
		this._currentPage = page;
		return this;
	}
	
	public function getCurrentPage():Int
	{
		if (null == this._currentPage) {
			this._currentPage = 1;
		}
		return this._currentPage;
	}

	public function setItemCountPerPage(count:Int):Paginator<T>
	{
		this._itemCountPerPage = count;
		this._pageCount        = Math.ceil(this._count/count);
		
		return this;
	}

	public function getItemCountPerPage():Int
	{
		if (null == this._itemCountPerPage) {
			this._itemCountPerPage = Paginator.DEFAULT_ITEM_COUNT_PER_PAGE;
		}
		return this._itemCountPerPage;
	}
	
	public function getMapper():IPaginatorMapper<T>
	{
		return this._mapper;
	}
	
	/**
	 * Constructor
	 */
	public function new(mapper:IPaginatorMapper<T>):Void
	{		
		this._mapper = mapper;
		this._count  = mapper.count();
	}

	public function fetchItems():Array<T>
	{
		var itemCount:Int = this.getItemCountPerPage();
		var offset:Int    = itemCount * (this.getCurrentPage()-1);
		
		return this.getMapper().fetchRange(offset, itemCount);
	}
	
	public function getPages(uri:String):String
	{
		var str:String = '';
		var i:Int = 0;
		
		if (this._pageCount > 1) {
			str += '<ul>';
			
			if (this._currentPage != 1) {
				
				var p:Int = this._currentPage-1;
				var u:String = uri;
				if (p != 1) {
					u = u + '/page/' + p;
				}
				str += '<li><a href="' 
				    +  u 
					+  '">Previous page</li>';				
			}
			
			while (i++ < this._pageCount) {
				
				if (i == this._currentPage) {
					str += '<li><span>' + i + '</span></li>';
				} else if (i == 1) {
					str += '<li><a href="' 
					    +  uri + '">' + i
						+  '</a></li>';
				} else {
					str += '<li><a href="' 
					    +  uri + '/page/' 
						+  i + '">' + i 
						+  '</a></li>';
				}
			}
			
			if (this._currentPage != this._pageCount) {
				str += '<li><a href="' 
				    +  uri + '/page/' 
					+  Std.string(this._currentPage+1) 
					+  '">Next page</a></li>';
			}
			
			str += '</ul>';
		}
		
		return str;
	}
	
}