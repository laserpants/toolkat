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
package org.toolkt.node.controller.action.helper;

import org.toolkt.core.auth.AuthResult;
import org.toolkt.core.controller.action.abstract.AbstractActionController;
import org.toolkt.core.controller.action.helper.abstract.AbstractHelper;
import org.toolkt.core.controller.action.helper.HelperBroker;
import org.toolkt.core.controller.action.helper.ViewRenderer;
import org.toolkt.core.controller.interfaces.IActionController;
import org.toolkt.core.controller.interfaces.IRequestHttp;
import org.toolkt.core.controller.request.abstract.AbstractRequestHttp;
import org.toolkt.core.helper.QuickHash;
import org.toolkt.core.helper.StrTrim;
import org.toolkt.core.view.interfaces.IView;
import org.toolkt.node.Node;
import org.toolkt.node.Nodetree;

class NodeHelper extends AbstractHelper
{

	private var _nodetree:Nodetree;
	
	/**
	 * View instance
	 */
	private var _view:IView;
	
	private var _baseUrl:String;
	
	private var _pathInfo:String;
	
	private var _controller:IActionController<Dynamic, Dynamic>;
	
	private var _renderWrappers:Bool;
	
	private var _blockWrapper:String;
	
	private var _wrapperForm:org.toolkt.core.form.Form;
	
	private var _uriVars:Hash<String>;
	
	private var _nodeUri:String;
	
	public function setRenderWrappers(flag:Bool):NodeHelper
	{
		this._renderWrappers = flag;
		return this;
	}
	
	public function setBlockWrapper(template:String):NodeHelper
	{
		this._blockWrapper = template;
		return this;
	}
	
	public function setWrapperForm(form:org.toolkt.core.form.Form):NodeHelper
	{
		this._wrapperForm = form;
		return this;
	}
	
	/**
	 * Set view instance
	 * 
	 * @return Provides a fluent interface
	 */
	public function setView(view:IView):NodeHelper
	{
		this._view = view;
		return this;
	}
	
	override public function setActionController(controller:IActionController<Dynamic, Dynamic>):AbstractHelper
	{
		this._actionController = controller;
		return this;
	}
	
	public function getView():IView
	{
		if (null == this._view) {
//			var controller:AbstractActionController<Dynamic, Dynamic> = 
//				cast(this.getActionController(), AbstractActionController<Dynamic, Dynamic>);

			this._view = this.getActionController().initView();
		}
		return this._view;
	}
	
	public function getNodetree():Nodetree
	{
		if (null == this._nodetree) {
			var view:IView = this.getView();
			
			var nodetree:Nodetree = new Nodetree();			
			nodetree.setView(view);
			this._nodetree = nodetree;
		}
		
		return this._nodetree;
	}
	
	public function setUriVar(key:String, value:String):NodeHelper
	{
		this._uriVars.set(key, value);
		return this;
	}

	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();
		
