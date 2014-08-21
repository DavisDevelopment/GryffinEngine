package gryffin.geom;

import gryffin.geom.Point;
import gryffin.Utils;
import gryffin.Entity;

class Ray {
	public var origin:Point;

	//- Expects Radians
	public var angle:Float;

	public function new(orig:Point, angle:Float):Void {
		this.origin = orig;
		this.angle = angle;//Math.abs(angle);
	}
	public function points(distance:Int):Array<Point> {
		var pointList:Array<Point> = new Array();
		var lastPoint:Point = this.origin;

		var x:Float = this.origin.x;
		var y:Float = this.origin.y;

		do {
			x += Math.cos(angle);
			y += Math.sin(angle);
			lastPoint = new Point(x, y);
			pointList.push(lastPoint);
		} while (Math.round(this.origin.distanceTo(lastPoint)) <= distance);

		return pointList;
	}
	public inline function intersects(ent:Entity):Bool {
		var corners:Array<Point> = ent.getCorners();
		var farthest:Null<Point> = Utils.arrayLargest(corners, function(x:Point) return origin.distanceTo(x));
		if (farthest == null) return false;

		var mask = this.points(Math.round(this.origin.distanceTo(farthest)));

		for (point in mask) {
			if (ent.rect.contains(point)) return true;
		}

		return false;
	}
}