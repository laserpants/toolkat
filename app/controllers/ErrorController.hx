package controllers;

import org.toolkt.core.controller.abstract.AbstractController;
import org.toolkt.core.controller.plugin.ErrorHandler;
import org.toolkt.core.controller.request.abstract.AbstractRequest;

class ErrorController extends AbstractController
{

	public function indexAction():Void
	{
		var errorClass:String   = this.request.getParam('errorClass');
		var errorMessage:String = this.request.getParam('errorMsg');
		var errorSource:String  = this.request.getParam('errorSrc');
		
		this.view.assign({
			exception: errorClass,
			message:   errorMessage,
			source:    errorSource
		});

		switch (errorClass) 
		{
			case 'org.toolkt.core.controller.exceptions.InvalidControllerException', 
			     'org.toolkt.core.controller.exceptions.InvalidActionException',
				 'org.toolkt.core.controller.exceptions.IdentityNotFoundException':
				 
				// Error 404 -- page not found
				this.render('error/404', {}, true);
				return;
				
			default:
				// General error, render error/index
		}
		
		// This will output detailed error information
		this.render('error/details', {}, true);
	}
	
}