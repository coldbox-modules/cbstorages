[![Total Downloads](https://forgebox.io/api/v1/entry/cbstorages/badges/downloads)](https://forgebox.io/view/cbstorages)
[![Latest Stable Version](https://forgebox.io/api/v1/entry/cbstorages/badges/version)](https://forgebox.io/view/cbstorages)
[![Apache2 License](https://img.shields.io/badge/License-Apache2-blue.svg)](https://forgebox.io/view/cbstorages)

<p align="center">
	<img src="https://www.ortussolutions.com/__media/coldbox-185-logo.png" alt="ColdBox Platform Logo">
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

# Welcome to the cbStorages Module

The `cbstorages` module will provide you with a collection of **smart** :wink: storage services that will enhance the capabilities of the major persistence scopes:

- Application
- Cache
- Cgi
- Client
- Cookie
- Request
- Session

## Enhancement Capabilities

- Consistent API for dealing with all persistent scopes
- The `CacheStorage` allows you to leverage distributed caches like Couchbase, Redis, ehCache, etc for distributed session management. It can act as a distributed session scope.
- The `CookieStorage` can do automatic encryption/decryption, httpOnly, security and much more.
- Ability to retrieve and clear all values stored in a scope
- Ability to deal with complex and simple values by leveraging JSON serialization
- Much More

## License

Apache License, Version 2.0.

## Important Links

- Source: https://github.com/coldbox-modules/cbstorages
- Issues: https://github.com/coldbox-modules/cbstorages#issues
- ForgeBox: https://forgebox.io/view/cbstorages
- [Changelog](changelog.md)

## Requirements

- BoxLang 1.0+ (Preferred)
- Lucee 5+
- ColdFusion 2023+

## Installation

Use CommandBox to install

`box install cbstorages`

## Usage Examples

### Basic Operations

```javascript
// Get a storage instance via WireBox
var storage = getInstance("sessionStorage@cbstorages");

// Store and retrieve values
storage.set("userName", "johndoe");
var userName = storage.get("userName", "anonymous");

// Work with complex data
storage.set("userPrefs", { theme: "dark", lang: "en" });
var prefs = storage.get("userPrefs");

// Check existence and delete
if (storage.exists("userName")) {
    storage.delete("userName");
}
```

### Method Chaining (Fluent API)

Most storage methods return the storage instance, enabling fluent API usage:

```javascript
storage
    .set("user", userData)
    .set("session", sessionData)
    .setMulti({
        "lastLogin": now(),
        "isVIP": true
    })
    .clearAll();
```

### Multi-Operations

```javascript
// Batch operations for efficiency
storage.setMulti({
    "key1": "value1",
    "key2": "value2",
    "key3": { complex: "data" }
});

// Retrieve multiple values at once
var data = storage.getMulti(["key1", "key2", "key3"]);

// Delete multiple keys
var results = storage.deleteMulti(["key1", "key2"]);
// Returns: { "key1": true, "key2": true }
```

### Get-or-Set Pattern

Use `getOrSet()` for expensive operations with built-in concurrency protection:

```javascript
// Only executes the function if the key doesn't exist
var userData = storage.getOrSet("userProfile", function(){
    return userService.getComplexUserData(userId);
});

// Perfect for caching expensive calculations
var report = storage.getOrSet("monthlyReport", function(){
    return reportService.generateMonthlyReport();
});
```

## WireBox Mappings

The module registers the following storage mappings:

- `applicationStorage@cbstorages` - For application based storage
- `CGIStorage@cbstorages` - For cgi based storage (read-only)
- `clientStorage@cbstorages` - For client based storage
- `cookieStorage@cbstorages` - For cookie based storage
- `sessionStorage@cbstorages` - For session based storage
- `cacheStorage@cbstorages` - For CacheBox based storage simulating session/client
- `requestStorage@cbstorages` - For request based storage

You can check out the included [API Docs](https://apidocs.ortussolutions.com/#/coldbox-modules/cbstorages/) to see all the functions you can use for persistence.

## Settings

Some storages require further configuration via your configuration file `config/ColdBox.cfc` under the `moduleSettings` in a `cbStorages` structure:

```js
cbStorages : {
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
		secure 				: false,
		// If yes, sets cookie as httponly so that it cannot be accessed using JavaScripts
		httpOnly			: true,
		// Applicable global cookie domain
		domain 				: "",
		// Use encryption of values
		useEncryption 		: false,
		// The encryption key to use for the encryption
		encryptionKey : generateSecretKey( "AES", "128" ),
		// The unique seeding key to use: keep it secret, keep it safe
		encryptionSeed 		: "CBStorages",
		// The algorithm to use: https://cfdocs.org/encrypt
		encryptionAlgorithm : "AES",
		// The encryption encoding to use
		encryptionEncoding 	: "Base64"
	}
}
```

## CacheStorage Unique Tracking Identifiers

The `CacheStorage` leverages a discovery algorithm to determine a user's request in order to store their session information.  The discovery order is the following:

1. identifierProvider closure/lambda/udf
2. Session identifiers
3. Cookie identifiers
4. URL identifiers
5. Create a unique request identifier

You can use the `identifierProvider` in order to give the storage the unique identifier you want to use. This is useful if you do your own tracking your way. If not, we will use the ColdFusion approaches of `jsessionID` or `cfid/cftoken`.

```js
identifierProvider = function(){
	return cookie.myTrackingCookie;
}
```

## Storage Methods

All storages must adhere to our interface, but each of them can extend as they see please.  Here is the basic interface for all storages:

```java
/**
 * Copyright Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is the main storage interface all cbStorages should implement
 */
interface {

	/**
	 * Set a new variable in storage
	 *
	 * @name The name of the data key
	 * @value The value of the data to store
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function set( required name, required value );

	/**
	 * Do a multi-set using a target structure of name-value pairs
	 *
	 * @map A struct of name value pairs to store
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function setMulti( required struct map );

	/**
	 * Get a new variable in storage if it exists, else return default value, else will return null.
	 *
	 * @name The name of the data key
	 * @defaultValue The default value to return if not found in storage
	 */
	any function get( required name, defaultValue );

	/**
	 * Triest to get a value from the storage, if it does not exist, then it will
	 * call the `produce` closure/lambda to produce the required value and store it
	 * in the storage using the passed named key.
	 *
	 * @name The name of the key to get
	 * @produce The closure/lambda to execute that should produce the value
	 */
	any function getOrSet( required name, required any produce );

	/**
	 * Get multiple values from the storage using the keys argument which can be a list or an array
	 *
	 * @keys A list or array of keys to get from the storage
	 */
	struct function getMulti( required keys );

	/**
	 * Delete a variable in the storage
	 *
	 * @name The name of the data key
	 */
	boolean function delete( required name );

	/**
	 * Delete multiple keys from the storage
	 *
	 * @keys A list or array of keys to delete from the storage
	 *
	 * @return A struct of the keys and a boolean value if they where removed or not
	 */
	struct function deleteMulti( required keys );

	/**
	 * Verifies if the named storage key exists
	 *
	 * @name The name of the data key
	 */
	boolean function exists( required name );

	/**
	 * Clear the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function clearAll();

	/**
	 * Get the size of the storage
	 */
	numeric function getSize();

	/**
	 * Get the list of keys stored in the storage
	 */
	array function getKeys();

	/**
	 * Verifies if the storage is empty or not
	 */
	boolean function isEmpty();

	/****************************************** STORAGE METHODS ******************************************/

	/**
	 * Get the entire storage scope structure, basically means return all the keys
	 */
	struct function getStorage();

	/**
	 * Remove the storage completely, different from clear, this detaches the entire storage
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function removeStorage();

	/**
	 * Check if storage exists
	 */
	boolean function storageExists();

	/**
	 * Create the storage
	 *
	 *
	 * @return cbstorages.models.IStorage
	 */
	any function createStorage();

}
```

## Storage Lifecycle & Utility Methods

Beyond the basic CRUD operations, each storage provides lifecycle and utility methods:

```javascript
// Storage information
var size = storage.getSize();           // Get number of stored items
var keys = storage.getKeys();           // Get array of all keys
var empty = storage.isEmpty();          // Check if storage is empty

// Storage lifecycle (advanced usage)
var exists = storage.storageExists();   // Check if underlying storage exists
storage.createStorage();                // Initialize storage if needed
storage.removeStorage();                // Completely destroy storage
var scope = storage.getStorage();       // Get entire storage structure
```

## Advanced Patterns

### Error Handling

```javascript
// Safe retrieval with defaults
var userPrefs = storage.get("preferences", {});

// Check storage availability for distributed scenarios
if (storage.storageExists()) {
    var data = storage.get("importantData");
} else {
    storage.createStorage();
}

// Null vs undefined handling
var value = storage.get("mayNotExist");
if (!isNull(value)) {
    // Value exists (could be empty string, 0, false, etc.)
}
```

### Distributed Session Management

```javascript
// Configure CacheStorage for distributed sessions
moduleSettings = {
    cbStorages: {
        cacheStorage: {
            cachename: "redis",  // Your distributed cache
            timeout: 60,
            identifierProvider: function(){
                // Custom session tracking
                return cookie.myAppSessionId ?: createUUID();
            }
        }
    }
};

// Use exactly like regular session storage
var cache = getInstance("cacheStorage@cbstorages");
cache.set("cart", shoppingCartData);
cache.set("userState", currentUserState);
```

### Cookie Storage with Encryption

```javascript
// Configure encrypted cookie storage
moduleSettings = {
    cbStorages: {
        cookieStorage: {
            useEncryption: true,
            secure: true,        // HTTPS only
            httpOnly: true,      // No JavaScript access
            domain: ".mysite.com"
        }
    }
};

// Values are automatically encrypted/decrypted
var cookieStorage = getInstance("cookieStorage@cbstorages");
cookieStorage.set("sensitiveData", userData);  // Encrypted automatically
var data = cookieStorage.get("sensitiveData"); // Decrypted automatically
```

## Testing

When testing with cbstorages, especially CacheStorage:

```javascript
component extends="coldbox.system.testing.BaseTestCase" {
    function beforeEach() {
        // Important: Setup new request context
        setup();

        // Get fresh storage instance
        storage = getInstance("sessionStorage@cbstorages");
        storage.clearAll();
    }

    function testStorageOperations() {
        storage.set("test", "value");
        expect(storage.get("test")).toBe("value");
        expect(storage.exists("test")).toBeTrue();
    }
}
```

********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

### HONOR GOES TO GOD ABOVE ALL

Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
