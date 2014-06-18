package gryffin.geom;

class Point {
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new ( x:Float, y:Float, z:Float = 0 ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	public function distanceTo(other:Point):Float {
		return gryffin.Utils.distance(this.x, this.y, other.x, other.y);
	}
	public function is(x:Int, y:Int, z:Int = 0):Bool {
		return (this.x == x && this.y == y && this.z == z);
	}
}