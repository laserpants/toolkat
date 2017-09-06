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

//import comp.db.interfaces.IResultSet;
import comp.db.ResultSet;
import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.model.abstract.AbstractDbMapper;
import org.toolkt.post.Post;

class CommentMapper extends AbstractDbMapper<Comment>
{

	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
	override public function save(comment:Comment):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		var sql:String;
		
		var date:String = Date.now().toString();
		
		if (null == comment.id) {
			
			// Create new db row
			sql = "INSERT INTO post_comments (email, content, post_id, created_at, updated_at) "
				+ "VALUES ("
				+ "'" + comment.email    + "', "
				+ "'" + comment.content  + "', "
				+ "'" + comment.postId   + "', "
				+ "'" + date             + "', "
				+ "'" + date             + "'"
				+ ");";
		} else {
			
			// Update existing db row
			sql = "UPDATE post_comments SET "
				+ "email = '"      + comment.email   + "', "
				+ "content = '"    + comment.content + "', "
				+ "post_id = '"    + comment.postId  + "', "
				+ "updated_at = '" + date            + "' "
				+ "WHERE id = "    + comment.id      + ";";
		}

		db.request(sql);
		
		if (null != comment.id)  return;
		
		var sql:String;
		switch (db.getDbType()) 
		{
			case 'Sqlite':			
				sql = 'SELECT last_insert_rowid() AS id;';
					
			case 'Mysql':
				sql = 'SELECT last_insert_id( ) AS id;';
				
			default:
				throw 'n/i';	// ?
		}
		
		var result:ResultSet = db.request(sql);
		
		if (0 == result.length)  return;

		var rowData:Dynamic = result.next();
		comment.id = rowData.id;
	}		
	
	/**
	 * Fetch comments for array of posts.
	 */
	public function fetchForPosts(posts:Array<Post>, limit:Int):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		
		switch (db.getDbType()) 
		{
			case 'Sqlite':			
					
				for (post in posts) {
					
					var sql:String = 'SELECT id, email, content, post_id, created_at, updated_at '
								   + 'FROM post_comments WHERE post_id = ' + post.id + ' '
								   + 'ORDER BY created_at DESC';
					
					if (null != limit) {
						sql += ' LIMIT 0, ' + limit;
					}
					sql += ';';
								   
					post.comments = this._fetch(sql);
				}
			
			case 'Mysql':
			
				var ids:String = '';
				var postHash:IntHash<Post> = new IntHash();
				
				if (0 == posts.length)
					return;
				
				for (post in posts) {
					ids += post.id + ',';
					post.comments = [];
					postHash.set(post.id, post);
				}
				ids = org.toolkt.core.helper.StrTrim.rtrimChar(ids, ',');
			
					var sql:String = 'SELECT id, email, content, post_id, created_at, updated_at '
						           + 'FROM post_comments AS c '
						           + 'WHERE c.post_id '
						           + 'IN (' + ids + ')';
								   
					if (null != limit) {
						
						sql += ' '
						    +  'AND ( '
							+  'SELECT count( x.id ) '
							+  'FROM post_comments AS x '
							+  'WHERE x.post_id = c.post_id '		
							+  'AND x.created_at > c.created_at '
						    +  ') < ' + limit;
					}
					sql     += ' ORDER BY c.created_at DESC;';
					
					var comments:Array<Comment> = this._fetch(sql);
					for (comment in comments) {
						var post:Post = postHash.get(comment.postId);
						if (null != post)
							post.comments.push(comment);
					}
			
			default:
				throw 'n/i';	// ?
		}
		
		// Set comments count
		for (post in posts) {
			post.commentsCount = this.countForPost(post.id);
		}
	}
	
	/**
	 * Fetch comments for single post.
	 */
	public function fetchForPost(postId:Int):Array<Comment>
	{
		var sql:String = 'SELECT id, email, content, post_id, created_at, updated_at '
		               + 'FROM post_comments WHERE post_id = ' 
					   + postId 
					   + ' ORDER BY created_at DESC;';
		
		return this._fetch(sql);
	}
	
	/**
	 * @return	Total number of comments for single post.
	 */
	public function countForPost(postId:Int):Int
	{
		var sql:String = 'SELECT count(id) AS count FROM post_comments WHERE post_id = ' + postId + ';';
		var result:ResultSet = this.getDbAdapter().request(sql);
		return result.next().count;
	}
	
	private function _fetch(sql:String):Array<Comment>
	{
		var result:ResultSet = this.getDbAdapter().request(sql);
		var comments:Array<Comment> = [];
		
		for (row in result) {
			var comment:Comment = new Comment();
			comment.id          = row.id;
			comment.email       = row.email;
			comment.content     = row.content;
			comment.postId      = row.post_id;
			comment.createdAt   = this._getSafeDate(row.created_at);
			comment.updatedAt   = this._getSafeDate(row.updated_at);
			
			comments.push(comment);
		}
		return comments;
	}
	
}