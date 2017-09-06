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
package org.toolkt.post.comment;

import org.toolkt.core.model.abstract.AbstractModel;
import org.toolkt.post.comment.CommentMapper;
import org.toolkt.post.Post;

class Comment extends AbstractModel<CommentMapper>
{

	public var id:Int;
	public var email:String;
	public var content:String;
	public var postId:Int;
	public var createdAt:String;
	public var updatedAt:String;

	/**
	 * Get data mapper. Lazy-load default CommentMapper if null.
	 */
	override public function getMapper():CommentMapper
	{
		if (null == this._mapper) {
			this._mapper = new org.toolkt.post.comment.CommentMapper();
		}
		return this._mapper;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
	/**
	 * Fetch comments for array of posts.
	 */
	public static function fetchForPosts(posts:Array<Post>, ?limit:Int):Void
	{
		var t:Comment = new Comment();
		t.getMapper().fetchForPosts(posts, limit);
	}

	/**
	 * Fetch comments for single post.
	 */
	public static function fetchForPost(postId:Int):Array<Comment>
	{
		var t:Comment = new Comment();
		return t.getMapper().fetchForPost(postId);
	}
	
	public static function countForPost(postId:Int):Int
	{
		var t:Comment = new Comment();
		return t.getMapper().countForPost(postId);
	}
	
	/**
	 * Load model with data from resource corresponding to supplied id.
	 */
	public function find(id:Int):Void
	{
		this.getMapper().find(this, id);
		
		// Data was successfully loaded
		this._loaded = true;
	}
	
	/**
	 * Save the comment.
	 */
	public function save():Void
	{
		this.getMapper().save(this);
	}
	
}