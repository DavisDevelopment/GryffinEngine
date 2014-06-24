package gryffin;

class Stack {
	public var funcs:Array < Dynamic >;
	public var complete:Array < Dynamic >;
	public var parametric:Bool;
	
	public function new( ?parametric:Bool ) {
		this.funcs = new Array();
		this.complete = new Array();
		this.parametric = parametric;
	}
	public function push( f:Dynamic ):Void {
		this.funcs.push(f);
	}
	public function pop():Void {
		this.funcs.pop();
	}
	public function unshift( f:Dynamic ):Void {
		this.funcs.unshift( f );
	}
	public function shift():Dynamic {
		return this.funcs.shift();
	}
	public function onComplete( f:Dynamic ):Void {
		this.complete.push( f );
	}
	public function call( ?parameters:Dynamic ):Void {
		if ( this.parametric && parameters == null ) parameters = {};
		var self = this;
		var index:Int = 0;
		function callNext() {
			index++;
			var func = self.funcs[index];
			if ( func != null ) {
				if (Reflect.isFunction(func)) {
					var args:Array < Dynamic > = [ callNext, parameters ];
					try {
						Reflect.callMethod(null, func, args);
					} catch ( error : String ) {
						Reflect.callMethod(null, func, [callNext]);
						trace( error );
					}
				}
			} else {
				for ( func in this.complete ) {
					if (Reflect.isFunction(func)) {
						Reflect.callMethod(null, func, []);
					}
				}
			}
		};
		try {
			(self.funcs[0])( callNext );
		} catch ( error : String ) {
			(self.funcs[0])( callNext, parameters );
		}
	}
}