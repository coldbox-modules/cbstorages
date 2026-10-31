component {

	function init( required cache ){
		variables.cache = arguments.cache;
		return this;
	}
	function getCache( required name ){
		return variables.cache;
	}

}
