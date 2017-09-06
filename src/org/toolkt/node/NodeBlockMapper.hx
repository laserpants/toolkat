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
package org.toolkt.node;

//import comp.db.interfaces.IResultSet;
import comp.db.ResultSet;
import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.model.abstract.AbstractDbMapper;
import org.toolkt.node.interfaces.INodeBlockMapper;
import org.toolkt.node.NodeBlock;

class NodeBlockMapper extends AbstractDbMapper<NodeBlock>,
	implements INodeBlockMapper
{

	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}
	
	/**
	 * Save node block.
	 * 
	 * @todo	Optimize query for MySQL
	 */
	override public function save(block:NodeBlock):Void
	{
		if (null == block.uri) {
			throw new org.toolkt.node.exceptions.NodeException(
				'Block uri is not set');
		}
		
		var uri:String  = block.uri;
		var db:AbstractAdapter = this.getDbAdapter();

		/*
		switch (db.getDbType()) 
		{
			case 'Sqlite':			
					
			case 'Mysql':
			
		// INSERT INTO node_block_content (block_uri, variable, content) 
		// VALUES ('asdf', 'content', 'asdfasdf') 
		// ON DUPLICATE KEY UPDATE variable = 'asdfasdf';
				
			default:
				throw 'n/i';
		}
		*/
		
		for (key in block.content.keys()) {
			var value:String = block.content.get(key);
			
			var insert:String = 'INSERT INTO node_block_content (block_uri, variable, content) '
							  + 'VALUES (\''
							  + block.uri
							  + '\', \''
							  + key
							  + '\', \''
							  + db.escape(value)
							  + '\')';
							  
			var update:String = 'UPDATE node_block_content SET content = \''
			                  + db.escape(value)
							  + '\' '
							  + 'WHERE block_uri = \''
							  + block.uri
							  + '\' '
							  + ' AND variable = \''
							  + key
							  + '\'';
			
			try {
				db.request(insert);
			} catch (e:Dynamic) {
				db.request(update);
			}
		}
	}
	
	/**
	 * Load content vars from data source for block uri and
	 * assign to block content hash.
	 */
	public function load(block:NodeBlock):Void
	{
		if (null == block.uri) {
			throw new org.toolkt.node.exceptions.NodeException(
				'Block uri is not set');
		}
		
		var uri:String  = block.uri;
		var db:AbstractAdapter = this.getDbAdapter();

		var sql:String = "SELECT block_uri, variable, content "
		               + "FROM node_block_content "
					   + "WHERE block_uri = '" 
					   + uri
					   + "';";
		
		var result:ResultSet = db.request(sql);
		
		if (0 == result.length)  return;
		
		for (row in result) {
			block.content.set(row.variable, row.content);
		}
	}
	
}