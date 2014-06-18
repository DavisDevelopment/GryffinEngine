package gryffin;

interface EventSensitive {
	function on( type:String, f:Dynamic -> Dynamic ):Void;
	function unbind( type:String ):Void;
	function emit( type:String, data:Dynamic ):Void;
}