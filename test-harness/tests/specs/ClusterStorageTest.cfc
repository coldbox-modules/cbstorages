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
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/root" skip="true">
	<cffunction name="testRetrieval" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "clusterStorage@cbstorages" );
		assertTrue( isObject( storage ) );
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		var storage = getModel( "clusterStorage@cbstorages" );
		var complex = structNew();

		complex.date = now();
		complex.id = createUUID();

		storage.setVar( "tester", 1 );

		AssertTrue( storage.exists( "tester" ), "Test set & Exists" );
		AssertEquals( 1, storage.getVar( "tester" ), "Get & Set Test" );

		AssertFalse( storage.exists( "nothing" ), "False Assertion on exists" );

		storage.deleteVar( "tester" );
		AssertFalse( storage.exists( "tester" ), "Remove & Exists" );

		storage.setVar( "tester", complex );
		AssertTrue( storage.exists( "tester" ), "Test Complex set & Exists" );

		storage.deleteVar( "tester" );
		AssertFalse( storage.exists( "tester" ), "Remove & Exists" );
		</cfscript>
	</cffunction>

	<!--- railoOnly --->
	<cffunction name="railoOnly" output="false" access="public" returntype="boolean" hint="">
		<cfscript>
		return ( structKeyExists( server, "railo" ) ? false : true );
		</cfscript>
	</cffunction>
</cfcomponent>
