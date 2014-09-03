package gryffin.utils;

abstract DynamicObject( Dynamic ) {
	public inline function new(x : Dynamic):Void {
		this = x;
	}
	public inline function keys():Array<String> {
		return Reflect.fields(this);
	}
	@:arrayAccess
	public inline function get(key : String):Null<Dynamic> {
		return Reflect.getProperty(this, key);
	}
	@:arrayAccess
	public inline function set(key:String, value:Dynamic):Dynamic {
		Reflect.setProperty(this, key, value);
		return value;
	}
	public inline function has(key : String):Bool {
		return (get(key) != null);
	}
	public inline function hasMethod(key : String):Bool {
		return Reflect.isFunction(get(key));
	}
	public inline function call(key:String, ?args:Array<Dynamic>):Dynamic {
		if (args == null) args = new Array();
		var func:Dynamic = Reflect.getProperty(this, key);
		var ret:Dynamic = null;

		if (Reflect.isFunction(func)) ret = Reflect.callMethod(this, func, args);

		return ret;
	}

	@:from
	public static inline function autoCast(x : Dynamic):DynamicObject {
		return new DynamicObject(x);
	}
}