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
package org.toolkt.user.db.table;

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
					CREATE TABLE IF NOT EXISTS user_users (
						name          VARCHAR(255), 
						password_hash VARCHAR(255), 
						password_salt VARCHAR(255), 
						email         VARCHAR(255),
						id            INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
						username      VARCHAR(255))
				');

			case 'Sqlite':
				this._addSql('
					CREATE TABLE user_users (
						name          VARCHAR(255), 
						password_hash VARCHAR(255), 
						password_salt VARCHAR(255), 
						email         VARCHAR(255),
						id            INTEGER PRIMARY KEY, 
						username      VARCHAR(255))
				');
			
			default:
		}

		this._addSql('
			CREATE UNIQUE INDEX 
				idx_user_users_username on user_users (username)
		');

		this._addSql('
			CREATE UNIQUE INDEX 
				idx_user_users_email on user_users (email)
		');
	}
	
}