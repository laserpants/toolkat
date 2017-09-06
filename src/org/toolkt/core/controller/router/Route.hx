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
package org.toolkt.core.controller.router;

import org.toolkt.core.controller.FrontController;
import org.toolkt.core.controller.router.abstract.AbstractRoute;
import org.toolkt.core.helper.QuickHash;
import org.toolkt.core.helper.StrTrim;

class Route extends AbstractRoute
{
	
	private static inline var URL_DELIMITER = '/';	
	private static inline var URL_VARIABLE  = ':';

    /**
     * Holds route patterns for all URL parts.
	 */
	private var _parts:IntHash<String>;
	
	/**
	 * Number of parts in parts hash.
	 */
	private var _partsCount:Int;
	
    /**
     * Holds names of all route's pattern variable names.
	 */
	private var _variables:IntHash<String>;

	/**
     * Holds user submitted default values for route's variables.
	 */
	private var _defaults:Hash<String>;
	
    /**
     * Hash filled on match() that holds wildcard variable names and values.
     */ 
	private var _wildcardData:Hash<String>;

    /**
     * Holds a count of route pattern's static parts for validation
	 */
	private var _staticCount:Int;
	
	/**
	 * Constructor
	 * 
     * Prepares the route for mapping by splitting (exploding) it
     * to corresponding atomic parts. These parts are assigned a
     * position which is later used for matching and preparing values.
	 * 
	 * @todo	Regex
	 */
	public function new(route:String, ?defaults:Dynamic, ?front:FrontController):Void
	{
		super(route);
		this._wildcardData = new Hash<String>();

		var defaultsHash:QuickHash<String> = new QuickHash(defaults);

		this._parts       = new IntHash();
		this._variables   = new IntHash();
		this._staticCount = 0;
		this._defaults    = defaultsHash;
		
		route = StrTrim.trimChar(route, Route.URL_DELIMITER);

		if ('' != route) {
			var parts:Array<String> = route.split(Route.URL_DELIMITER);
			var c:Int = 0;
			this._partsCount = parts.length;
			
			for (part in parts) {
				
				if (part.charAt(0) == Route.URL_VARIABLE) {
					var name:String = part.substr(1);
					this._variables.set(c, name);
					this._parts.set(c, '');				// @todo
				} else {
					this._parts.set(c, part);
					if ('*' != part) {
						this._staticCount++;
					}	
				}
				c++;
			}
		}
	}
	
    /**
     * Matches submitted path with parts defined by a map.
	 * 
	 * @todo	Regex
	 */
	override public function match(path:String):Bool
	{
		path = StrTrim.trimChar(path, Route.URL_DELIMITER);

		var matchedPath:String  = '';
		var parts:Array<String> = path.split(Route.URL_DELIMITER);
		var c:Int               = 0;
		var pathStaticCount:Int = 0;
		var values:Hash<String> = new Hash();
		
		if ('' != path) {
			for (part in parts) {
				
				if (c > this._partsCount) {
					return false;
				}
				matchedPath += part + Route.URL_DELIMITER;
				
				// If it's a wildcard, get the rest of URL as wildcard data and stop matching
				if (this._parts.get(c) == '*') {
					var count:Int = parts.length;
					var i:Int = c;
					while (i < count) {
						var v:String = StringTools.urlDecode(parts[i]);
						if (false == this._wildcardData.exists(v) 
							&& false == this._defaults.exists(v) 
							&& false == values.exists(v)) {
								if (null != parts[i + 1]) {
									this._wildcardData.set(v, StringTools.urlDecode(parts[i + 1]));
								} else {
									this._wildcardData.set(v, null);
								}
							}
						i += 2;
					}
					break;
				}
				
				var name:String = this._variables.get(c);
				
				var decodedPart:String = StringTools.urlDecode(part);
				var patternPart:String = this._parts.get(c);

				// If it's a static part, match directly
				if (null == name && patternPart != decodedPart) {
					return false;
				}

                // @todo: If it's a variable with requirement, 
				// match a regex. If not - everything matches
				
				if (null != name) {
					values.set(name, decodedPart);
				} else {
					pathStaticCount++;	
				}
				c++;
			}
		}

		// Check if all static mappings have been matched
		if (this._staticCount != pathStaticCount) {
			return false;
		}
		
		var result:Hash<String> = this._defaults;
		for (key in values.keys()) {
			var value:String = values.get(key);
			result.set(key, value);
		}
		for (key in this._wildcardData.keys()) {
			var value:String = this._wildcardData.get(key);
			result.set(key, value);
		}
		
		// Check if all map variables have been initialized
		for (v in this._variables) {
			if (false == result.exists(v)) {
				return false;
			}
		}
		
		matchedPath = StrTrim.rtrimChar(matchedPath, Route.URL_DELIMITER);
		this.setMatchedPath(matchedPath)
		    .setMatchedValues(result);
		
		return true;
	}	
	
}