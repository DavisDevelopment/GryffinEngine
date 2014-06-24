package gryffin.display;

class Tile extends Entity {
	public var texture:String;
	public var updateMe:Bool;
	public var type:String;
	public var lightLevel:Int;
	public function new( x, y, width, height, ?texture ) {
		super();
		
		this.x = x;
		this.y = y;
		this.z = 0;
		this.width = width;
		this.height = height;
		this.texture = texture;
		this.lightLevel = 12;
	}
	public function collide( obj:Entity, stage:Stage ):Void {
		'stuff';
	}
}