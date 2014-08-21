package gryffin.loaders;

typedef MapElement = {
	name : String,
	textContent : String,
	attributes : Map<String, String>,
	childNodes : Array<MapElement>
};