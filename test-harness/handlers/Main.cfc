component{


	function index( event, rc, prc ){
		getInstance( "ApplicationStorage@cbStorages" );
		getInstance( "ClientStorage@cbStorages" );
		getInstance( "CacheStorage@cbStorages" );
		getInstance( "CookieStorage@cbStorages" );
		getInstance( "RequestStorage@cbStorages" );
		getInstance( "SessionStorage@cbStorages" );

		return "<h1>CB Storages</h1>";
	}

}