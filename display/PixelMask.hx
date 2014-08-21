package gryffin.display;

import gryffin.utils.Color;
import gryffin.utils.Buffer;
import gryffin.geom.Rectangle;

class PixelMask {
	public var buffer:Buffer;
	public var width:Int;
	public var height:Int;

	public function new(buf:Buffer, area:Rectangle):Void {
		this.buffer = buf;

		this.width = Math.round(area.width);
		this.height = Math.round(area.height);
	}

	public inline function get(x:Int, y:Int):Color {
		var index:Int = ((x + y * width));
		return (new Color(0,0,0,0).value = buffer[index]);
	}

	public inline function set(x:Int, y:Int, color:Color):Void {
		var index:Int = ((x + y * width));
		var byte:Int = color.value;
		buffer[index] = byte;
	}
}