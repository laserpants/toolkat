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

import org.toolkt.core.cache.abstract.AbstractCache;
import org.toolkt.core.cache.front.abstract.AbstractCacheFront;
import org.toolkt.core.controller.FrontController;
import org.toolkt.core.view.interfaces.IView;
import org.toolkt.node.Node;
import org.toolkt.node.NodeBlock;

typedef Block  = Hash<String>;
typedef Region = Array<Block>;

class Nodetree
{

	private static var _cacheFront:AbstractCacheFront;

	private var _xml:Xml;
	
	private var _view:IView;
	
	private var _sitemap:Array<Node>;
	
	private var _nodeXml:Hash<Xml>;

	public static function getCache():AbstractCacheFront
	{
		if (null == Nodetree._cacheFront) {
			Nodetree._cacheFront = AbstractCache.factory(Object, {prefix: 'nodetree'}, {});
		}
		return Nodetree._cacheFront;
	}
	
	/**
	 * @return	Provides a fluent interface
	 */
	public function setView(view:IView):Nodetree
	{
		this._view = view;
		return this;
	}

	/**
	 * @todo
	 */
	public function allowCaching():Bool
	{
		// ...
		
		return true;
	}
	
	/**
	 * @todo	Cache???
	 */
	public function getSitemap():Array<Node>
	{
		if (null == this._sitemap) {
			this._sitemap = this._buildSitemap(this._xml.firstElement());
		}
		return this._sitemap;
	}
	
	/**
	 * Constructor
	 */
	public function new():Void
	{
		this._nodeXml = new Hash<Xml>();
		
//		var cid:String = 'tree_' + haxe.Md5.encode(file);
		var cid:String = 'nodetree_xml';
		try {
			var str:String = Nodetree.getCache().load(cid);
			this._xml = Xml.parse(str);
			
		} catch (e:Dynamic) {
			
			/*
			
			var stream:comp.io.FileInput;
			try {
				stream = comp.io.File.read(file, false);
			} catch (e:Dynamic) {
				// File error
				throw e;
			}
			var data:haxe.io.Bytes = stream.readAll();
			var xmlString:String = data.toString();
			stream.close();
			*/
			
			//

			var xml:Xml = null;
			try {
//				xml = Xml.parse(xmlString);
				xml = Xml.parse(haxe.Resource.getString('nodetree_xml'));
				this._xml = xml;
				
			} catch (e:Dynamic) {
				throw new org.toolkt.node.exceptions.NodeException(
					'Error parsing XML nodetree');
			}
		
			try {
				// Save to cache
				Nodetree.getCache().save(this._xml.toString(), cid);
			} catch (e:Dynamic) {
				// Continue
			}
		}
	}
	
	public function getRegionById(id:String, xml:Xml):Xml
	{
		for (node in xml.elements()) {
			switch (node.nodeName) {				
				case 'node':
					try {
						return this.getRegionById(id, node);
					} catch (e:org.toolkt.node.exceptions.NodeRegionNotFoundException) {
						//
					}
				case 'region':
					if (node.exists('id')) {
						if (id == node.get('id')) {
							return node;
						}
					}
				default:
					//
			}
		}
		throw new org.toolkt.node.exceptions.NodeRegionNotFoundException();
	}

	public function getNodeByUri(uri:String):Xml
	{
		if (null == this._sitemap) {
			this._sitemap = this._buildSitemap(this._xml.firstElement());
		}
		
		if (this._nodeXml.exists(uri)) {
			return this._nodeXml.get(uri);
		}
		
		throw new org.toolkt.node.exceptions.NodeException();
	}
	
	public function fetchNode(uri:String):Hash<Region>
	{
		var root:Xml = this._xml.firstElement();		
		var node:Xml;
		try {
			node = this.getNodeByUri(uri);
		} catch (e:Dynamic) {
			throw e;
		}
		
		var tree:Hash<Region> = this._buildNodeHash(node);
		
		return tree;
	}
	
	public function buildMap(node:Xml, depth:Int, level:Int, 
							 ?pathPrefix = ''):Array<Node>
	{		
		var nodes:Array<Node> = [];
		var usedPaths:Hash<Bool> = new Hash();
		
		for (child in node.elementsNamed('node')) {
			
			var current:Node;
			var title:String = child.get('title');
			var link:String  = child.get('link');
			var	path:String  = this._urlFormat(title);
			var visibility:Visibility 
							 = Visible;
			
			switch (child.get('hidden')) {
				case 'always':
					visibility = Hidden;
					
				case 'auth':
					visibility = NotAuthenticated;
					
				case 'anonymous':
					visibility = Authenticated;
					
				default:
			}
			
			if (null != link) {
				
				current = new Node(
					title, null, visibility, child.get('link'));
				
				for (attr in child.elementsNamed('attribute')) {
					
					if (null == attr.get('name') || null == attr.get('value'))
						continue;
					
					current.attributes.set(attr.get('name'), attr.get('value'));
				}
				
			} else {

				var i:Int = 1;
				while (usedPaths.exists(path)) {
					path = this._urlFormat(title) + '-' + i++;
				}
				usedPaths.set(path, true);

				if ('' != pathPrefix) {
					path = pathPrefix + '/' + path;
				}
				var nodeAction:String = child.get('action');
				
				current = new Node(
					title, path, visibility, nodeAction);
			}
			
			var dashUri:String = StringTools.replace(path, '/', '-');
			this._nodeXml.set(dashUri, child);
				
			if (level < depth) {
				current.nodes = this._buildSitemap(child, depth, level+1, path);
			}
			nodes.push(current);
		}
		return nodes;		
	}
	
