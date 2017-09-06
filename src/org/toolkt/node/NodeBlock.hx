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

import org.toolkt.core.model.abstract.AbstractModel;
import org.toolkt.node.interfaces.INodeBlockMapper;

class NodeBlock extends AbstractModel<INodeBlockMapper>
{

	public var uri:String;
	
	public var content:Hash<String>;
	
	public var nodeId:String;
		
	override public function getMapper():INodeBlockMapper
	{
		if (null == this._mapper) {
			this._mapper = new org.toolkt.node.NodeBlockMapper();
		}
		return this._mapper;
	}
	
	public function new(nodeId:String, uri:String):Void
	{
		this.content = new Hash<String>();
		this.nodeId  = nodeId;
		this.uri     = uri;
		
		super();
	}

	public function assign(key:String, data:String):NodeBlock
	{
		this.content.set(key, data);
		return this;
	}
	
	public function save():Void
	{
		this.getMapper().save(this);
	}
	
	public function load():NodeBlock
	{
		this.getMapper().load(this);
		this._loaded = true;
		return this;
	}
	
}