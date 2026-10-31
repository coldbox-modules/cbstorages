/** Focused storage contracts without an application server or external services. */
component {

	function run( string testboxPath = "test-harness/testbox", string report = "" ){
		var root = variables.fileSystemUtil.resolvePath( "." );
		variables.fileSystemUtil.createMapping( "/cbstorages", root );
		variables.fileSystemUtil.createMapping( "/tests", root & "/test-harness/tests" );
		variables.fileSystemUtil.createMapping( "/testbox", variables.fileSystemUtil.resolvePath( testboxPath ) );
		var result = new testbox.system.TestBox( bundles = "tests.specs.CacheStorageConcurrencyTest" )
			.runRaw()
			.getMemento( includeDebugBuffer = true );
		if ( len( report ) ) {
			fileWrite( variables.fileSystemUtil.resolvePath( report ), serializeJSON( result ) );
		}
		for ( var bundle in result.bundleStats ) {
			for ( var suite in bundle.suiteStats ) {
				for ( var spec in suite.specStats ) {
					variables.print.line( spec.status & " " & spec.name & ": " & spec.failMessage );
					if ( spec.status == "Error" ) {
						variables.print.line( spec.error.message & " " & spec.error.detail );
					}
				}
			}
		}
		variables.print.line( "Passed: #result.totalPass#; failed: #result.totalFail#; errors: #result.totalError#" );
		if ( result.totalFail || result.totalError || !result.totalPass ) {
			throw( message = "CacheStorage contracts failed" );
		}
	}

}
