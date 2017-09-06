﻿/**
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
package org.toolkt.node.db.table;

import org.toolkt.core.db.interfaces.IDbTableSetup;
import org.toolkt.core.db.table.abstract.AbstractTableSetup;

class TableSetup extends AbstractTableSetup,
	implements IDbTableSetup
{
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
	}

	override private function _init():Void
	{
		switch (this.getDbAdapter().getDbType()) {
			
			case 'Mysql':
				this._addSql('
					CREATE TABLE IF NOT EXISTS node_block_content (
						block_uri VARCHAR(255),
						variable  VARCHAR(255),
						content   TEXT)
				');

			case 'Sqlite':
				this._addSql('
					CREATE TABLE node_block_content (
						block_uri VARCHAR(255),
						variable  VARCHAR(255),
						content   TEXT)
				');
			
			default:
		}

		this._addSql('
			CREATE UNIQUE INDEX 
				idx_node_block_content_block_uri_variable on node_block_content (block_uri, variable)
		');
	}
	
}