package setup;

import org.toolkt.core.application.Application;
import org.toolkt.core.application.bootstrap.abstract.AbstractBootstrap;
import org.toolkt.core.db.adapter.abstract.AbstractAdapter;
import org.toolkt.core.db.Db;
import org.toolkt.core.db.interfaces.IDbTableSetup;

class InstallBootstrap extends AbstractBootstrap
{

	public function getDbAdapter():AbstractAdapter
	{
		return AbstractAdapter.getDefaultAdapter();
	}
	
	/**
	 * Constructor
	 */
	public function new(app:Application):Void
	{
		super(app);
	}
	
	override public function run():Void
	{
		var users:IDbTableSetup    = new org.toolkt.user.db.table.TableSetup();
		var node:IDbTableSetup     = new org.toolkt.node.db.table.TableSetup();
		var posts:IDbTableSetup    = new org.toolkt.post.db.table.TableSetup();
		var comments:IDbTableSetup = new org.toolkt.post.comment.db.table.TableSetup();
		
		users.setup();
		node.setup();
		posts.setup();
		comments.setup();
		
		// Populates db with data for test application
		this._setupTestData();
		
		this.getDbAdapter().close();
	}
	
	private function _setupTestData():Void
	{
		var sql:Array<String> = [];
		
		// Sample data for demo-application ----------------------------------------------------------------------------
		
		var i:Int = 0;
		while (i++ < 45) {
			var str:String = "post #" + i;
			sql.push('
				INSERT INTO post_posts (title, content, user_id, created_at, updated_at) 
					VALUES ("testpost ' + i +'", "testpost", 1, "0000-00-00 00:00:00", "0000-00-00 00:00:00")
			');
		}
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('about', 'right_content', '<p class=\"bar\">Some info</p><p>A web browser is not obliged to use DOM in order to render an HTML document. However, the DOM is required by JavaScript scripts that wish to inspect or modify a web page dynamically. In other words, the Document Object Model is the way JavaScript sees its containing HTML page and browser state.</p>')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('about', 'content', '<h1>Inline page editing test, should have some sort of wysiwyg</h1><p>(register/login to edit this page)</p><p><small>From Wikipedia, the free encyclopedia</small></p>The Document Object Model (DOM) is a cross-platform and language-independent convention for representing and interacting with objects in HTML, XHTML and XML documents. Aspects of the DOM (such as its \"Elements\") may be addressed and manipulated within the syntax of the programming language in use. The public interface of a DOM are specified in its Application Programming Interface (API).')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('home-welcome', 'title', 'Hot like ice! You are now rocking with haXe and the toolkat')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('home-welcome', 'body', 'Welcome to a smorgasbord of low-fat components, designed for rapid web development with haXe, NekoVM and PHP.')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('home-welcome', 'info', 'This project is hosted at <a href=\"http://code.google.com/p/toolkat\" target=\"_blank\">http://code.google.com/p/toolkat</a>')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('triplet', 'first', '<div id=\"tristar-logo\"></div>\r\n<p>\r\nThe Toolkat project is maintained and developed by Tristar and misc. \r\ncontributors.<br />\r\n<a href=\"http://www.tristarafrica.com\" target=\"_blank\">www.tristarafrica.com</a>\r\n</p>')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('triplet', 'second', '<ul><li><a href=\"http://haxe.org\">About haXe</a></li><li><a href=\"http://www.flashdevelop.org\">FlashDevelop script editor</a></li><li><strike>Getting started with Toolkat</strike> (todo)</li><li><strike>Available components</strike> (todo)</li></ul>')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('triplet', 'third', '<ul>\r\n<li><strike>Report a bug</strike> (todo)</li>\r\n<li><strike>Contribute patches</strike> (todo)</li>\r\n<li><strike>Suggestions &amp; ideas</strike> (todo)</li>\r\n</ul>')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('triplet', 'third_title', 'contribute')
		");
		sql.push("
			INSERT INTO node_block_content (block_uri, variable, content) 
				VALUES ('triplet', 'second_title', 'getting started')
		");
		
		// -------------------------------------------------------

		for (q in sql) {
			try {
				this.getDbAdapter().request(q);
			} catch (e:Dynamic) {
				// ...
			}
		}
	}

	override private function _init():Void
	{
		var opts:Dynamic = this._getAppOption('db');
		
		if (null != opts) {
			this._initResource(org.toolkt.core.application.resource.Db, opts);
		}
		
		var adapter:AdapterType = opts.get('adapter');
		var params:Dynamic = opts.get('params');
		
		switch (adapter) {

			case Sqlite:
			
				var path:String = params.path;
				var file:String = params.database;
			
				// Check if database exists in file system.
				var dbFile:String = path + file;
				
				if (!comp.FileSystem.exists(dbFile)) {
					
					try {
						// Create the database
						comp.db.Sqlite.open(dbFile);					
					} catch (e:Dynamic) {
						throw('Error creating Sqlite database file, check file permissions for folder \'db\'');
					}
				}
				
			case Mysql:
							
			default:
		}
	}
	
}