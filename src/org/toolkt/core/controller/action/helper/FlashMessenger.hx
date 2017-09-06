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
package org.toolkt.core.controller.action.helper;

import org.toolkt.core.controller.action.helper.abstract.AbstractHelper;
import org.toolkt.core.session.SessionNamespace;

typedef MessageEnvelope = Hash<Array<String>>;

class FlashMessenger extends AbstractHelper
{

	private static inline var SESSION_NS = '__flash';

    /**
     * Messages from previous request, in the format:
	 * 		namespace => [message, message]
     */
	private static var _messages:MessageEnvelope = new Hash();

	/**
	 * Session namespace obj. that stores the FlashMessenger messages.
	 */
	private static var _session:SessionNamespace;

	/**
	 * Instance name identifier.
	 */
	private var _namespace:String;
	
	/**
	 * Messages have been added to current namespace within this request?
	 */
	private var _hasCurrentMessages:Bool;

	/**
	 * Constructor
	 */
	public function new():Void
	{
		super();

		this._namespace = 'default';
		this._hasCurrentMessages = false;
		
		if (null == FlashMessenger._session) {
			FlashMessenger._session = SessionNamespace.get(FlashMessenger.SESSION_NS);
			
			var ns:SessionNamespace = FlashMessenger._session;
			var envelope:MessageEnvelope = new MessageEnvelope();

			if (!ns.storageIsEmpty()) {
				envelope = ns.read();
			}

			for (key in envelope.keys()) {
				var messages:Array<String> = envelope.get(key);
				FlashMessenger._messages.set(key, messages);
			}
			ns.clear();
		}
	}

	/**
	 * Add a message to FlashMessenger namespace.
	 * 
	 * @return	Provides a fluent interface
	 */
	public function addMessage(message:String):FlashMessenger
	{
		var ns:SessionNamespace = FlashMessenger._session;
		var messageHash:MessageEnvelope = new MessageEnvelope();
		
		if (!ns.storageIsEmpty()) {
			messageHash = ns.read();
		}
		var messageArray:Array<String> = messageHash.get(this._namespace);

		if (null == messageArray) {
			messageArray = [];
		}

		messageArray.push(message);
		messageHash.set(this._namespace, messageArray);

		ns.write(messageHash);
		
		this._hasCurrentMessages = true;
		return this;
	}

	/**
	 * Wether a specific namespace has messages.
	 */
	public function hasMessages():Bool
	{
		if (!FlashMessenger._messages.exists(this._namespace)) {
			return false;
		}

		return (FlashMessenger._messages.get(this._namespace).length != 0);
	}

	/**
	 * Get messages from a specific namespace.
	 */
	public function getMessages():Array<String>
	{	
		if (this.hasMessages()) {
			return FlashMessenger._messages.get(this._namespace);
		}
		
		return [];
	}
	
	/**
	 * Wether messages have been added to current
     * namespace within this request.
	 */
	public function hasCurrentMessages():Bool
	{
		return this._hasCurrentMessages;
	}
	
	/**
	 * Get messages from current request and then unset
	 * namespace. 
	 */
	public function flushCurrent():Array<String>
	{
		return this.getCurrentMessages(true);
	}
	
	/**
	 * Get messages that have been added to the current
     * namespace within this request.
	 */
	public function getCurrentMessages(?unsetNamespace = false):Array<String>
	{
		if (!this.hasCurrentMessages()) {
			return [];
		}

		var ns:SessionNamespace = FlashMessenger._session;
		var messageHash:MessageEnvelope = new MessageEnvelope();
		
		if (!ns.storageIsEmpty()) {
			messageHash = ns.read();
		}
		if (!messageHash.exists(this._namespace)) {
			return [];
		}		
		
		var messages:Array<String> = messageHash.get(this._namespace);
		var a:Array<String> = [];
		
		for (message in messages.iterator()) {
			a.push(message);
		}
		
		if (true == unsetNamespace) {
			messages = [];
			messageHash.set(this._namespace, messages);

			ns.write(messageHash);
		}
		return a;
	}			

}