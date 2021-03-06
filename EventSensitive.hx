package gryffin;

interface EventSensitive {
	function on( type:String, f:Dynamic, ?once:Bool ):Void;
	function unbind( type:String ):Void;
	function emit( type:String, data:Dynamic ):Void;
}