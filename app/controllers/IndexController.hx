package controllers;

import org.toolkt.core.auth.Auth;
import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.interfaces.IRestController;
import org.toolkt.core.controller.request.abstract.AbstractRequest;

class IndexController extends AbstractController,
	implements IRestController
{

	public function flushAction():Void
	{
		if (true == org.toolkt.core.controller.plugin.FullpageCache.clearData()) {
			this.addFlashMessage('Cache cleared successfully.');
			this._redirect(this.request.getBaseUrl());
		} 
	}
	
	public function indexAction():Void
	{
		this.getNodeHelper().fetchNode('home', this);
		
		this.view.assign({
			loggedIn: Auth.getInstance().hasIdentity(),
			nodeUri:  'home'
		});
		
		this.render('home', {}, true);
	}
	
	public function getAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}

	public function postAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	public function putAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
	public function deleteAction():Void
	{
		// Error 404
		throw new org.toolkt.core.controller.exceptions.InvalidActionException();
	}
	
}