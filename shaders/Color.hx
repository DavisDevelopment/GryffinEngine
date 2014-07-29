package gryffin.shaders;

class Color {
	public var data:Array<Int>;
	public var red(get, set):Int;
	public var green(get, set):Int;
	public var blue(get, set):Int;

	public function new() {
		this.data = new Array();
		this.red = 0;
		this.green = 0;
		this.blue = 0;
	}
	public function getValue(i:Int):Int {
		return (this.data[i]);
	}
	public function setValue(i:Int, v:Int):Int {
		var nv:Int = Std.int(Math.min(getValue(i), MAX));
		this.data[i] = nv;
		return nv;
	}
	public function get_red():Int {
		return getValue(0);
	}
	public function set_red(nr:Int):Int {
		return setValue(0, nr);
	}
	public function get_green():Int {
		return getValue(1);
	}
	public function set_green(ng:Int):Int {
		return setValue(1, ng);
	}
	public function get_blue():Int {
		return getValue(2);
	}
	public function set_blue(nb:Int):Int {
		return setValue(2, nb);
	}
	public function setColor(col:Int):Color {
		this.blue = (col >> 16 & 0xFF);
		this.green = (col >> 8 & 0xFF);
		this.red = (col & 0xFF);
		return this;
	}
	public function getColor():Int {
		return (Math.round(this.red)) | (Math.round(this.green) << 8) | (Math.round(this.blue) << 16);
	}
	public static function fromRGB(r:Int, g:Int, b:Int):Color {
		var c = new Color();
		c.red = r;
		c.green = g;
		c.blue = b;
		return c;
	}
	public static inline var MIN:Int = 0;
	public static inline var MAX:Int = 255;
}