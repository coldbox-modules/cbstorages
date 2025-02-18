/**
 * Copyright Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Module Configuration
 */
component {

	// Module Properties
	this.title       = "ColdBox Storages";
	this.author      = "Ortus Solutions";
	this.webURL      = "https://www.ortussolutions.com";
	this.description = "Provides a collection of facade storages for ColdFusion and distributed caching";
	this.version     = "@build.version@+@build.number@";
	this.cfmapping   = "cbstorages";

	/**
	 * Configure
	 */
	function configure(){
		settings = {
			// Cache Storage Settings
			cacheStorage : {
				// The CacheBox registered cache to store data in
				cachename          : "template",
				// The default timeout of the session bucket, defaults to 60
				timeout            : 60,
				// The identifierProvider is a closure/udf that will return a unique identifier according to your rules
				// If you do not provide one, then we will search in session, cookie and url for the ColdFusion identifier.
				// identifierProvider : function(){}
				identifierProvider : "" // If it's a simple value, we ignore it.
			},
			// Cookie Storage settings
			cookieStorage : {
				// Matches the secure attribute of cfcookie, ssl only
				secure              : false,
				// If yes, sets cookie as httponly so that it cannot be accessed using JavaScripts
				httpOnly            : true,
				// Applicable global cookie domain
				domain              : "",
				// Use encryption of values
				useEncryption       : false,
				// The encryption key to use for the encryption
				encryptionKey : generateSecretKey( "AES", "128" ),
				// The unique seeding key to use: keep it secret, keep it safe
				encryptionSeed      : "CBStorages",
				// The algorithm to use: AES, BLOWFISH, DES, 3DES, RC4
				encryptionAlgorithm : "AES",
				// The encryption encoding to use
				encryptionEncoding  : "base64"
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