		this._renderWrappers = false;
		this._uriVars = new Hash();
	}

	override public function preDispatch():Void
	{
		var request:AbstractRequestHttp;
		try {
			request = cast(this.getActionController()
			                   .getRequest(), AbstractRequestHttp);
		} catch (e:Dynamic) {
			throw 'NodeHelper expects instance of AbstractRequestHttp.';
		}
		
		if (request.isAjaxRequest())
			return;

		if (org.toolkt.core.auth.Auth.getInstance().hasIdentity()) {
			var identity:AuthIdentity = 
				org.toolkt.core.auth.Auth.getInstance().getIdentity();
			this.setUriVar('user', Std.string(identity.id));
		}
			
		
		// Build node menu and assign to view
		this.buildNodeMenu(request.getBaseUrl(), 
		                   request.getPathInfo(), 
						   this.getView(), 
						   1);
	}
	
	public function buildNodeMenu(baseUrl:String, 
	                              path:String, 
								  view:IView, 
								  ?levels:Int = null):Void
	{
		this._baseUrl  = baseUrl;
		this._view     = view;
		this._pathInfo = baseUrl + path;
		
		var menu:String = this._buildMenuMap(this.getNodetree().getSitemap(), levels);
		
		this._view.assignVar('nodeMenu', menu);
	}
	
	public function transformNodeUri(request:IRequestHttp):Void
	{
		var uri:String = request.getPathInfo();
		
		var paramCount:Int = 0;
		for (param in request.getParams()) {
			paramCount++;
		}
		
		// Translate e.g. /node/do/some/stuff to do-some-stuff
		if (paramCount > 3 && request.getAction() == 'index') {

			if (StringTools.startsWith(uri, '/node/')) {
				uri = uri.substr(6);
			}
			var parts:Array<String> = uri.split('?');			
			uri = StringTools.replace(parts[0], '/', '-');			

			request.setParam('id', uri)
				   .action = 'get';			
		}
	}
	
	public function fetchNode(nodeUri:String, controller:IActionController<Dynamic, Dynamic>):Void
	{
		if (null == nodeUri) {
			nodeUri = '';
		}
		
		this._controller = controller;
		this._nodeUri    = nodeUri;
		
		var view:IView = this.getView();
				
		var node:Hash<Region>;
		try {
			node = this.getNodetree().fetchNode(nodeUri);

			// Create sandbox storage for view variables, to restore after _assignNodeData call
			var sandbox:Dynamic = view.getVars();
			
			this._assignNodeData(node);
			view.assign(sandbox);
			
		} catch (e:org.toolkt.node.exceptions.NodeException) {
			
			// Node not found
			throw new org.toolkt.core.controller.exceptions.InvalidActionException();
		} 
		
		this._injectScriptTemplate();
	}
	
	public function _injectScriptTemplate():Void
	{
		if (null == this._nodeUri)
			return;
			
		var xml:Xml = this.getNodetree().getNodeByUri(this._nodeUri);
		var template:String = xml.get('template');
		if (null != template) {
			
			//var action:String = this.getActionController().getRequest().getAction();
			//this.getActionController().getRequest().action = template;
			
			if (HelperBroker.hasHelper('ViewRenderer')) {
				var viewRenderer:ViewRenderer = 
					cast(HelperBroker.getStaticHelper('ViewRenderer'), ViewRenderer);
					
				viewRenderer.setScript('node/' + template);
			}
		} 
	}

	private function _assignNodeData(node:Hash<Region>):NodeHelper
	{
		var layoutHtml:Hash<String> = new Hash();
		// Iterate all regions
		for (regionKey in node.keys()) {
			
			var region:Region = node.get(regionKey);
			var regionHtml:String = '';
			
			// Retrieve all blocks
			for (block in region) {
				
//				this.getView().clearVars();
				/*
				var vars:Dynamic = this.getView().getVars();
				this.getView().clearVars();
				this.getView().assignVar('baseUrl', vars.baseUrl);
				*/
				
				var template:String = block.get('__template');
				var uri:String      = block.get('__uri');
						
				block.remove('__template');
				block.remove('__uri');
					
				var html:String;
				if (null != template ) {
					// Iterate block vars
					for (blockVarKey in block.keys()) {
						
						var blockVar:String = block.get(blockVarKey);

						// Authenticated?
						if (true == this._renderWrappers 
							&& null != this._blockWrapper 
							&& null != uri) 
						{
							this.getView().assign( {
								block:  blockVar,
								key:    blockVarKey,
								uri:    uri,
								region: regionKey,
								form:   this._wrapperForm,
								helper: this.getView().getHelperBroker()
							});
							blockVar = this._controller.renderToStr(this._blockWrapper);
						}

						this.getView().assignVar(blockVarKey, blockVar);
					}
					html = this._controller.renderToStr(template);
				} else {
					
					// No template specified, only output raw data from 'content'
					html = block.exists('content') ? block.get('content') : '';
					
					// Authenticated?
					if (true == this._renderWrappers 
						&& null != this._blockWrapper 
						&& null != uri) 
					{
						this.getView().assign({
							block:  html,
							key:    'content',
							uri:    uri,
							region: regionKey,
							form:   this._wrapperForm,
							helper: this.getView().getHelperBroker()
						});
						html = this._controller.renderToStr(this._blockWrapper);
					}
				}
				
				// Replace {{key}} with value of corresponding view variable
				// e.g., {{baseUrl}} will be parsed as /baseurl/ in template
				var hash:QuickHash<Dynamic> = new QuickHash<Dynamic>(this._view.getVars());
				for (key in hash.keys()) {
					var val:Dynamic = hash.get(key);
					html = StringTools.replace(html, '{{' + key + '}}', val);
				}
				
				regionHtml += html;
			}
			layoutHtml.set(regionKey, regionHtml);				
		}
		
		this.getView().clearVars();
		for (regionKey in layoutHtml.keys()) {
			this.getView().assignVar(regionKey, layoutHtml.get(regionKey));
		}
		return this;
	}
		
	private function _buildMenuMap(map:Array<Node>, ?levels:Int, ?currentLevel:Int = 1):String
	{
		if (null == this._baseUrl) {
			throw "Error, missing baseUrl";
		}
		
		if (0 == map.length) {
			return '';
		}
		
		var menu:String = '<ul id="node-menu">';
		for (node in map) {
			
			if (node.visibility == Hidden)
				continue;
			
			if (org.toolkt.core.auth.Auth.getInstance().hasIdentity()) {
				if (node.visibility == NotAuthenticated)
					continue;
			} else {
				if (node.visibility == Authenticated)
					continue;
			}
			
			var url:String = this._baseUrl;
			if (null != node.action) {
				url += '/' + node.action;
			} else if (node.uri != 'home') {
				url += '/node/' +  node.uri; 
			}
			
			for (key in this._uriVars.keys()) {
				var val:String = this._uriVars.get(key);
				url = StringTools.replace(url, ':' + key, val);
			}
			
			var klasses:String = '';
			/*
			if (StrTrim.trimChar(url, '/') == 
				StrTrim.trimChar(this._pathInfo, '/')) {
				klasses = 'current ';
			}
			*/
			
			var s:String = this._getUriPart(url);
			var p:String = this._getUriPart(this._pathInfo);

			if (s.length > 0) {
				if (p.substr(0, s.length) == s) {
					klasses = 'current ';
				}
			}
			
			var rel:String = '';
			var onclick:String = '';
			for (attrKey in node.attributes.keys()) {
				var attr:String = node.attributes.get(attrKey);
				switch (attrKey) {
					case 'method':
						rel = 'rel="' + attr + '" ';
						onclick = 'onclick="return false;" ';
					
					case 'class':
						klasses += attr + ' ';
						
					default:
				}
			}
			klasses = StringTools.trim(klasses);
			var klass:String = '';
			if ('' != klasses) {
				klass = 'class="' + klasses + '" ';
			}
			
			if ('' == url)
				url = '/';
			
			menu += '<li ' 
			     +  klass
				 +  '><a ' 
				 +  rel 
				 +  onclick
				 +  'href="' 
			     +  url
				 +  '">' 
				 +  node.title + '</a>';
			if (null == levels || currentLevel < levels) {
				menu += this._buildMenuMap(node.nodes, levels, currentLevel+1);
			}
			menu += '</li>';
		}
		menu += '</ul>';
		return menu;
	}
	
	private function _getUriPart(str:String):String
	{
		return StrTrim.trimChar(str, '/')
			          .substr(this._baseUrl.length) + '/';
	}
	
}