	private function _buildSitemap(node:Xml, 
	                               ?depth:Int = 3, 
								   ?level:Int = 1, 
								   ?pathPrefix = ''):Array<Node>
	{		
		return this.buildMap(node, depth, level, pathPrefix);
	}
	
	private function _buildNodeHash(element:Xml):Hash<Region>
	{		
		var tree:Hash<Region> = new Hash();
		
		// Iterate through all <region> elements
		for (node in element.elementsNamed('region')) {
			
			if (!node.exists('pos')) {
				// 'pos' is required attribute for <region>
				throw new org.toolkt.node.exceptions.NodeException(
					'XML error, <region> missing required attribute \'pos\'.');
			}
			var position:String = node.get('pos');	

			var reg:Xml;			
			if (node.exists('ref')) {
				// <region ref=""> attribute refers to id of elsewhere defined region
				try {					
					reg = this.getRegionById(node.get('ref'),
						this._xml.firstElement());

				} catch (e:Dynamic) {
					throw new org.toolkt.node.exceptions.NodeException(
						'XML error, <region> with reference to non-existing region');
				}
			} else {
				reg = node;
			}
			
			var region:Region = this._getBlocks(reg, element.get('id'));			
			tree.set(position, region);
		}
		return tree;
	}
	
	/**
	 * Collects array of blocks.
	 * 
	 * @todo	Generators
	 */
	private function _getBlocks(element:Xml, nodeId:String):Region
	{
		var blocks:Region = new Region();

		// Iterate through all <block> elements
		for (node in element.elementsNamed('block')) {
			
			var title:String = node.get('title');			
			var block:Block  = new Block();
			
			// Iterate through all <content> elements (if any)
			for (content in node.elementsNamed('content')) {

				// Variable key, default is 'content'
				var key:String = 'content';
				if (content.exists('var')) {
					key = content.get('var');
				}

				// Get inner data
				var data:String = '';
				for (n in content.iterator()) {
					
					var str:String = n.nodeValue;
					str = StringTools.replace(str, '\t', '');
					str = StringTools.replace(str, '\n', '');
					str = StringTools.replace(str, '\r', '');
					
					if ('' == str) continue;

					if (n.nodeType == Xml.CData) {
						data = str;
						break;
					}
					if (n.nodeType == Xml.PCData) {
						data = str;
					}
				}
				block.set(key, data);
			}

			if (node.exists('uri')) {
				// Block has 'uri' attribute, content should come from
				// external data source
				
				var uri:String = node.get('uri');
				var nodeBlock:NodeBlock = new NodeBlock(nodeId, uri);				
				var cacheId:String = 'block_' + haxe.Md5.encode(uri);
				
				if (this.allowCaching()) {
					// Attempt loading data from cache	
					try {					
						nodeBlock.content = Nodetree.getCache().load(cacheId);
						nodeBlock.content.keys();		// To check that data is OK

					} catch (e:Dynamic) {
						// No cache hit, load fresh data instead
						nodeBlock = new NodeBlock(nodeId, uri);
						nodeBlock.load();
						
						try {
							// Save to cache
							Nodetree.getCache().save(nodeBlock.content, cacheId);
						} catch (e:Dynamic) {
							// Do nothing, data loaded but not saved to cache
						}
					}
				} else {
					// Caching disabled, always load content
					nodeBlock.load();
				}
				
				for (key in nodeBlock.content.keys()) {
					block.set(key, nodeBlock.content.get(key));
				}
				
			} else if (node.exists('plugin')) {
				
				// Block has 'plugin' attribute, content should come from node plugin
				var plugin:String = node.get('plugin');
				
				// @todo
			}
			
			if (node.exists('template')) {
				block.set('__template', node.get('template'));
			}
			if (node.exists('uri')) {
				block.set('__uri', node.get('uri'));
			}
			
			blocks.push(block);
		}
		return blocks;
	}

	/**
	 * Url-formats string.
	 */
	private function _urlFormat(str:String):String
	{
		str = StringTools.replace(str, ' ', '-');
		
		var regex:EReg = new EReg('[^A-Za-z0-9\\-]', '');
		str = regex.replace(str, '');
		
		return str.toLowerCase();
	}

}