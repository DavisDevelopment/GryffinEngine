package gryffin;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.media.Sound;
import motion.Actuate;

//- Gryffin imports
import gryffin.gss.GryffinStyles;
import gryffin.storage.LocalStorage;

@:expose class Stage extends Sprite {
	public var fps:Int;
	private var framesThisSecond:Int;
	private var _activated:Bool;
	private var selectors:Map<String, Selection>;
	private var env_vars:Map<String, Dynamic>;
	public var textures:NativeMap<String, BitmapData>;
	public var sounds:NativeMap<String, Sound>;
	public var shape:Shape;
	public var sprite:Sprite;
	public var sceneName:String;
	public var color:Int = 0xFF0000;
	public var radius:Int = 20;
	public var vx:Int;
	public var vy:Int;
	public var boundX:Int;
	public var boundY:Int;
	public var childNodes:Array<Entity>;
	public var surface:Surface;
	public var handlers:Map<String, Array<Dynamic->Dynamic>>;
	private var stylesheets:Array<Dynamic>;
	
	public function new( ?textureList:Map<String, String>, ?soundList:Map<String, String> ) {
		super();
		stages.push(this);

		this.fps = 0;
		this.framesThisSecond = 0;
		this.handlers = new Map();
		this.shape = new Shape();
		this.sprite = new Sprite();
		this.boundX = 200;
		this.boundY = 200;
		this.childNodes = [];
		this.sceneName = "game";
		this.selectors = new Map();
		this.stylesheets = new Array();
		this.env_vars = new Map();
		this.surface = new Surface( this.shape.graphics, this );
		if ( textureList != null ) this.textures = Utils.getTextures(textureList);
		else this.textures = Utils.getTextures(new Map());
		if ( soundList != null ) this.sounds = Utils.getSounds(soundList);
		else this.sounds = Utils.getSounds(new Map());
		
        addChild(shape);
        addChild(sprite);
		this.selectors.set("*", new Selection("*", this));
		this.init();

		this._activated = true;
	}
	private function init():Void {
		LocalStorage.init();
		this.startFPSCounter();
	}
	public function get( s:String ):Selection {
		var selector = this.selectors.get("*");
		if ( this.selectors.get(s) == null ) {
			selector = new Selection( s, this );
			this.selectors.set( s, selector );
		} else {
			selector = this.selectors.get(s);
			selector.update();
		}
		return selector;
	}
	
	public function add( item:Entity ) {
		this.childNodes.push( item );
		haxe.ds.ArraySort.sort(this.childNodes, function ( x:Entity, y:Entity ):Int {
			return (x.z + y.z);
		});
		this.emit('activate:${Types.basictype(item)}', item);
		item.emit('activate', this);
	}
	public function setChildren( items:Array <Entity> ) {
		for ( child in this.childNodes ) {
			child.destroy(this); //Run Child's destructor method
		}
		this.childNodes = items;
	}
	public function remove( ent:Entity ):Void {
		ent.destroy(this);
		var newChildren = this.childNodes.filter(function(x) {
			return x != ent;
		});
		this.childNodes = newChildren;
	}
	
	public function filter( f:Entity -> Bool ) {
		var kids:Array<Entity> = [];
		for ( ent in this.childNodes ) {
			if (f(ent)) kids.push(ent);
		}
		this.childNodes = kids;
	}
	
	public function render():Void {
		this.framesThisSecond++;

		if (!this._activated)
			return;
		#if html5
			this.shape.graphics.clear();
		#end
		for ( x in this.childNodes ) {
			var rot:Float = this.shape.rotation;
			this.shape.rotation = x.rotation;
			if ( !x._hidden ) x.render( this.surface, this );
			this.shape.rotation = rot;
		}
	}
	public function setBounds( x:Int, y:Int ) {
		this.boundX = x;
		this.boundY = y;
		this.emit("resize", {
			'width' : x,
			'height' : y
		});
	}
	
	public function update():Void {
		if (!this._activated)
			return;
		#if !html5
		removeChild( this.shape );
		this.shape = new Shape();
		this.surface.setGraphics( this.shape.graphics );
		addChild( this.shape );
		this.shape.addEventListener( "click", function( e:MouseEvent ):Void {
			this.handleEvent( e );
		});
		#end
		this.childNodes = this.childNodes.filter(function(ent) {
			return !ent.remove;
		});
		for ( x in this.childNodes ) {
			if ( !x._cache ) x.update( this.surface, this );
		}
		haxe.ds.ArraySort.sort(this.childNodes, function ( x:Entity, y:Entity ):Int {
			return (x.z - y.z);
		});
	}
	
	public function light() {
		for ( ent in this.childNodes ) {
			if ( ent.shaded ) ent.shade( this.surface, this );
		}
	}
	public function style(?filter:String):Void {
		for (runner in this.stylesheets) {
			if (Reflect.isFunction(runner)) {
				runner(this);
			}
		}
	}
	public function stylesheet(code:String):Void {
		// try {
			var runner:Stage->Void = GryffinStyles.compile(code);
			this.stylesheets.push(runner);
		// } catch (error : String) {
			// trace(error);
		// }
	}
	
	public function addEventHandler( type:String, func:Dynamic->Dynamic ) {
		if (this.handlers.exists(type)) this.handlers.get(type).push(func);
		else {
			var listOfHandlers:Array<Dynamic->Dynamic> = [];
			this.handlers.set(type, listOfHandlers);
			listOfHandlers.push(func);
		}
	}
	
	public function handleEvent( e:Dynamic, ?type:String ) {
		if ( type != null ) {
			if (this.handlers.exists(type)) for (f in this.handlers.get(type)) f(e);
		} else 	{
			if (Reflect.getProperty(e, "type") != null ) {
				if (this.handlers.exists(e.type)) for (f in this.handlers.get(e.type)) f(e);
			} else {
				trace("Event Trigger Failed");
			}
		}
		var x:Float = e.stageX;
		var y:Float = e.stageY;
		var children = this.childNodes.copy();
		children.reverse();
		for ( item in children ) {
			var touchingX:Bool = ( x > item.x && x < item.x + item.width );
			var touchingY:Bool = ( y > item.y && y < item.y + item.height );
			if ( touchingX && touchingY ) {
				if ( type != null ) {
					item.emit(type, e);
				} else {
					item.handleEvent( e );
				}
				break;
			}
		}
		return null;
	}
	//Various 'getter' functions
	public function getScene() {
		return this.sceneName;
	}
	
	//Other various 'setters'
	public function setScene( name:String ):Void {
		this.sceneName = name;
	}
	public function on( type:String, func:Dynamic -> Dynamic ):Void {
		this.addEventHandler( type, func );
	}
	public function emit( type:String, data:Dynamic ) {
		if (this.handlers.exists(type)) {
			for (f in this.handlers.get(type)) {
				f(data);
			}
		}
	}
	public function setEnv(name:String, value:Dynamic):Void {
		this.env_vars.set(name, value);
	}
	public function getEnv(name:String):Null<Dynamic> {
		return this.env_vars.get(name);
	}

	public function bindEvents( ?events:Array<String> ):Void {
		var me = this;
		if (events == null) {
			events = ['click', 'mouse-move', 'mouse-enter', 'mouse-leave'];
		}
		var clickHandler:Dynamic = function(event:flash.events.MouseEvent):Void {
			var gevent:Dynamic = new gryffin.events.GryffinEvent('click');
			gevent.x = event.stageX;
			gevent.y = event.stageY;
			var clicked:Null<gryffin.Entity> = null;
			me.emit('click', gevent);

			var children:Array<Entity> = me.get('!:_cache').toArray();
			haxe.ds.ArraySort.sort(children, function ( x:Entity, y:Entity ):Int {
				return (x.z - y.z);
			});
			for (child in children) {
				if (child.contains(event.stageX, event.stageY)) {
					if (!gevent.isDefaultPrevented) child.emit('click', gevent);
					clicked = child;
				}
			}
			for (x in me.childNodes) {
				if (x != clicked && !gevent.isDefaultPrevented) x.emit('stage:click', gevent);
			}
		};
		this.stage.addEventListener(flash.events.MouseEvent.CLICK, clickHandler);
		#if mobile
		this.stage.addEventListener(openfl.events.TouchEvent.TOUCH_TAP, clickHandler);
		#end

		var resizeHandler:Dynamic = function(event:flash.events.Event):Void {
			var gevent:Dynamic = new gryffin.events.GryffinEvent('resize');
			me.setBounds(me.stage.stageWidth, me.stage.stageHeight);
			me.emit('resize', gevent);
		};
		this.stage.addEventListener(flash.events.Event.RESIZE, resizeHandler);

		//- Mouse Move
		var moveHandler:Dynamic = function(event:flash.events.MouseEvent):Void {
			var gevent:gryffin.events.GryffinEvent = new gryffin.events.GryffinEvent('click');
			gevent.x = event.stageX;
			gevent.y = event.stageY;
			gevent.ctrlKey = event.ctrlKey;

			var clicked:Null<gryffin.Entity> = null;
			me.emit('mouse-move', gevent);
			var kids:Array<Entity> = [for (x in me.get('!:_cache')) x];
			for (kid in kids) {
				if (kid.contains(event.stageX, event.stageY)) {
					if (kid.mouse_over == false) {
						kid.mouse_over = true;
						kid.emit('mouse-enter', gevent);
					}
					kid.mouse_over = true;
				} else {
					if (kid.mouse_over == true) {
						kid.emit('mouse-leave', gevent);
					}
					kid.mouse_over = false;
				}
			}
		};
		this.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, moveHandler);

		var keyBoardHandler:Dynamic = function(event:flash.events.KeyboardEvent):Void {
			var type:String = '';
			switch (event.type) {
				case flash.events.KeyboardEvent.KEY_DOWN:
					type = "key-down";
				case flash.events.KeyboardEvent.KEY_UP:
					type = "key-up";
			}
			var gevent:gryffin.events.GryffinEvent = new gryffin.events.GryffinEvent(type);
			gevent.keyCode = event.keyCode;
			gevent.charCode = event.charCode;
			gevent.ctrlKey = event.ctrlKey;
			gevent.shiftKey = event.shiftKey;
			gevent.altKey = event.altKey;
			gevent.defaultAction = function():Void {
				if (getEnv('__focused__') != null) {
					var input:Entity = cast(getEnv('__focused__'), Entity);
					input.emit(type, gevent);
				}
			};
			me.emit('$type', gevent);
			gevent.performAction();
		};
		this.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, keyBoardHandler);
		this.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, keyBoardHandler);

		var scrollHandler:Dynamic = function (event:flash.events.Event):Void {
			trace(event);
		}

		this.stage.addEventListener(flash.events.Event.SCROLL, scrollHandler);
	}
	public function startFPSCounter():Void {
		var me = this;
		function frame() {
			if (me.fps == 0) {
				me.fps = me.framesThisSecond;
				me.framesThisSecond = 0;
			} else {
				me.fps = Math.round((me.fps + me.framesThisSecond) / 2);
				me.framesThisSecond = 0;
			}
			Actuate.timer(1).onComplete(frame);
		};
		Actuate.timer(1).onComplete(frame);
	}

	public function containsEntity( item:Entity ):Bool {
		var allOfType:Array<Entity> = this.get('.' + Types.basictype(item)).toArray();
		allOfType = allOfType.filter(function(x:Entity) {
			return (x.id == item.id);
		});
		return (allOfType.length != 0);
	}

	public static function getContainingStage( item:Entity ):Null<Stage> {
		for (stage in stages) {
			if (stage.containsEntity(item)) return stage;
		}
		return null;
	}

//= Private Internal Methods
	private static function ensureAssetsLoaded( inst:Stage ):Void {
		if (!_assetsLoaded) {
			_waitingForAssets.push(inst);
			inst.on('internal:assets-loaded', function(e:Dynamic):Dynamic {
				inst._activated = true;

				inst.emit('start', null);
				return null;
			});
		} else {
			inst.emit('internal:assets-loaded', null);
		}
	}

//= Private Internal Properties
	private static var stages:Array<Stage> = [];
	private static var _assetsLoaded:Bool;
	private static var _waitingForAssets:Array<Stage>;

//= Class Initialization Functions
	private static function __init__():Void {
		_assetsLoaded = false;
		_waitingForAssets = new Array();
		// gryffin.loaders.BaseLoader.on('initial:load-complete', function(fls:Array<Dynamic>):Void {
		// 	_assetsLoaded = true;
		// 	for (inst in _waitingForAssets) {
		// 		inst.emit('internal:assets-loaded', null);
		// 	}
		// });
		// gryffin.Assets.grabAssetFile('assets.json');
	}
}