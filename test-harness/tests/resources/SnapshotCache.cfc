/** A detached-value cache, like a serialized remote CacheBox provider. */
component {

	function init(){
		variables.entries = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		variables.slow    = createObject( "java", "java.util.concurrent.atomic.AtomicBoolean" ).init( false );
		this.firstRead    = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );
		this.writes       = createObject( "java", "java.util.concurrent.atomic.AtomicInteger" ).init( 0 );
		return this;
	}

	function get( required key ){
		var value = variables.entries.get( arguments.key );
		if ( !isNull( local.value ) ) {
			value = duplicate( value );
		}
		if ( variables.slow.compareAndSet( true, false ) ) {
			this.firstRead.countDown();
			createObject( "java", "java.util.concurrent.CountDownLatch" )
				.init( 1 )
				.await(
					javacast( "long", 400 ),
					createObject( "java", "java.util.concurrent.TimeUnit" ).MILLISECONDS
				);
		}
		if ( !isNull( local.value ) ) {
			return value;
		}
	}

	function set(
		required key,
		required value,
		timeout           = 60,
		lastAccessTimeout = 0
	){
		variables.entries.put( arguments.key, duplicate( arguments.value ) );
		this.writes.incrementAndGet();
		return this;
	}

	function clear( required key ){
		variables.entries.remove( arguments.key );
		return true;
	}

	function lookup( required key ){
		return variables.entries.containsKey( arguments.key );
	}

	function delayNextRead(){
		variables.slow.set( true );
		return this;
	}

}
