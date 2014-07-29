package gryffin.loaders;

interface Parent<T> {
	public var _cascading:Bool;
	public var childNodes:Array<T>;
	public function add(item:T):Void;
}