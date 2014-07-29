package gryffin.geom;

import gryffin.geom.Point;

class Fragment extends Point {
	public var color:Int;

	public function new(?x:Int, ?y:Int, ?z:Int, ?color:Int = 0x00000000) {
		super(x, y, z);
		this.color = color;
	}
}