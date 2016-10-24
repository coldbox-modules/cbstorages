<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author     :    Eric Peterson, Mike Burt, and Dan Murphy
Date        :   10/24/2007
Description :
    Request Storage Test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/root">

    <cffunction name="testRetrieval" access="public" returntype="void" output="false">
        <!--- Now test some events --->
        <cfscript>
            var storage = getModel( "requestStorage@cbstorages" );
            assertTrue( isObject( storage ) );
        </cfscript>
    </cffunction>

    <cffunction name="testMethods" access="public" returntype="void" output="false">
        <!--- Now test some events --->
        <cfscript>
            var storage = getModel( "requestStorage@cbstorages" );

            storage.setVar("tester", 1);

            AssertTrue( storage.exists("tester") ,"Test set & Exists");
            AssertEquals(1, storage.getVar("tester"), "Get & Set Test");

            AssertFalse( storage.exists("nothing") ,"False Assertion on exists" );

            storage.deleteVar("tester");
            AssertFalse( storage.exists("tester") ,"Remove & Exists");

            storage.setVar("tester", 1);
            storage.setVar("tester2", now());

            storage.clearAll();
            AssertTrue( structISEmpty(request.cbStorage), "Clear & Test" );

            //Remove it
            structDelete(request, "cbStorage");
            //Try to add to it
            storage.setVar("tester", 123);
            AssertTrue( storage.exists("tester") ,"Removal Reconstruction test.");

        </cfscript>
    </cffunction>

    <!--- tearDown --->
    <cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
        <cfscript>
        structDelete(request,"cbStorage");
        </cfscript>
    </cffunction>

</cfcomponent>
