
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
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root"{

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

			beforeEach(function( currentSpec ){
				structdelete( application, "cbController" );
				structdelete( application, "wirebox" );
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
				storage = getModel( "cookieStorage@cbstorages" );
			});


			it( "can create the storage", function(){
				expect( storage ).toBeComponent();
			});


			it( "can test all methods", function(){
				debug( cookie );

				var complex = structNew();

				complex.date = now();
				complex.id = createUUID();

				storage.set( "tester", 1 );
				expect( storage.exists( "tester" ) ).toBeTrue();
				expect( storage.get( "tester" ) ).toBe( 1 );

				expect( storage.exists( "nothing" ) ).toBeFalse();
				storage.delete( "tester" );
				expect( storage.exists( "tester" ) ).toBeFalse();

				return ;


				AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for tester simple" );
				storage.set( "tester", complex );
				AssertTrue( storage.exists( "tester" ), "Test Complex set & Exists" );
				debug( cookie );
				r = storage.get( "tester" );
				assertTrue( isStruct( r ) );
				assertEquals( complex.id, r.id );

				storage.delete( "tester" );
				AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for complex" );


				debug( cookie );
				storage.clearAll();
				debug( cookie );

				// set/get multi with Keys
				storage.setMulti( { test : now(), test2 : "luis" } );
				expect( storage.getMulti( "test,test2" ) ).toHaveLength( 2 );
				// Get Keys
				expect( storage.getKeys() )
					.toBeArray()
					.toHaveLength( 2 )
					.toInclude( "test" )
					.toInclude( "test2" );

				// deleteMulti
				var r = storage.deleteMulti( "test,test2,test3" );
				expect( r.test ).toBeTrue();
				expect( r.test2 ).toBeTrue();
				expect( r.test3 ).toBeFalse();

				expect( storage.getSize() ).toBe( 0 );
				expect( storage.isEmpty() ).toBeTrue();
			});


			xit( "can test all methods with encryption", function(){
				var storage = getModel( "cookieStorage@cbstorages" );
				var complex = structNew();

				complex.date = now();
				complex.id = createUUID();

				/* set Encryption */
				storage.setEncryption( true );
				storage.setEncryptionSeed( "My#createUUID()#-Unit Test Key" );

				/* Set */
				storage.set( "tester", 1 );
				AssertTrue( storage.exists( "tester" ), "Test set & Exists" );
				AssertEquals( 1, storage.get( "tester" ), "Get & Set Test" );

				AssertFalse( storage.exists( "nothing" ), "False Assertion on exists" );
				storage.delete( "tester" );
				AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for tester simple" );

				storage.set( "tester", complex );
				AssertTrue( storage.exists( "tester" ), "Test Complex set & Exists" );

				storage.delete( "tester" );
				AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for complex" );
			});

		});

	}

}