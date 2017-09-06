package;

import org.toolkt.core.application.Application;
import org.toolkt.core.application.bootstrap.StandardBootstrap;
import org.toolkt.core.controller.FrontController;
import org.toolkt.core.controller.interfaces.IRoute;
import org.toolkt.core.controller.interfaces.IRouterHttp;
import org.toolkt.core.controller.router.RewriteRouter;
import org.toolkt.core.controller.router.Route;
import org.toolkt.core.controller.router.rest.RestRoute;
import org.toolkt.core.controller.plugin.abstract.AbstractPlugin;
import org.toolkt.core.db.Db;
import org.toolkt.core.helper.QuickHash;

class Bootstrap extends StandardBootstrap
{
	
	public function new(app:Application):Void
	{
		super(app);
	}

	override private function _initPlugins():StandardBootstrap
	{
		super._initPlugins();
		
		// The following lines enables the FullpageCache plugin
		var plugin:AbstractPlugin = new org.toolkt.core.controller.plugin.FullpageCache(
			new QuickHash({
				actions: new QuickHash({
				//  controller | actions, or [] for all
					index:	     [],
					node:        [],
					session:     [],
					user:        []
				})
			})
		);
//		FrontController.getInstance().registerPlugin(plugin);

		return this;
	}

	override private function _initRoutes():StandardBootstrap
	{
		var frontController:FrontController = FrontController.getInstance();
		var router:IRouterHttp = frontController.getRouter();

		// Add REST-route ----------------------------------------------------
		var route:RestRoute = new RestRoute(frontController);		

		// Register RESTful controllers --------------------------------------
		var restful:Hash<Array<String>> = new Hash();
		restful.set('default', ['node', 'index', 'session', 'user', 'post', 'comment']);
		route.setRestfulControllers(restful);

		router.addRoute('rest', route);
		
		// Add a route -------------------------------------------------------
		var route:IRoute = new Route('cache/clear', 
			{controller: 'index', 
		     action:     'flush'});
		router.addRoute('flush', route);

		// Add login route ---------------------------------------------------
		var route:IRoute = new Route('login', {
			module:     'default',
			controller: 'session',
			action:     'new'
		});
		router.addRoute('login', route);

		// Add default route (lowest priority) -------------------------------
		var route:IRoute = new Route(':controller/:action/*', {
			module:     'default',
			controller: 'index',
			action:     'index'
		});
		router.addRoute('default', route);
		
		return this;
	}
		
}