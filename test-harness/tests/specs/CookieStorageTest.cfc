<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author     :	Luis Majano
Date        :	9/3/2007
Description :
securityTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/root">
	<cffunction name="testRetrieval" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "cookieStorage@cbstorages" );
		assertTrue( isObject( storage ) );
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "cookieStorage@cbstorages" );
		var complex = structNew();

		complex.date = now();
		complex.id = createUUID();

		storage.set( "tester", 1 );

		AssertTrue( storage.exists( "tester" ), "Test set & Exists" );
		AssertEquals( 1, storage.get( "tester" ), "Get & Set Test" );

		AssertFalse( storage.exists( "nothing" ), "False Assertion on exists" );
		storage.delete( "tester" );
		debug( cookie );

		AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for tester simple" );
		storage.set( "tester", complex );
		AssertTrue( storage.exists( "tester" ), "Test Complex set & Exists" );
		debug( cookie );
		r = storage.get( "tester" );
		assertTrue( isStruct( r ) );
		assertEquals( complex.id, r.id );

		storage.delete( "tester" );
		AssertFalse( storage.get( "tester" ).length(), "Remove & Exists for complex" );
		</cfscript>
	</cffunction>

	<cffunction name="testWithEncryption" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "cookieStorage@cbstorages" );
		var complex = structNew();

		complex.date = now();
		complex.id = createUUID();

		/* set Encryption */
		storage.setEncryption( true );
		storage.setEncryptionKey( "My#createUUID()#-Unit Test Key" );

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
		</cfscript>
	</cffunction>
</cfcomponent>
