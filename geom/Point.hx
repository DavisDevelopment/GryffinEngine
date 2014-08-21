package gryffin.geom;

class Point {
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new ( x:Float = 0, y:Float = 0, z:Float = 0 ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	public inline function distanceTo(other:Point):Float {
		return gryffin.Utils.distance(this.x, this.y, other.x, other.y);
	}
	public inline function relativeTo(other:Point):Point {
		return new Point((this.x - other.x), (this.y - other.y), (this.z - other.z));
	}
	public inline function is(x:Int, y:Int, z:Int = 0):Bool {
		return (this.x == x && this.y == y && this.z == z);
	}
	public inline function clone():Point {
		return new Point(this.x, this.y, this.z);
	}
}