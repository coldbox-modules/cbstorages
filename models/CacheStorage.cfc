/**
 * Copyright Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This storage leverages cachebox in order to operate. It simulates a session/client storage bucket in cache.
 */
component
	accessors="true"
	extends  ="AbstractStorage"
	threadsafe
	singleton
{

	/**
	 * The cache provider to use
	 */
	property name="cache";

	/**
	 * Application name, comes from the application settings
	 */
	property name="appName";

	/**
	 * Session Timeout, defaults to 60 minutes
	 */
	property
		name   ="timeout"
		default="60"
		type   ="numeric";

	/**
	 * The module settings defined in ColdBox.cfc
	 */
	property name="settings";

	/**
	 * Constructor
	 *
	 * @settings The storage settings struct
	 * @cachebox A reference to CacheBox
	 * @settings.inject coldbox:moduleSettings:cbstorages
	 * @cachebox.inject cachebox
	 */
	function init( required settings, required cachebox ){
		// Get application name
		variables.appName = application.applicationName;

		// Param cacheStorage Settings
		param arguments.settings.cacheStorage                    = {};
		param arguments.settings.cacheStorage.cacheName          = "template";
		param arguments.settings.cacheStorage.timeout            = 60;
		param arguments.settings.cacheStorage.identifierProvider = "";

		// Store module settings
		variables.settings = arguments.settings;
		// Default timeout
		variables.timeout  = arguments.settings.cacheStorage.timeout;
		// Assemble Provider
		variables.cache    = arguments.cachebox.getCache( variables.settings.cacheStorage.cachename );

		return this;
	}

	/**
	 * Set a new variable in storage
	 *
	 * @name The name of the data key
	 * @value The value of the data to store
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function set( required name, required value ){
		var storage               = getStorage();
		// store in bucket
		storage[ arguments.name ] = arguments.value;
		// save it back in cache
		cache.set(
			getSessionKey(),
			storage,
			variables.timeout,
			0
		);

		return this;
	}

	/**
	 * Get a new variable in storage if it exists, else return default value, else will return null.
	 *
	 * @name The name of the data key
	 * @defaultValue The default value to return if not found in storage
	 */
	any function get( required name, defaultValue ){
		var storage = getStorage();
		// check if exists
		if ( structKeyExists( storage, arguments.name ) ) {
			return storage[ arguments.name ];
		}
		// default value
		if ( structKeyExists( arguments, "defaultValue" ) ) {
			return arguments.defaultValue;
		}
	}

	/**
	 * Delete a variable in the storage
	 *
	 * @name The name of the data key
	 */
	boolean function delete( required name ){
		var storage = getStorage();
		// verify and delete
		if ( structKeyExists( storage, arguments.name ) ) {
			structDelete( storage, arguments.name );
			// store it back
			cache.set(
				getSessionKey(),
				storage,
				variables.timeout,
				0
			);
			return true;
		}
		return false;
	}

	/**
	 * Clear the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function clearAll(){
		createStorage();
		return this;
	}

	/**
	 * Get the entire storage scope from cache. If it does not exist, then create the default bucket
	 */
	struct function getStorage(){
		var cacheKey = getSessionKey();
		// get map from cache
		var storage  = cache.get( cacheKey );
		// Verify, else create it
		if ( isNull( local.storage ) ) {
			storage = {
				"sessionid"   : cacheKey,
				"timecreated" : now()
			};
			cache.set(
				cacheKey,
				storage,
				variables.timeout,
				0
			);
		}

		return storage;
	}

	/**
	 * Remove the storage completely, different from clear, this detaches the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function removeStorage(){
		cache.clear( getSessionKey() );
		return this;
	}

	/**
	 * Check if storage exists
	 */
	boolean function storageExists(){
		return cache.lookup( getSessionKey() );
	}

	/**
	 * Create the storage.
	 * This initializes an empty session in the cache.
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function createStorage(){
		var cacheKey = getSessionKey();

		cache.set( cacheKey, {}, variables.timeout, 0 );

		return this;
	}

	/**************************** CONCRETE METHODS ****************************/

	/**
	 * Builds the unique Session Key of a user request and returns it to you.
	 * Order of discovery
	 * 1. identifierProvider closure
	 * 2. session identifiers
	 * 3. cookie cfid/cftoken
	 * 4. url cfid/cftoken
	 * 5. request based identifier
	 */
	string function getSessionKey(){
		// Setup global storage prefix according to app name in case we have multiple apps with storages
		var prefix = "cbstorage:#variables.appName#:";

		// Check settings identifier provider
		if ( !isSimpleValue( variables.settings.cacheStorage.identifierProvider ) ) {
			return prefix & variables.settings.cacheStorage.identifierProvider();
		}

		// Check jsession id First
		var isSessionDefined = getApplicationMetadata().sessionManagement;
		if ( isSessionDefined and structKeyExists( session, "sessionid" ) ) {
			return prefix & session.sessionid;
		}
		// check session URL Token
		else if ( isSessionDefined and structKeyExists( session, "URLToken" ) ) {
			return prefix & session.URLToken;
		}
		// Check cfid and cftoken in cookie
		else if ( structKeyExists( cookie, "CFID" ) AND structKeyExists( cookie, "CFTOKEN" ) ) {
			return prefix & hash( cookie.cfid & cookie.cftoken );
		}
		// Check cfid and cftoken in URL
		else if ( structKeyExists( URL, "CFID" ) AND structKeyExists( URL, "CFTOKEN" ) ) {
			return prefix & hash( URL.cfid & URL.cftoken );
		}
		// fallback for no cookie, session or url basically sessionless requests, track the request only
		else if ( isNull( request.cbStorageId ) ) {
			request.cbStorageId = prefix & createUUID();
		}

		return request.cbStorageId;
	}

}
