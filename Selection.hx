package gryffin;

typedef Handler = Dynamic -> Dynamic;

class Selection {
	public var items:Array < Entity >;
	public var length(get, never):Int;
	public var selector:String;
	public var selectorFunction: Entity -> Bool;
	public var stage:Stage;
	public function new( sel:String, stage:Stage ) {
		this.stage = stage;
		this.selector = sel;
		this.selectorFunction = this.getSelectorFunction(sel);
		this.items = this.getMatches(stage.childNodes);
		
	}
	private function getMatches( set:Array<Dynamic> ):Array<Entity> {
		var result:Array < Dynamic > = [];
		for ( item in set ) {
			var add:Bool = this.selectorFunction(item);
			if ( add ) result.push(item);
			if (Utils.hasField(item, "childNodes")) {
				result = result.concat(this.getMatches(cast(Reflect.getProperty(item, "childNodes"), Array<Dynamic>)));
			}
		}
		return [for (x in result) cast(x, Entity)];
	}
	public function update():Void {
		this.items = this.getMatches(this.stage.childNodes);
	}
	public function at( pos:Int ):Entity {
		return this.items[pos];
	}
	public function iterator():Iterator < Entity > {
		return this.items.iterator();
	}
	@:to public function toArray():Array<Entity> {
		return [for (x in this) x];
	}
	public function each(lambdaFunc:Entity->Int->Void):Void {
		var i:Int = 0;
		for (ent in this) {
			lambdaFunc(ent, i);
			i++;
		}
	}
	public function is( filter:String ):Bool {
		var selFunc:Entity->Bool = this.getSelectorFunction(filter);
		return (this.at(0).is(filter));
	}
	public function on( type:String, f:Handler ):Void {
		for ( item in this.items ) item.on( type, f );
	}
	public function emit( type:String, data:Dynamic ):Void {
		for ( item in this.items ) item.emit( type, data );
	}
	public function bind( handlerObject:Dynamic ):Void {
		var type:String = Types.typename(handlerObject);
		if (type == "Object<String, Function") {
			var keys:Array<String> = Reflect.fields(handlerObject);
			for ( key in keys ) {
				var prop:Dynamic = Reflect.getProperty(handlerObject, key);
				this.on(type, prop);
			}
		} else {
			trace( type );
		}
	}
	public function unbind( type:String ):Void {
		for ( item in this.items ) {
			if(item.handlers.exists(type)) {
				item.handlers.remove(type);
			}
		}
	}
	public function call(method:String, args:Array<Dynamic>):Void {
		for ( item in this.items ) {
			var func:Dynamic = Reflect.getProperty(item, method);
			try {
				Reflect.callMethod(item, func, args);
			} catch ( error:String ) {
				null;
			}
		}
	}
	public function destroy( ?filter:String ):Void {
		for ( item in this.items ) {
			if ( filter != null ) {
				if (item.is(filter)) {
					item.remove = true;
					item.destroy(this.stage);
				}
			} else {
				item.remove = true;
				item.destroy( this.stage );
			}
		}
	}
	public function cache():Void {
		for ( item in this.items ) {
			item.cache();
		}
	}
	public function uncache():Void {
		for ( item in this.items ) {
			item.uncache();
		}
	}
	public function hide():Void {
		for ( item in this.items ) {
			item.hide();
		}
	}
	public function show():Void {
		for ( item in this.items ) {
			item.show();
		}
	}
	private inline function get_length():Int {
		return (this.items.length);
	}

	private function getSelectorFunction(sel:String):Entity->Bool {
		if (_useCache && _filterCache.exists(sel)) {
			return _filterCache.get(sel);
		} else {
			var selFunc:Entity->Bool = Selector.compile(sel);
			_filterCache.set(sel, selFunc);
			return selFunc;
		}
	}

	private static var _filterCache:Map<String, Entity->Bool>;
	private static var _useCache:Bool = false;
	private static function __init__():Void {
		_filterCache = new Map();
	}
}