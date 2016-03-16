# WELCOME TO THE CBSTORAGES MODULE
A collection of model objects to facade and help with native ColdFusion persistence structures.

##LICENSE
Apache License, Version 2.0.

##IMPORTANT LINKS
- https://github.com/ColdBox/cbox-cbstorages
- http://forgebox.io/view/cbstorages

##SYSTEM REQUIREMENTS
- Lucee 4.5+
- ColdFusion 9+
- 
#INSTRUCTIONS
Just drop into your **modules** folder or use CommandBox to install

`box install cbstorages`

## WireBox Mappings
The module registers the following storage mappings:

* `applicationStorage@cbstorages`
* `clientStorage@cbstorages`
* `cookieStorage@cbstorages`
* `clusterStorage@cbstorages`
* `sessionStorage@cbstorages`

You can check out the included API Docs to see all the functions you can use for persistence.

## Settings
The **cluster** and **cookie** storages also have some configuration data that can be set in your application's configuration `ColdBox.cfc` under a `storages` structure:

```js
storages = {
    // If using the cluster storage, this is the cluster key app name to use
    clusterStorage = {
        clusterAppName = "MyApp"
    },
    // Cookie Storage settings
    cookieStorage = {
        useEncryption   = false,
        encryptionSeed  = "CBStorages",
        encryptionAlgorithm = "CFMX_COMPAT",
        encryptionEncoding = "HEX"
    }
};
```

********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
####HONOR GOES TO GOD ABOVE ALL
Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

###THE DAILY BREAD
 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12