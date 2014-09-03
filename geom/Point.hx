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
	public inline function angleTo(other:Point):Float {
		return gryffin.Utils.angleBetween(this.x, this.y, other.x, other.y);
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

/*
 * The Point class will eventually be an abstract class, using an Array<Int> in the background.
 * Below is the basis for the implementation
 */
/*
abstract Point(Array<Float>) {
	public var self(get, never):Point;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;

	public inline function new(x:Float = 0, y:Float = 0, z:Float = 0):Void {
		this = [x, y, z];
	}
	private inline function get_self():Point {
		return cast this;
	}
	public inline function distanceTo(other:Point):Float {
		return 0;
	}
	public inline function angleTo(other:Point):Float {
		return 0;
	}
	public inline function relativeTo(other:Point):Float {
		return new Point();
	}
	@:op(A == B)
	public inline function equals(other:Point):Bool {
		return (self.x == other.x && self.y == other.y && self.z == other.z);
	}
	public inline function is(x:Float, y:Float, z:Float = 0):Bool {
		return (self == new Point(x, y, z));
	}
	public inline function clone():Point {
		return cast this.copy();
	}
//- Getter Methods
	private inline function get_x():Float {
		return this[0];
	}
	private inline function get_y():Float {
		return this[1];
	}
	private inline function get_z():Float {
		return this[2];
	}
//- Setter Methods
	private inline function set_x(nx:Float):Float {
		this[0] = nx;
		return this[0];
	}
	private inline function set_y(ny:Float):Float {
		this[1] = ny;
		return this[1];
	}
	private inline function set_z(nz:Float):Float {
		this[2] = nz;
		return this[2];
	}
}
*/