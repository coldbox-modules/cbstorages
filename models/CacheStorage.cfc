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
	 * @settings        The storage settings struct
	 * @cachebox        A reference to CacheBox
	 * @settings.inject coldbox:moduleSettings:cbstorages
	 * @cachebox.inject cachebox
	 */
	function init( required settings, required cachebox ){
		// Locks
		variables.lockTimeout = 20;

		// Get application name
		variables.appName = getAppName();

		// Param cacheStorage Settings
		param arguments.settings.cacheStorage                    = {};
		param arguments.settings.cacheStorage.cacheName          = "template";
		param arguments.settings.cacheStorage.timeout            = 60;
		param arguments.settings.cacheStorage.identifierProvider = "";
		param arguments.settings.cacheStorage.lockProvider       = "";
		if (
			!isCustomFunction( arguments.settings.cacheStorage.lockProvider ) &&
			!(
				isSimpleValue( arguments.settings.cacheStorage.lockProvider ) && arguments.settings.cacheStorage.lockProvider == ""
			)
		) {
			throw(
				type    = "CacheStorage.InvalidLockProvider",
				message = "cacheStorage.lockProvider must be a callback or an empty string"
			);
		}

		// Store module settings
		variables.settings = arguments.settings;
		variables.lockName = "cbstorages.CacheStorage." & hash(
			arguments.settings.cacheStorage.cacheName,
			"SHA-256"
		);
		// Default timeout
		variables.timeout = arguments.settings.cacheStorage.timeout;
		// Assemble Provider
		variables.cache   = arguments.cachebox.getCache( variables.settings.cacheStorage.cachename );

		return this;
	}

	/**
	 * Set a new variable in storage
	 *
	 * @name  The name of the data key
	 * @value The value of the data to store
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function set( required name, required value ){
		var key         = getSessionKey();
		var field       = arguments.name;
		var storedValue = arguments.value;
		withStorageLock( key, function(){
			var storage      = readStorage( key );
			storage[ field ] = storedValue;
			writeStorage( key, storage );
		} );
		return this;
	}

	/** Set all fields in one protected read/modify/write operation. */
	CacheStorage function setMulti( required struct map ){
		var key    = getSessionKey();
		var values = arguments.map;
		withStorageLock( key, function(){
			var storage = readStorage( key );
			structAppend( storage, values, true );
			writeStorage( key, storage );
		} );
		return this;
	}

	/** Coordinate production with the same bucket lock used by other mutations. */
	any function getOrSet( required name, required any produce ){
		var key      = getSessionKey();
		var field    = arguments.name;
		var producer = arguments.produce;
		return withStorageLock( key, function(){
			var storage = readStorage( key );
			if ( structKeyExists( storage, field ) && !isNull( storage[ field ] ) ) {
				return storage[ field ];
			}
			var value        = producer();
			storage[ field ] = value;
			writeStorage( key, storage );
			return value;
		} );
	}

	/**
	 * Get a new variable in storage if it exists, else return default value, else will return null.
	 *
	 * @name         The name of the data key
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
		var key   = getSessionKey();
		var field = arguments.name;
		return withStorageLock( key, function(){
			var storage = readStorage( key );
			if ( structKeyExists( storage, field ) ) {
				structDelete( storage, field );
				writeStorage( key, storage );
				return true;
			}
			return false;
		} );
	}

	/**
	 * Clear the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function clearAll(){
		return createStorage();
	}

	/**
	 * Get the entire storage scope from cache. If it does not exist, then create the default bucket
	 */
	struct function getStorage(){
		var cacheKey = getSessionKey();
		return withStorageLock( cacheKey, function(){
			return readStorage( cacheKey );
		} );
	}

	/** Called only while holding the bucket lock, including first-use initialization. */
	private struct function readStorage( required string cacheKey ){
		// get map from cache
		var storage = variables.cache.get( arguments.cacheKey );
		// Verify, else create it
		if ( isNull( local.storage ) ) {
			storage = { "sessionid" : cacheKey, "timecreated" : now() };
			writeStorage( arguments.cacheKey, storage );
		}

		return storage;
	}

	/**
	 * Remove the storage completely, different from clear, this detaches the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	CacheStorage function removeStorage(){
		var key = getSessionKey();
		withStorageLock( key, function(){
			variables.cache.clear( key );
		} );
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
		withStorageLock( cacheKey, function(){
			writeStorage( cacheKey, {} );
		} );

		return this;
	}

	/**************************** CONCRETE METHODS ****************************/

	private function writeStorage( required string cacheKey, required struct storage ){
		variables.cache.set(
			arguments.cacheKey,
			arguments.storage,
			variables.timeout,
			0
		);
	}

	/** A distributed provider must execute the operation synchronously and exclusively. */
	private any function withStorageLock( required string cacheKey, required any operation ){
		var name = variables.lockName & "." & hash( arguments.cacheKey, "SHA-256" );
		if ( isCustomFunction( variables.settings.cacheStorage.lockProvider ) ) {
			return variables.settings.cacheStorage.lockProvider(
				name,
				arguments.operation,
				variables.lockTimeout
			);
		}
		lock name=name type="exclusive" timeout=variables.lockTimeout throwOnTimeout=true {
			return arguments.operation();
		}
	}

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

		return super.getSessionKey();
	}

}
