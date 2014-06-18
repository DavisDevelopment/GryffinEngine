package gryffin;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.media.Sound;
import motion.Actuate;

@:expose class Stage extends Sprite {
	private var selectors:Map<String, Selection>;
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
	
	public function new( ?textureList:Map<String, String>, ?soundList:Map<String, String> ) {
		super();
		stages.push(this);
		this.handlers = new Map();
		this.shape = new Shape();
		this.sprite = new Sprite();
		this.boundX = 200;
		this.boundY = 200;
		this.childNodes = [];
		this.sceneName = "game";
		this.selectors = new Map();
		this.surface = new Surface( this.shape.graphics, this );
		if ( textureList != null ) this.textures = Utils.getTextures(textureList);
		else this.textures = Utils.getTextures(new Map());
		if ( soundList != null ) this.sounds = Utils.getSounds(soundList);
		else this.sounds = Utils.getSounds(new Map());
		
        addChild(shape);
        addChild(sprite);
		this.selectors.set("*", new Selection("*", this));
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
	
	public function render() {
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

	private static var stages:Array<Stage> = [];
}