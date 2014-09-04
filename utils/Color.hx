package gryffin.utils;

@:forward(alpha, red, green, blue)
abstract Color(IColor) {
	public var value(get, set):Int;
	public inline function new(r:Int, g:Int, b:Int, ?a:Null<Int>):Void {
		this = new IColor(r, g, b, a);
	}
	private inline function get_value():Int {
		return this.getColor();
	}
	private inline function set_value(v:Int):Int {
		this.setColor(v);
		return v;
	}
	public inline function mix(other:Color, ?ratio:Null<Float>):Color {
		var newColor:IColor = this.mix(other.toIColor(), ratio);
		this.red = newColor.red;
		this.green = newColor.green;
		this.blue = newColor.blue;
		return cast this;
	}

	@:to 
	public inline function toInt32():Int {
		return this.getColor();
	}
	@:to
	public inline function toIColor():IColor {
		return this;
	}
	@:to 
	public inline function toString():String {
		var str:String = '#';
		var set:Array<Int> = [this.alpha, this.red, this.green, this.blue];
		for (channel in set) {
			str += StringTools.hex(channel, 2);
		}
		return str;
	}
	@:to 
	public inline function toArray():Array<Int> {
		return [this.alpha, this.red, this.green, this.blue];
	}

	@:from
	public static inline function fromIColor(col:IColor):Color {
		return new Color(col.red, col.green, col.blue, col.alpha);
	}

	@:from 
	public static inline function fromArray(list:Array<Int>):Color {
		return new Color(list[1], list[2], list[3], list[0]);
	}

	@:from 
	public static inline function fromInteger(color : Int):Color {
		return cast (new IColor(0, 0, 0, 0).setColor(color));
	}

	@:from 
	public static inline function fromString(str : String):Color {
		var colString:String = (str + '');
		if (colString.charAt(0) == '#') colString.substring(1, 0);

		switch (colString.length) {
			case 3:
				var pieces:Array<String> = colString.split('');
				var npieces:Array<String> = [];
				for (c in pieces) npieces.push(c + c);
				colString = npieces.join('');

			case 6:
				colString = ('FF' + colString);
		}
		var num:Int = Std.parseInt('0x$colString');
		if (Math.isNaN(num)) {
			num = 0;
		}

		return Color.fromInteger(num);
	}
}

class IColor {
	public var data:Array<Int>;

	public var red(get, set):Int;
	public var green(get, set):Int;
	public var blue(get, set):Int;
	public var alpha(get, set):Int;

	public function new(r:Int, g:Int, b:Int, ?a:Null<Int>):Void {
		if (a == null) a = 255;
		this.data = [a, r, g, b];
	}
	private inline function getValue(channel:Int):Int {
		return this.data[channel];
	}
	private inline function setValue(channel:Int, value:Int):Int {
		var v:Int = Math.floor(Math.min(255, Math.max(value, 0)));
		this.data[channel] = v;
		return v;
	}
	private inline function get_alpha():Int {
		return getValue(0);
	}
	private inline function set_alpha(a:Int):Int {
		return setValue(0, a);
	}
	private inline function get_red():Int {
		return getValue(1);
	}
	private inline function set_red(r:Int):Int {
		return setValue(1, r);
	}
	private inline function get_green():Int {
		return getValue(2);
	}
	private inline function set_green(g:Int):Int {
		return setValue(2, g);
	}
	private inline function get_blue():Int {
		return getValue(3);
	}
	private inline function set_blue(b:Int):Int {
		return setValue(3, b);
	}

	public function setColor(color : Int):IColor {
		this.alpha = color >> 24 & 0xFF;
		this.red = color >> 16 & 0xFF;
		this.green = color >> 8 & 0xFF;
		this.blue = color & 0xFF;
		return this;
	}

	public inline function getColor():Int {
		return (Math.round(alpha) << 24) | (Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue);
	}

	public function mix(target:IColor, ratio:Float = 0.5):IColor {
		return new IColor( 
			Math.round(this.red + (target.red - this.red) * ratio), 
			Math.round(this.green + (target.green - this.green) * ratio), 
			Math.round(this.blue + (target.blue - this.blue) * ratio),
			Math.round(this.alpha + (target.alpha - this.alpha) * ratio)
		);
	}
}