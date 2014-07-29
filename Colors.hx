package gryffin;

class Colors {
	private static function contains( list:Array <Dynamic>, item:Dynamic ):Bool {
		for ( x in list ) if ( x == item ) return true;
		return false;
	}
	public static function parse( color:Dynamic ):Int {
		var type:String = Types.typename( color );
		switch ( type ) {
			case "String":
				var colorNameList:Array <String> = ["black", "white", "red", "green", "blue"];
				if (contains(colorNameList, color)) {
					return [
						"black" => 0xFF000000,
						"white" => 0xFFFFFFFF,
						"red" => 0xFFFF0000,
						"green" => 0xFF00FF00,
						"blue" => 0xFF0000FF,
						"transparent" => 0x00FFFFFF
					].get(cast(color, String));
				} else {
					if (color.substring(0,1) == "#") {
						return Std.parseInt(StringTools.replace(cast(color, String), "#", "0x"));
					} else {
						return Std.parseInt(cast(color, String));
					}
				}
			case "Array<Int>", "Array<Float>", "Array<Number>":
				var res:String = "0x";
				var list:Array <Int> = [for (x in cast(color, Array<Dynamic>)) cast(x, Int)];
				for (x in list) {
					res += StringTools.hex( x, 2 );
				}
				return Std.parseInt( res );
			
			case "Int":
				return cast( color, Int );
				
			default:
				return 0xFF000000;
		}
	}
	public static function unparse( col:Dynamic ):String {
		var type:String = Types.typename( col );
		switch ( type ) {
			case "String":
				var colorNameList:Array <String> = ["black", "white", "red", "green", "blue"];
				if (contains(colorNameList, col)) {
					return Colors.unparse([
						"black" => 0xFF000000,
						"white" => 0xFFFFFFFF,
						"red" => 0xFFFF0000,
						"green" => 0xFF00FF00,
						"blue" => 0xFF0000FF,
						"transparent" => 0x00FFFFFF
					].get(cast(col, String)));
				} else {
					return cast( col, String );
				}
			case "Int":
				return ("#" + StringTools.hex(cast(col, Int), 8));
			case "Array<Int>", "Array<Float>", "Array<Number>":
				var res:String = "#";
				var list:Array <Int> = [for (x in cast(col, Array<Dynamic>)) Math.floor(x)];
				for (x in list) {
					res += StringTools.hex( x, 2 );
				}
				return res;
			default:
				return Std.string(col);
		}
	}
	public static function parseToRGB( col:Dynamic ):Array < Int > {
		var color:Int = parse(col);
		var red:Int = color >> 16 & 0xFF;
		var green:Int = color >> 8 & 0xFF;
		var blue:Int = color & 0xFF;
		return [red, green, blue];
	}
	public static function parseFromRGB(red:Int, green:Int, blue:Int):Int {
		return (Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue);
	}
	public static function rgb2hsl( r:Float, g:Float, b:Float ):Array < Float > {
		r /= 255;
		g /= 255;
		b /= 255;
		var max = Utils.largest([r, g, b]), min = Utils.smallest([r, g, b]);
		var h:Float = (( max + min ) / 2)+0.0;
		var s:Float = h;
		var l:Float = s;
		
		if ( max == min ) {
			h = s = 0;
		} else {
			var d = ( max - min );
			s = (( l > 0.5 ) ? (d / (2 - max - min)) : (d / (max + min)))+0.0;
			
			if ( max == r ) h = (g - b) / d + (g < b ? 6 : 0);
			else if ( max == g ) h = (b - r) / d + 2;
			else if ( max == b ) h = (r - g) / d + 4;
			h /= 6;
		}
		return [ h, s, l ];
	}
	public static function hsl2rgb( h:Float, s:Float, l:Float ):Array < Int > {
		var r, g, b;

		if(s == 0){
			r = g = b = l; // achromatic
		}else{
			function hue2rgb(p:Float, q:Float, t:Float):Float {
				if(t < 0) t += 1;
				if(t > 1) t -= 1;
				if(t < 1/6) return p + (q - p) * 6 * t;
				if(t < 1/2) return q;
				if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
				return p;
			}

			var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
			var p = 2 * l - q;
			r = hue2rgb(p, q, h + 1/3);
			g = hue2rgb(p, q, h);
			b = hue2rgb(p, q, h - 1/3);
		}

		var basicResult = [r * 255, g * 255, b * 255];
		return [for ( x in basicResult ) Math.round(x)];
	}
	public static function darken( col:Dynamic, amount:Float ):String {
		var color = parseToRGB( col );
		var percentage = Math.round(amount/100);
		for ( channel in color ) {
			channel -= (percentage*channel);
		}
		color = [for ( x in color) Math.round(x)];
		return unparse(color);
	}
	public static function lighten( col:Dynamic, amount:Float ):String {
		return darken( col, amount*-1 );
	}
	public static function mix( col1:Dynamic, col2:Dynamic, ?ratio:Float = 0.5 ):Int {
		var color1:Array<Int> = parseToRGB(parse(col1));
		var color2:Array<Int> = parseToRGB(parse(col2));
		var color:Array<Int> = [0, 0, 0];

		color[0] = Std.int(color1[0] + ((color2[0] - color1[0]) * ratio));
		color[1] = Std.int(color1[1] + ((color2[1] - color1[1]) * ratio));
		color[2] = Std.int(color1[3] + ((color2[3] - color1[3]) * ratio));

		return parseFromRGB(color[0], color[1], color[2]);
	}
}