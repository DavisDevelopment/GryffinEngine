package gryffin.geom;

import gryffin.Utils;
import gryffin.geom.Point;
import gryffin.geom.Rectangle;
import gryffin.geom.Mask;

abstract Vector<T : Point>(IVector<T>) {

	public var angle(get, never):Float;
	public var points(get, never):Mask<T>;
	public var rect(get, never):Rectangle;

	public inline function new(x:T, y:T) {
		this = new IVector(x, y);

		get_points();
	}

	private function get_points():Mask<T> {
		if (this._points == null) {
			var distance:Float = Utils.distance(this.originPoint().x, this.originPoint().y, this.farthestPoint().x, this.farthestPoint().y);
			var pointList:Mask<T> = new Mask();
			var lastPoint:Point = this.originPoint();

			var x:Float = this.originPoint().x;
			var y:Float = this.originPoint().y;

			do {
				x += Math.cos(angle);
				y += Math.sin(angle);
				lastPoint = new Point(x, y);
				pointList.push(cast lastPoint);
			} while (Math.round(this.originPoint().distanceTo(lastPoint)) <= distance);

			this._points = pointList;
			return pointList;
		} else {
			return this._points;
		}
	}

	private function get_rect():Rectangle {
		var origin:Point = this.originPoint();
		var farthest:Point = this.farthestPoint();
		return new Rectangle([origin.x, origin.y], [origin.x + farthest.x, origin.y + farthest.y]);
	}

	private inline function get_angle():Float {
		return Utils.angleBetween(this.start.x, this.start.y, this.end.x, this.end.y);
	}
}

class IVector<T : Point> {
	public var start:T;
	public var end:T;
	public var _points:Null<Mask<T>>;

	public function new(start:T, end:T):Void {
		this.start = start;
		this.end = end;

		this._points = null;
		var x = cast(this, Vector<Dynamic>).points;
		trace(this._points);
	}

//= Private Helpers
	public function originPoint():Point {
		var lowestX:Point = Utils.arraySmallest(_points, function(x) return x.x);
		var lowestY:Point = Utils.arraySmallest(_points, function(x) return x.y);
		return new Point(lowestX.x, lowestY.y);
	}
	public function farthestPoint():Point {
		var highestX:Point = Utils.arrayLargest(_points, function(x) return x.x);
		var highestY:Point = Utils.arrayLargest(_points, function(x) return x.y);
		return new Point(highestX.x, highestY.y);
	}
}