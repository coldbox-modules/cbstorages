component {

	// Module Properties
	this.title 				= "cbstorages";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "Provides a collection of facade storages for ColdFusion";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "cbstorages";

	function configure(){

		settings = {
			// If using the cluster storage, this is the cluster key app name to use
			clusterStorage = {
				clusterAppName = "MyApp"
			},
			// Cookie Storage settings
			cookieStorage = {
				useEncryption 	= false,
				encryptionSeed 	= "CBStorages",
				encryptionAlgorithm = "CFMX_COMPAT",
				encryptionEncoding = "HEX"
			}
		};

		// Binder Mappings
		binder.map( "application@cbstorages" )
			.to( "#moduleMapping#.model.ApplicationStorage" );
		binder.map( "client@cbstorages" )
			.to( "#moduleMapping#.model.ClientStorage" );
		binder.map( "cluster@cbstorages" )
			.to( "#moduleMapping#.model.ClusterStorage" )
			.initArg( name="appName", value=settings.clusterStorage.clusterAppName );
		binder.map( "cookie@cbstorages" )
			.to( "#moduleMapping#.model.CookieStorage" )
			.initArg( name="settings", value=settings.cookieStorage );
		binder.map( "session@cbstorages" )
			.to( "#moduleMapping#.model.SessionStorage" );

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){

	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}