package gryffin.io;

import gryffin.EventDispatcher;

class DataSource<T> extends EventDispatcher {
	public var supplier:Null<Void -> T>;

	public function new(?source:Void->T):Void {
		super();

		this.supplier = source;
	}
	public function put():Void {
		this.emit(DATA_AVAILABLE, this.get());
	}
	public function get():Null<T> {
		if (Reflect.isFunction(supplier)) {
			return supplier();
		} else {
			return null;
		}
	}

	public static inline var DATA_AVAILABLE:String = 'da';
}