/**
* Copyright Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Module Configuration
*/
component {

	// Module Properties
	this.title 				= "ColdBox Storages";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "https://www.ortussolutions.com";
	this.description 		= "Provides a collection of facade storages for ColdFusion and distributed caching";
	this.version			= "@build.version@+@build.number@";
	this.cfmapping			= "cbstorages";

	/**
	 * Configure
	 */
	function configure(){
		settings = {
			// Cache Storage Settings
			cacheStorage : {
				cachename   : "template", // The CacheBox registered cache to store data in
				timeout     : 60 // The default timeout of the session bucket, defaults to 60
			},

			// Cookie Storage settings
			cookieStorage : {
				useEncryption 		: false,
				encryptionSeed 		: "CBStorages",
				encryptionAlgorithm : "CFMX_COMPAT",
				encryptionEncoding 	: "HEX"
			}
		};
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