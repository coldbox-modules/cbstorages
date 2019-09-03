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
		var storage = getModel( "cachestorage@cbstorages" );
		assertTrue( isObject( storage ) );
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "cacheStorage@cbstorages" );
		var complex = structNew();

		complex.date = now();
		complex.id = createUUID();

		storage.setVar( "tester", 1 );

		AssertTrue( storage.exists( "tester" ), "Test set & Exists" );
		AssertEquals( 1, storage.getVar( "tester" ), "Get & Set Test" );

		AssertFalse( storage.exists( "nothing" ), "False Assertion on exists" );
		storage.deleteVar( "tester" );

		expect( storage.getVar( "tester" ) ).toBeNull();

		storage.setVar( "tester", complex );
		AssertTrue( storage.exists( "tester" ), "Test Complex set & Exists" );

		var r = storage.getVar( "tester" );
		assertTrue( isStruct( r ) );
		assertEquals( complex.id, r.id );

		storage.deleteVar( "tester" );
		expect( storage.getVar( "tester" ) ).toBeNull();
		</cfscript>
	</cffunction>
</cfcomponent>
