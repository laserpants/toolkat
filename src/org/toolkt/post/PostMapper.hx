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

//import comp.db.interfaces.IResultSet;
import comp.db.ResultSet;
import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.model.abstract.AbstractDbMapper;
import org.toolkt.core.paginator.interfaces.IPaginatorMapper;
import org.toolkt.post.comment.Comment;

class PostMapper extends AbstractDbMapper<Post>,
	implements IPaginatorMapper<Post>
{
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
	override public function find(post:Post, id:Int):Void
	{
		var sql:String = 
			  "SELECT id, title, content, user_id, created_at, updated_at "
			+ "FROM post_posts " 
			+ "WHERE id = " + id + " "
			+ "LIMIT 1;";
			
		this._find(sql, post);
	}
	
	override public function save(post:Post):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		var sql:String;
		
		var date:String = Date.now().toString();
		
		if (null == post.id) {
			
			// Create new db row
			sql = "INSERT INTO post_posts (title, content, user_id, created_at, updated_at) "
				+ "VALUES ("
				+ "'" + db.escape(post.title)   + "', "
				+ "'" + db.escape(post.content) + "', "
				+ "'" + post.userId             + "', "
				+ "'" + date                    + "', "
				+ "'" + date                    + "'"
				+ ");";
		} else {
			
			// Update existing db row
			sql = "UPDATE post_posts SET "
				+ "title = '"      + db.escape(post.title)    + "', "
				+ "content = '"    + db.escape(post.content)  + "', "
				+ "user_id = '"    + post.userId              + "', "
				+ "updated_at = '" + date                     + "' "
				+ "WHERE id = "    + post.id                  + ";";
		}

		db.request(sql);
		
		if (null != post.id)  return;
		
		var sql:String;
		switch (db.getDbType()) 
		{
			case 'Sqlite':			
				sql = 'SELECT last_insert_rowid() AS id;';
					
			case 'Mysql':
				sql = 'SELECT last_insert_id( ) AS id;';
				
			default:
				throw 'Unsupported database type';
		}
		
		var result:ResultSet = db.request(sql);
		
		if (0 == result.length)  return;

		var rowData:Dynamic = result.next();
		post.id = rowData.id;
	}	
	
	public function delete(post:Post):Void
	{
		var sql:String = 'DELETE FROM post_posts WHERE id = ' + post.id;
		this.getDbAdapter().request(sql);
	}

	/**
	 * @see 	IPaginatorMapper
	 */
	public function fetchRange(offset:Int, limit:Int):Array<Post>
	{
		var sql:String = 'SELECT id, title, content, user_id, created_at, updated_at FROM post_posts '
		               + 'ORDER BY created_at DESC LIMIT ' 
					   + offset + ', ' 
					   + limit  + ';';
		
		return this._fetch(sql);
	}
	
	/**
	 * @see 	IPaginatorMapper
	 */
	public function count():Int
	{
		var sql:String = 'SELECT count(id) AS count FROM post_posts';
		var result:ResultSet = this.getDbAdapter().request(sql);
		return result.next().count;
	}
	
	private function _find(sql:String, post:Post):Void
	{
		var db:AbstractAdapter = this.getDbAdapter();
		var result:ResultSet   = null;
		
		try {
			result = db.request(sql);
			if (1 == result.length) {
				
				var rowData:Dynamic = result.next();
				
				post.id         = rowData.id;
				post.title      = rowData.title;
				post.content    = rowData.content;
				post.userId     = rowData.user_id;
				post.createdAt  = this._getSafeDate(rowData.created_at);
				post.updatedAt  = this._getSafeDate(rowData.updated_at);

				// Everything ok, clean return
				return;	
			}
		} catch (e:Dynamic) {
			// Continue and throw RecordNotFoundException
		}
		throw new org.toolkt.core.db.exceptions.RecordNotFoundException();		
	}

	private function _fetch(sql:String):Array<Post>
	{
		var result:ResultSet = this.getDbAdapter().request(sql);
		var posts:Array<Post> = [];
		
		for (row in result) {
			var post:Post   = new Post();
			post.id         = row.id;
			post.title      = row.title;
			post.content    = row.content;
			post.userId     = row.user_id;
			post.createdAt  = this._getSafeDate(row.created_at);
			post.updatedAt  = this._getSafeDate(row.updated_at);
			
			posts.push(post);
		}
		return posts;
	}
	
}