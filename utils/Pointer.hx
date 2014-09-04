package gryffin.utils;

abstract Pointer<T>(PointerClass<T>) {
	private var self(get, never):Pointer<T>;
	public inline function new(gtr:Void->T):Void {
		this = new PointerClass(gtr);
	}
	private inline function get_self():Pointer<T> {
		return cast this;
	}
	
	@:to
	public inline function dereference():T {
		return this.dereference();
	}

	public inline function toString():String {
		return Std.string(self.dereference());
	}

	@:from
	public static inline function toConstant<T>(item : T):Pointer<T> {
		return cast PointerClass.fromPointerTypeInstance(PointerType.PTConstant(item));
	}

	@:from
	public static inline function fromGetter<T>(gtr:Void->T):Pointer<T> {
		return cast PointerClass.fromPointerTypeInstance(PointerType.PTGetter(gtr));
	}

	public static inline function toField<T>(obj:Dynamic, field:String):Pointer<T> {
		return cast PointerClass.fromPointerTypeInstance(PointerType.PTField(obj, field));
	}
}

class PointerClass<T> {
	private var getter:Void->T;

	public function new(gtr:Void->T):Void {
		this.getter = gtr;
	}

	public function dereference():T {
		return this.getter();
	}

	public static function fromPointerTypeInstance<T>(pti : PointerType):PointerClass<T> {
		var getter:Void->T;
		switch (pti) {
			case PointerType.PTConstant(item):
				getter = function() return item;
			case PointerType.PTGetter(gtr):
				getter = gtr;
			case PointerType.PTField(obj, field):
				getter = function() {
					return Reflect.getProperty(obj, field);
				};
			case PointerType.PTMethod(obj, method, args):
				getter = function() {
					var meth = Reflect.getProperty(obj, method);
					return Reflect.callMethod(obj, meth, args);
				};
		}
		return new PointerClass(getter);
	}
}

enum PointerType {
	PTConstant( item:Dynamic );
	PTGetter( gtr:Void->Dynamic );
	PTField( obj:Dynamic, field:String );
	PTMethod( obj:Dynamic, method:String, args:Array<Dynamic> );
}