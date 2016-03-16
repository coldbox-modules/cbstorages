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
			var storage = getModel( "ApplicationStorage@cbstorages" );
			
			assertTrue( isObject( storage ) );
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var storage = getModel( "applicationStorage@cbstorages" );

			storage.setVar("tester", 1);

			AssertTrue( storage.exists("tester") ,"Test set & Exists");
			AssertEquals(1, storage.getVar("tester"), "Get & Set Test");

			AssertFalse( storage.exists("nothing") ,"False Assertion on exists" );

			storage.deleteVar("tester");
			AssertFalse( storage.exists("tester") ,"Remove & Exists");

			storage.setVar("tester", 1);
			storage.setVar("tester2", now());

			storage.clearAll();
			AssertTrue( structISEmpty(application.cbStorage), "Clear & Test" );
		</cfscript>
	</cffunction>

	<!--- tearDown --->
	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
		<cfscript>
		structDelete(application,"cbStorage");
		</cfscript>
	</cffunction>

</cfcomponent>