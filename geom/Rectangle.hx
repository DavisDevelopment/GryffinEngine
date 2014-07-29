package gryffin.geom;

import gryffin.geom.Point;

class Rectangle {
	public var x:Float;
	public var y:Float;
	public var z:Null<Float>;
	public var width:Float;
	public var height:Float;
	
	public function new( pos:Array < Float >, area:Array < Float >) {
		this.x = pos[0];
		this.y = pos[1];
		this.z = pos[2];
		if ( this.z == null ) this.z = 0;
		this.width = area[0];
		this.height = area[1];
	}
	public function collidesWith( other:Rectangle ):Bool {
		var collideX:Bool = (this.x + this.width > other.x && this.x < other.x + other.width);
		var collideY:Bool = ( this.y + this.height > other.y && this.y < other.y + other.height );
		var sameZ:Bool = ( this.z == other.z );
		return ( sameZ && collideX && collideY );
	}
	public function contains( p:Point ):Bool {
		var inX:Bool = ( p.x > this.x && p.x < this.x + this.width );
		var inY:Bool = ( p.y > this.y && p.y < this.y + this.height );
		var sameZ:Bool = ( this.z == p.z );
		return ( sameZ && inX && inY );
	}
	public function points():Array<Point> {
		var pointlist:Array<Point> = new Array();
		for (x in Std.int(this.x)...Std.int(this.x + this.width)) {
			for (y in Std.int(this.y)...Std.int(this.y + this.height)) {
				var p:Point = new Point(x, y);
				pointlist.push(p);
			}
		}
		return pointlist;
	}
}