/**
 * Copyright Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a common storage utility class for all implementing storages.
 */
component accessors="true" serializable="false" {

	/**
	 * Lock Timeout
	 */
	property
		name   ="lockTimeout"
		default="20"
		type   ="numeric";

	/**
	 * Lock Name : If you want to lock the storage, you can provide a lock name
	 */
	property
		name   ="lockName"
		type   ="string"
		default="";

	// Setup defaults
	variables.lockTimeout = 20;
	variables.lockName    = hash( now() );

	/**
	 * Do a multi-set using a target structure of name-value pairs
	 *
	 * @map A struct of name value pairs to store
	 *
	 * @return cbstorages.models.IStorage
	 */
	AbstractStorage function setMulti( required struct map ){
		arguments.map.each( function( key, value ){
			set( key, value );
		} );

		return this;
	}

	/**
	 * Triest to get a value from the storage, if it does not exist, then it will
	 * call the `produce` closure/lambda to produce the required value and store it
	 * in the storage using the passed named key.
	 *
	 * @name    The name of the key to get
	 * @produce The closure/lambda to execute that should produce the value
	 */
	any function getOrSet( required name, required any produce ){
		// Verify if it exists? if so, return it.
		var target = get( arguments.name );
		if ( !isNull( local.target ) ) {
			return target;
		}

		// else, produce it
		lock
			name          ="getOrSet.#variables.lockName#.#arguments.name#"
			type          ="exclusive"
			timeout       ="#variables.lockTimeout#"
			throwonTimeout="true" {
			// double lock, due to race conditions
			var target    = get( arguments.name );
			if ( isNull( local.target ) ) {
				// produce it
				target = arguments.produce();
				// store it
				set( arguments.name, target );
			}
		}

		return target;
	}

	/**
	 * Get multiple values from the storage using the keys argument which can be a list or an array
	 *
	 * @keys A list or array of keys to get from the storage
	 */
	struct function getMulti( required keys ){
		if ( isSimpleValue( arguments.keys ) ) {
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// reduce to struct of data
			.reduce( function( result, key ){
				result[ key ] = get( key );
				return result;
			}, {} );
	}


	/**
	 * Delete multiple keys from the storage
	 *
	 * @keys A list or array of keys to delete from the storage
	 *
	 * @return A struct of the keys and a boolean value if they where removed or not
	 */
	struct function deleteMulti( required keys ){
		if ( isSimpleValue( arguments.keys ) ) {
			arguments.keys = listToArray( arguments.keys );
		}

		return arguments.keys
			// reduce to struct of lookups
			.reduce( function( result, key ){
				result[ key ] = delete( key );
				return result;
			}, {} );
	}

	/**
	 * Verifies if the named storage key exists
	 *
	 * @name The name of the data key
	 */
	boolean function exists( required name ){
		// check if exists
		return structKeyExists( getStorage(), arguments.name );
	}

	/**
	 * Get the size of the storage
	 */
	numeric function getSize(){
		return structCount( getStorage() );
	}

	/**
	 * Get the list of keys stored in the storage
	 */
	array function getKeys(){
		return structKeyArray( getStorage() );
	}

	/**
	 * Verifies if the storage is empty or not
	 */
	boolean function isEmpty(){
		return structIsEmpty( getStorage() );
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
		var prefix = "cbstorage:#getAppName()#:";

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

	/**
	 * Get the current application's name, if not found, return an empty string
	 */
	string function getAppName(){
		return application.keyExists( "applicationName" )
		 ? application.applicationName
		 : "";
	}

}
