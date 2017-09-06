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
package org.toolkt.post;

import org.toolkt.core.model.abstract.AbstractModel;
import org.toolkt.core.paginator.Paginator;
import org.toolkt.post.abstract.AbstractPost;
import org.toolkt.post.comment.Comment;
import org.toolkt.post.PostMapper;

class Post extends AbstractPost<PostMapper>
{

	public var comments:Array<Comment>;
	public var commentsCount:Int;
	
	/**
	 * Get data mapper. Lazy-load default PostMapper if null.
	 */
	override public function getMapper():PostMapper
	{
		if (null == this._mapper) {
			this._mapper = new PostMapper();
		}
		return this._mapper;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
		
		this.comments = [];
		this.commentsCount = 0;
	}

	public static function fetchAll():Array<Post>
	{
		var t:Post = new Post();
		return t.getMapper().fetchAll();
	}
	
	public static function paginateAll():Paginator<Post>
	{
		var t:Post = new Post();
		return new Paginator<Post>(t.getMapper());
	}
	
	/**
	 * Delete post.
	 */
	override public function delete():Void
	{
		this.getMapper().delete(this);
	}
	
	/**
	 * Load model with data from resource corresponding to supplied id.
	 */
	override public function find(id:Int):Void
	{
		this.getMapper().find(this, id);
		
		// Data was successfully loaded
		this._loaded = true;
	}
	
	/**
	 * Save the post.
	 */
	override public function save():Void
	{
		this.getMapper().save(this);
	}
	
	/**
	 * Fetch comments for post.
	 */
	public function fetchComments():Void
	{
		if (!this.isLoaded()) {
			return;
		}
		
		this.comments      = Comment.fetchForPost(this.id);
		this.commentsCount = Comment.countForPost(this.id);
	}
	
}