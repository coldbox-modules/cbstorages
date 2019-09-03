﻿/**
* Copyright Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This storage leverages the application scope for its bucket storage and applies correct locks for access and mutations.
*/
component
	accessors="true"
	serializable="false"
	extends="AbstractStorage"
	implements="IStorage"
	threadsafe
	singleton
{

	/**
	* Lock Timeout
	*/
	property name="lockTimeout" default="20" type="numeric";


	/**
	 * Constructor
	 */
	function init(){
		variables.lockName 		= hash( now() ) & "_APPLICATION_STORAGE";
		variables.lockTimeout 	= 20;

		createStorage();

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
	any function set( required name, required value ){
		var storage = getStorage();

		lock name="#variables.lockName#" type="exclusive" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			storage[ arguments.name ] = arguments.value;
		}

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

		lock name="#variables.lockName#" type="readonly" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			// check if exists
			if( structKeyExists( storage, arguments.name ) ){
				return storage[ arguments.name ];
			}

			// default value
			if( !isNull( arguments.defaultValue ) ){
				return arguments.defaultValue;
			}
		}

		// if we get here, we return null
	}

	/**
	 * Delete a variable in the storage
	 *
	 * @name The name of the data key
	 */
	boolean function delete( required name ){
		var storage = getStorage();

		lock name="#variables.lockName#" type="exclusive" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			return structDelete( storage, arguments.name, true );
		}

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
	 * Clear the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function clearAll(){
		var storage = getStorage();

		lock name="#variables.lockName#" type="exclusive" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			structClear( storage );
		}

		return this;
	}

	/****************************************** STORAGE METHODS ******************************************/

	/**
	 * Get the entire storage scope structure
	 */
	struct function getStorage(){
		// Verify Storage Exists
		createStorage();

		// Return Storage now that it is guaranteed to exist
		lock name="#variables.lockName#" type="readonly" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			return application.cbStorage;
		}
	}

	/**
	 * Remove the storage completely, different from clear, this detaches the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function removeStorage(){
		lock name="#variables.lockName#" type="exclusive" timeout="#variables.lockTimeout#" throwOnTimeout=true{
			structDelete( application, "cbStorage" );
		}

		return this;
	}

	/**
	 * Check if storage exists
	 */
	boolean function storageExists(){
		return !isNull( application.cbStorage );
	}

	/**
	 * Create the storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function createStorage(){

		if( isNull( application.cbStorage ) ){

			lock name="#variables.lockName#" type="exclusive" timeout="#variables.lockTimeout#" throwOnTimeout=true{

				// Double Lock Race Conditions
				if( isNull( application.cbStorage ) ){
					application.cbStorage = {};
				}

			}

		}

		return this;
	}

}