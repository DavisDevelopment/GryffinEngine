package gryffin;
import flash.events.MouseEvent;
import flash.events.Event;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import motion.Actuate;

class Entity implements EventSensitive {
	public var stage(get, set):Null<Stage>;
	public var parent(get, never):Entity;
	public var id:String;
	public var width:Int;
	public var height:Int;
	public var x:Int;
	public var y:Int;
	public var z:Int;
	public var vx:Float;
	public var vy:Float;
	public var rotation:Float;
	public var handlers:Map<String, Array<Dynamic -> Dynamic>>;
	public var remove:Bool;
	public var mouse_over:Bool;
	public var shaded:Bool;
	public var _hidden:Bool;
	public var _cache:Bool;

	public function new() {
		this.id = (Types.basictype(this) + '-' + gryffin.utils.Memory.uniqueID());
		this.width = 0;
		this.height = 0;
		this.x = 0;
		this.y = 0;
		this.z = 0;
		this.vx = 0;
		this.vy = 0;
		this.rotation = 0;
		this.handlers = new Map();
		this.remove = false;
		this.mouse_over = false;
		this.shaded = false;
		this._hidden = false;
		this._cache = false;
	}
	
	public function render( g:Surface, s:Stage ):Void {
		this.emit('render', this);
	}
	
	public function update( g:Surface, s:Stage ):Void {
		var stuff:String = "stuff";
	}
	public function is( sel:String ):Bool {
		var selector = Selector.compile(sel);
		return selector(this);
	}
	public function collidesWith( o:Dynamic ):Bool {
		var myRect:Rectangle = new Rectangle([this.x, this.y, this.z], [this.width, this.height]);
		var theirRect:Rectangle = new Rectangle([o.x, o.y, o.z], [o.width, o.height]);
		return myRect.collidesWith( theirRect );
	}
	public function contains(x:Float, y:Float, ?z:Float):Bool {
		var mx:Float = this.x;
		var my:Float = this.y;
		// if (this.parent != null && this.parent.is(':_cascading')) {
		// 	mx += this.parent.x;
		// 	my += this.parent.y;
		// }
		var myRect:Rectangle = new Rectangle([mx, my, this.z], [this.width, this.height]);
		if (z == null) z = this.z;
		var pt:Point = new Point(x, y, z);
		return myRect.contains(pt);
	}
	public function getHitmask():Array<Point> {
		var points:Array<Point> = [];
		for (x in this.x...this.width) {
			for (y in this.x...this.height) {
				points.push(new Point(x, y, this.z));
			}
		}
		return points;
	}
	public function addEventHandler( type:String, f:Dynamic -> Dynamic ):Void {
		if (this.handlers.exists(type)) {
			this.handlers.get(type).push(f);
		} else {
			var list:Array < Dynamic -> Dynamic > = [f];
			this.handlers.set(type, list);
		}
	}
	public function on( type:String, f:Dynamic -> Dynamic ):Void {
		this.addEventHandler( type, f );
	}
	public function once( type:String, f:Dynamic->Dynamic ):Void {
		var me = this;
		this.on(type, Utils.invokeOnce(function(data:Dynamic):Dynamic {
			return f(data);
		}));
	}
	public function unbind( type:String ):Void {
		this.handlers.remove( type );
	}
	public function emit( type:String, data:Dynamic ):Void {
		for ( key in this.handlers.keys() ) {
			if ( key.indexOf(type) == 0 ) {
				for (f in this.handlers.get(key)) {
					Reflect.callMethod( this, f, [data] );
				}
			}
		}
		if (type != '*') {
			var starData:Array<Dynamic> = [type, data];
			this.emit('*', starData);
		}
	}
	public function handleEvent( e:Event ):Void {
		if (this.handlers.exists(e.type)) for (f in this.handlers.get(e.type)) {
			f(e);
		}
	}
	public function animate( duration:Float, props:Dynamic ):Void {
		if (Reflect.getProperty(props, "complete") != null) {
			var done = props.complete;
			Reflect.deleteField(props, "complete");
			Actuate.tween( this, duration, props ).onComplete( done, null );
		} else {
			Actuate.tween( this, duration, props );
		}
	}
	public function destroy(s:Stage):Void {
		this.emit("destroy", s);
		this.remove = true;
	}
	public function shade( g:Surface, stage:Stage ) {
		"stuff";
	}
	public function getLightLevel( distanceFromLight:Float ):Float {
		var dis = distanceFromLight;
		var increment = 20;
		if ( dis < increment ) return 32;
		else {
			if ( dis % increment == 0 ) return (32-(dis/increment)-1);
			while ( dis % increment != 0 ) --dis;
			return (32 - (dis/increment) - 1);
		}
	}
	public function hide():Void {
		this._hidden = true;
		this.emit('hide', null);
	}
	public function show():Void {
		this._hidden = false;
		this.emit('show', null);
	}
	public function cache():Void {
		this._cache = true;
		this.emit('cache', null);
	}
	public function uncache():Void {
		this._cache = false;
		this.emit('uncache', null);
	}
	private function get_stage():Null<Stage> {
		return Stage.getContainingStage(this);
	}
	private function set_stage(s:Stage):Stage {
		if (this.stage != null) this.stage.remove(this);
		s.add(this);
		return s;
	}
	private function get_parent():Null<Entity> {
		if (this.stage != null) {
			var ents:Array<Entity> = this.stage.get('[childNodes][_cascading]').toArray();
			for (ent in ents) {
				var kids:Array<Dynamic> = cast(Reflect.getProperty(ent, 'childNodes'), Array<Dynamic>);
				if (Lambda.has(kids, this)) return ent;
			}
			return null;
		} else {
			return null;
		}
	}
}