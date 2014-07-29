package gryffin.geom;

import gryffin.Utils;
import gryffin.geom.Point;
import gryffin.geom.Rectangle;
import gryffin.geom.PathComponent;

class Path {
	public var components:Array<PathComponent>;

	public function new() {
		this.components = new Array();
	}
	public function reset():Void {
		this.components = new Array();
	}
	public function getContainingRectangle():Rectangle {
		var lowest = originPoint();
		var highest = farthestPoint();
		return new Rectangle([lowest.x, lowest.y], [(highest.x - lowest.x), (highest.y - lowest.y)]);
	}
	public function getHitmask():Array<Point> {
		var points:Array<Point> = [];
		for (command in this.components) {
			points = points.concat(getComponentPoints(command));
		}
		return points;
	}
	public function getComponentPoints(command:PathComponent):Array<Point> {
		switch (command) {
			case PathComponent.CLine(sx, sy, dx, dy):
				var pts:Array<Point> = new Array();
				var distance:Int = Utils.distance(sx, sy, dx, dy);
				var angle:Float = Utils.angleBetween(sx, sy, dx, dy);
				angle = Utils.radians(angle);
				var x:Float = sx;
				var y:Float = sy;
				while (!(Math.round(x) == dx && Math.round(y) == dy)) {
					pts.push(new Point(x, y, 0));
					x += Math.cos(angle);
					y += Math.sin(angle);
				}
				pts.push(new Point(x, y, 0));
				alignPoints(pts);
				return pts;

			case PathComponent.CRect(x, y, width, height):
				var pts:Array<Point> = (new Rectangle([x, y], [width, height]).points());
				alignPoints(pts);
				return pts;

			default:
				return [];
		}
	}
	public function alignPoints(points:Array<Point>):Array<Point> {
		for (pt in points) {
			pt.x = Std.int(pt.x);
			pt.y = Std.int(pt.y);
			pt.z = Std.int(pt.z);
		}
		return points;
	}
//= Path Creation Methods
	public function command(com:PathComponent):Void {
		this.components.push(com);
	}
	public function line(sx:Float, sy:Float, dx:Float, dy:Float):Void {
		var fcoords:Array<Float> = [sx, sy, dx, dy];
		var coords:Array<Int> = [for (x in fcoords) Std.int(x)];
		command(Type.createEnum(PathComponent, 'CLine', coords));
	}
	public function rect(x:Float, y:Float, width:Float, height:Float):Void {
		var fcoords:Array<Float> = [x, y, width, height];
		var coords:Array<Int> = [for (i in fcoords) Std.int(i)];
		command(Type.createEnum(PathComponent, 'CRect', coords));
	}

//= Private Helpers
	private function originPoint():Point {
		var points:Array<Point> = this.getHitmask();
		var lowestX:Point = Utils.arraySmallest(points, function(x) return x.x);
		var lowestY:Point = Utils.arraySmallest(points, function(x) return x.y);
		return new Point(lowestX.x, lowestY.y);
	}
	private function farthestPoint():Point {
		var points:Array<Point> = this.getHitmask();
		var highestX:Point = Utils.arrayLargest(points, function(x) return x.x);
		var highestY:Point = Utils.arrayLargest(points, function(x) return x.y);
		return new Point(highestX.x, highestY.y);
	}
}