component extends="testbox.system.BaseSpec" {

	function run(){
		describe( "CacheStorage concurrency", function(){
			beforeEach( function(){
				variables.cache   = new tests.resources.SnapshotCache();
				variables.bucket  = createUUID();
				variables.storage = buildStorage();
				variables.other   = buildStorage();
				variables.storage.createStorage();
			} );

			it( "preserves both writes from independent storage instances", function(){
				var firstName  = "storageFirst" & replace( createUUID(), "-", "", "all" );
				var secondName = "storageSecond" & replace( createUUID(), "-", "", "all" );
				variables.cache.delayNextRead();
				thread name=firstName action="run" storage=variables.storage {
					attributes.storage.set( "first", 1 );
				}
				var started = variables.cache.firstRead.await(
					javacast( "long", 5 ),
					createObject( "java", "java.util.concurrent.TimeUnit" ).SECONDS
				);
				thread name=secondName action="run" storage=variables.other {
					attributes.storage.set( "second", 2 );
				}
				thread action="join" name="#firstName#,#secondName#" timeout=10000;
				expect( started ).toBeTrue();
				expect( cfthread[ firstName ].status ).toBe( "COMPLETED" );
				expect( cfthread[ secondName ].status ).toBe( "COMPLETED" );
				expect( variables.storage.get( "first", 0 ) ).toBe( 1 );
				expect( variables.storage.get( "second", 0 ) ).toBe( 2 );
			} );

			it( "produces a missing value once across independent instances and preserves false", function(){
				var results    = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
				var count      = createObject( "java", "java.util.concurrent.atomic.AtomicInteger" ).init( 0 );
				var firstName  = "produceFirst" & replace( createUUID(), "-", "", "all" );
				var secondName = "produceSecond" & replace( createUUID(), "-", "", "all" );
				variables.cache.delayNextRead();
				thread name=firstName action="run" storage=variables.storage count=count results=results {
					var value = attributes.storage.getOrSet( "flag", function(){
						attributes.count.incrementAndGet();
						return false;
					} );
					attributes.results.put( "first", value );
				}
				var started = variables.cache.firstRead.await(
					javacast( "long", 5 ),
					createObject( "java", "java.util.concurrent.TimeUnit" ).SECONDS
				);
				thread name=secondName action="run" storage=variables.other count=count results=results {
					var value = attributes.storage.getOrSet( "flag", function(){
						attributes.count.incrementAndGet();
						return false;
					} );
					attributes.results.put( "second", value );
				}
				thread action="join" name="#firstName#,#secondName#" timeout=10000;
				expect( started ).toBeTrue();
				expect( cfthread[ firstName ].status ).toBe( "COMPLETED" );
				expect( cfthread[ secondName ].status ).toBe( "COMPLETED" );
				expect( results.get( "first" ) ).toBeFalse();
				expect( results.get( "second" ) ).toBeFalse();
				expect( count.get() ).toBe( 1 );
			} );

			it( "writes a multi-set once and retains missing defaults and falsy values", function(){
				var before = variables.cache.writes.get();
				expect( variables.storage.setMulti( { first : false, second : 0, third : "" } ) ).toBe(
					variables.storage
				);
				expect( variables.cache.writes.get() - before ).toBe( 1 );
				expect( variables.other.get( "first" ) ).toBeFalse();
				expect( variables.other.get( "second" ) ).toBe( 0 );
				expect( variables.other.get( "third" ) ).toBe( "" );
				expect( variables.storage.get( "absent" ) ).toBeNull();
				expect( variables.storage.get( "absent", false ) ).toBeFalse();
			} );

			it( "delegates every bucket mutation and initialization to one stable lock name", function(){
				var names    = [];
				var provider = function( name, operation, timeout ){
					names.append( name );
					expect( timeout ).toBe( 20 );
					return operation();
				};
				var storage = buildStorage( provider );
				storage.removeStorage();
				expect( storage.getStorage() ).toHaveKey( "sessionid" );
				storage.set( "first", 1 ).setMulti( { second : 2 } );
				expect( storage.delete( "first" ) ).toBeTrue();
				expect( storage.delete( "absent" ) ).toBeFalse();
				expect(
					storage.getOrSet( "made", function(){
						return "value";
					} )
				).toBe( "value" );
				storage.clearAll().createStorage();
				expect( names ).toHaveLength( 9 );
				for ( var name in names ) {
					expect( name ).toBe( names[ 1 ] );
				}
				var other = buildStorage( provider );
				other.getStorage();
				expect( names[ 10 ] ).toBe( names[ 1 ] );
				variables.bucket = createUUID();
				buildStorage( provider ).getStorage();
				expect( names[ 11 ] ).notToBe( names[ 1 ] );
			} );

			it( "propagates lock acquisition failure without writing or producing", function(){
				var storage = buildStorage( function( name, operation, timeout ){
					throw( type = "StorageTest.LockUnavailable" );
				} );
				var before = variables.cache.writes.get();
				expect( function(){
					storage.set( "unsafe", true );
				} ).toThrow( "StorageTest.LockUnavailable" );
				expect( function(){
					storage.getOrSet( "unsafe", function(){
						fail( "Producer ran without a lock" );
					} );
				} ).toThrow( "StorageTest.LockUnavailable" );
				expect( variables.cache.writes.get() ).toBe( before );
			} );

			it( "rejects a non-callable configured lock provider", function(){
				expect( function(){
					buildStorage( "not-a-callback" );
				} ).toThrow( "CacheStorage.InvalidLockProvider" );
			} );

			it( "preserves deletion, clearing and removal contracts", function(){
				variables.storage.set( "first", 1 ).set( "second", 2 );
				expect( variables.other.delete( "first" ) ).toBeTrue();
				expect( variables.storage.get( "second" ) ).toBe( 2 );
				variables.other.clearAll();
				expect( variables.storage.getStorage() ).toBeEmpty();
				variables.storage.removeStorage();
				expect( variables.other.storageExists() ).toBeFalse();
			} );
		} );
	}

	private function buildStorage( lockProvider = "" ){
		var id = variables.bucket;
		return new cbstorages.models.CacheStorage(
			settings = {
				cacheStorage : {
					cacheName          : "concurrency",
					timeout            : 60,
					identifierProvider : function(){
						return id;
					},
					lockProvider : arguments.lockProvider
				}
			},
			cachebox = new tests.resources.StorageCacheFactory( variables.cache )
		);
	}

}
