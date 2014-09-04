package gryffin;
import flash.events.MouseEvent;
import flash.events.Event;

import gryffin.EventDispatcher;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import motion.Actuate;

class Entity extends EventDispatcher implements EventSensitive {
	private var to_autoemit:Map<String, Dynamic>;

	public var stage(get, set):Null<Stage>;
	public var parent(get, never):Entity;
	public var rect(get, never):Rectangle;
	
	public var id:String;
	public var width:Int;
	public var height:Int;
	public var x:Int;
	public var y:Int;
	public var z:Int;
	public var vx:Float;
	public var vy:Float;
	public var rotation:Float;
	public var remove:Bool;
	public var mouse_over:Bool;
	public var shaded:Bool;
	public var _hidden:Bool;
	public var _cache:Bool;

	public function new() {
		super();

		this.to_autoemit = new Map();

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
		this.emit('update', this);
	}
	public function is( sel:String ):Bool {
		var selector = Selector.compile(sel);
		return selector(this);
	}
	public function describe():String {
		return '."${Types.basictype(this)}"#"$id"';
	}
	private function should_autoemit(channel:String):Bool {
		var autoers:Array<String> = [for (channl in to_autoemit.keys()) channl];
		return Lambda.has(autoers, channel);
	}
	private inline function get_rect():Rectangle {
		return new Rectangle([this.x, this.y, this.z], [this.width, this.height]);
	}
	public function collidesWith( o:Dynamic ):Bool {
		var myRect:Rectangle = new Rectangle([this.x, this.y, this.z], [this.width, this.height]);
		var theirRect:Rectangle = new Rectangle([o.x, o.y, o.z], [o.width, o.height]);
		return myRect.collidesWith( theirRect );
	}
	public function contains(x:Float, y:Float, ?z:Float):Bool {
		var mx:Float = this.x;
		var my:Float = this.y;
		var myRect:Rectangle = new Rectangle([this.x, this.y, this.z], [this.width, this.height]);
		if (z == null) z = this.z;
		var pt:Point = new Point(x, y, z);
		return myRect.contains(pt);
	}
	public function getCorners():Array<Point> {
		var points:Array<Point> = new Array();
		var rect:Rectangle = new Rectangle([this.x, this.y, this.z], [this.width, this.height]);

		points.push(new Point(rect.x, rect.y, rect.z));
		points.push(new Point(rect.x + rect.width, rect.y, rect.z));
		points.push(new Point(rect.x + rect.width, rect.y + rect.height, rect.z));
		points.push(new Point(rect.x, rect.y + rect.height, rect.z));

		return points;
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
	public function delayCall(delay:Float, name:String, args:Array<Dynamic>):Void {
		var method:Dynamic = Reflect.getProperty(this, name);
		var me = this;
		Actuate.timer(delay).onComplete(function() {
			Reflect.callMethod(me, method, args);
		}, null);
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
	override public function listen(channel:String, handler:Dynamic, once:Bool = false):Void {
		if (!should_autoemit(channel)) {
			super.listen(channel, handler, once);
		} else {
			this.callHandler(this.makeHandler(channel, handler, once), to_autoemit[channel]);
		}
	}
	public function autoemit(channel:String, msg:Dynamic):Void {
		this.emit(channel, msg);
		this.to_autoemit[channel] = msg;
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