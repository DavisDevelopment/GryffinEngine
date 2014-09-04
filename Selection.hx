package gryffin;

import gryffin.Entity;

typedef Handler = Dynamic -> Dynamic;

@:forward(
	live_handlers,
	from_array,
	_stage,
	items,
	selector,
	selectorFunction,
	get_stage,getMatches,
	update,
	at,
	indexOf,
	iterator,
	toArray,
	each,
	is,
	filter,
	on,
	emit,
	bind,
	unbind,
	live,
	call,
	attr,
	destroy,
	contains,
	cache,
	uncache,
	hide,
	show,
	length,
	getSelectorFunction
)
abstract Selection(ISelection) {
	private var self(get, never):Selection;
	public inline function new(sel:String, ?stage:Null<Stage>):Void {
		this = new ISelection(sel, stage);
	}
	private inline function get_self():Selection {
		return cast this;
	}
	public inline function iterator():Iterator<Entity> {
		return this.iterator();
	}
	@:arrayAccess
	public inline function grab(index : Int):Null<Entity> {
		return this.at(index);
	}
/*
 == Operator Methods ==
*/	
	@:op(A + B)
	public inline function plusSelection(other : Selection):Selection {
		//var self:Selection = cast this;
		var selector:String = '(${self.selector})|(${other.selector})';
		return new Selection(selector);
	}
	@:op(A + B)
	public inline function plusString(other : String):Selection {
		return new Selection('(${this.selector})|(other)');
	}
	@:op(A + B)
	public inline function plusEntity(other : Entity):Selection {
		//var self:Selection = cast this;
		return (self + other.describe());
	}
	@:op(A + B)
	public inline function plusEntityArray(others:Array<Entity>):Selection {
		//var self:Selection = cast this;
		return (self + ([for (ent in others) ('('+ent.describe()+')')].join('|')));
	}

	@:op(A - B)
	public inline function minusString(filter : String):Selection {
		return new Selection(self.selector + ('&!($filter)'));
	}

	@:op(A - B)
	public inline function minusSelection(other : Selection):Selection {
		return (self - other.selector);
	}

	@:op(A - B)
	public inline function minusEntity(other : Entity):Selection {
		return (self - other.describe());
	}

	@:op(A - B)
	public inline function minusEntityArray(others : Array<Entity>):Selection {
		return (self - arraySelectorString(others));
	}

/*
 == Implicit Casting Methods ==
*/
	@:to 
	public inline function toISelection():ISelection {
		return this;
	}
	@:to 
	public inline function toArray():Array<Entity> {
		return this.toArray();
	}
	@:to 
	public inline function toString():String {
		return ([for (ent in this.toArray()) ('('+ent.describe()+')')].join('|'));
	}

	@:from 
	public static inline function fromISelection(prim : ISelection):Selection {
		return cast prim;
	}
	@:from 
	public static inline function fromString(sel:String):Selection {
		return new Selection(sel + '');
	}
	@:from 
	public static inline function fromEntity(ent:Entity):Selection {
		return new Selection(ent.describe());
	}
	@:from
	public static inline function fromArray(ent_set:Array<Entity>):Selection {
		var selectors:Array<String> = [for (ent in ent_set) ('('+ent.describe()+')')];
		var selector:String = (ent_set.length > 0 ? selectors.join('|') : '!*');
		return new Selection(selector);
	}

	private static inline function arraySelectorString(others:Array<Entity>):String {
		return ([for (ent in others) ('('+ent.describe()+')')].join('|'));
	}
}

class ISelection {
	private var live_handlers:Map<String, Array<Dynamic>>;
	public var from_array:Bool;
	private var _stage:Stage;

	public var items:Array < Entity >;
	public var length(get, never):Int;
	public var selector:String;
	public var selectorFunction: Entity -> Bool;

	public var stage(get, never):Stage;
	public function new(sel:String, ?stage:Null<Stage>):Void {
		if (stage == null)
			stage = Stage.stages[0];

		this.live_handlers = new Map();
		this.selector = sel;
		this.selectorFunction = this.getSelectorFunction(sel);

		this.items = this.getMatches(stage.childNodes);

		this.from_array = false;
	}
	private inline function get_stage():Stage {
		return Stage.stages[0];
	}
	private function getMatches( set:Array<Dynamic> ):Array<Entity> {
		if (this.from_array) {
			return this.items;
		} else {
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
	}
	public function update():Void {
		this.items = this.getMatches(this.stage.childNodes);
	}
	public inline function at( pos:Int ):Entity {
		return this.items[pos];
	}
	public inline function indexOf(ent : Entity):Int {
		return this.items.indexOf(ent);
	}
	public inline function iterator():Iterator < Entity > {
		return this.items.iterator();
	}
	public inline function toArray():Array<Entity> {
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
	public inline function filter(description:String):Selection {
		return new Selection('($selector)&($description)');
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
	public inline function live(channel:String, handler:Dynamic):Void {
		this.stage.live(selector, channel, handler);
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
	public inline function attr(key:String):Null<Dynamic> {
		return Reflect.getProperty(this.at(0), key);
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
	public function contains(x:Float, y:Float, ?z:Float):Array<Entity> {
		var i = Math.round.bind(_);
		var thatContained:Array<Entity> = [];
		for (item in this.items) {
			if (item.contains(x, y, z)) thatContained.push(item);
		}
		return thatContained;
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

	public static function fromArray(list : Array<Entity>):Selection {
		var dummy:Selection = new Selection("*");
		dummy.items = list;
		dummy.from_array = true;

		return dummy;
	}
}