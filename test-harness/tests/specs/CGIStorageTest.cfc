/*******************************************************************************
 *	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
 *
 *	Extends the integration class: coldbox.system.testing.BaseTestCase
 *
 *	so you can test your ColdBox application headlessly. The 'appMapping' points by default to
 *	the '/root' mapping created in the test folder Application.cfc.  Please note that this
 *	Application.cfc must mimic the real one in your root, including ORM settings if needed.
 *
 *	The 'execute()' method is used to execute a ColdBox event, with the following arguments
 *	* event : the name of the event
 *	* private : if the event is private or not
 *	* prePostExempt : if the event needs to be exempt of pre post interceptors
 *	* eventArguments : The struct of args to pass to the event
 *	* renderResults : Render back the results of the event
 *******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Main Handler", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
				storage = getInstance( "CGIStorage@cbstorages" );
				storage.clearAll();
			} );

			it( "can create the storage", function(){
				expect( storage ).toBeComponent();
				expect( storage.getSize() ).toBeGT( 0 );
				expect( storage.isEmpty() ).toBeFalse();
			} );

			it( "can use the common methods", function(){
				// Set, exists, get tests
				expect( storage.exists( "script_name" ) ).toBeTrue();
				expect( cgi.PATH_INFO ).toBe( storage.get( "path_info" ) );
				expect( storage.exists( "nothing" ) ).toBeFalse();
				expect( storage.isEmpty() ).toBeFalse();
			} );

			it( "can work with all multi methods", function(){
				// Get Keys
				expect( storage.getKeys() )
					.toBeArray()
					.toInclude( "path_info" )
					.toInclude( "server_port" );
			} );
		} );
	}

}
