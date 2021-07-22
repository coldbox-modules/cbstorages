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
				storage = getInstance( "cookieStorage@cbstorages" );
				storage.clearAll();
			} );


			it( "can create the storage", function(){
				expect( storage ).toBeComponent();
				// expect( storage.getSize() ).toBe( 0 );
				// expect( storage.isEmpty() ).toBeTrue();
			} );


			it( "can use the common methods", function(){
				// Set, exists, get tests
				storage.set( "tester", 1 );
				expect( storage.exists( "tester" ) ).toBeTrue();
				expect( storage.get( "tester" ) ).toBe( 1 );
				expect( storage.exists( "nothing" ) ).toBeFalse();
				expect( storage.isEmpty() ).toBeFalse();

				// Delete Tests
				storage.delete( "tester" );
				if ( structKeyExists( server, "lucee" ) ) {
					expect( storage.get( "tester" ) ).toBeNull();
				} else {
					// Empty because we are in the same request
					expect( storage.get( "tester" ) ).toBeEmpty();
				}
			} );


			it( "can work with all multi methods", function(){
				// Cleanup
				storage.clearAll();

				// set/get multi with Keys
				storage.setMulti( { test : now(), test2 : "luis" } );
				expect( storage.getMulti( "test,test2" ) ).toHaveLength( 2 );

				// Get Keys
				expect( storage.getKeys() )
					.toBeArray()
					.toInclude( "CBSTORAGE_TEST" )
					.toInclude( "CBSTORAGE_TEST2" );

				// deleteMulti
				var r = storage.deleteMulti( "test,test2,test3" );
				expect( r.test ).toBeTrue();
				expect( r.test2 ).toBeTrue();
				expect( r.test3 ).toBeFalse();
			} );


			it( "can store complex data", function(){
				var complex = { "date" : now(), "id" : createUUID() };
				// Store complex data
				storage.set( "test-complex", complex );
				expect( storage.exists( "test-complex" ) ).toBeTrue();

				var r = storage.get( "test-complex" );
				debug( r );
				expect( r ).toBeStruct();
				expect( r.id, complex.id );
			} );


			it( "can test all methods with encryption", function(){
				/* set Encryption */
				storage.setEncryption( true );
				storage.setEncryptionSeed( "My#createUUID()#-Unit Test Key" );

				/* Set Single */
				storage.set( "tester-encrypt", 1 );
				expect( storage.exists( "tester-encrypt" ) ).toBeTrue();
				expect( storage.get( "tester-encrypt" ) ).toBe( 1 );

				/* Set Complex */
				storage.set(
					"tester-encrypt",
					{
						"name" : "luis",
						"now"  : now(),
						"kids" : [ 1, 2, 3 ]
					}
				);
				expect( storage.exists( "tester-encrypt" ) ).toBeTrue();
				expect( storage.get( "tester-encrypt" ) ).toBeStruct();
			} );
		} );
	}

}
