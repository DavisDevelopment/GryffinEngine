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
		var type:String = Types.typename( col );
		switch ( type ) {
			case "String":
				var colString = cast( col, String );
				if ( colString.substring(0,1) == "#" ) colString = colString.substring(1);
				else if ( colString.substring(0, 2) == "0x" ) colString = colString.substring(2);
				var rgbString:Array < String > = [];
				var piece:String = "";
				for ( i in 2...colString.length+1 ) {
					if ( i % 2 == 0 && i != 0 ) {
						rgbString.push( piece );
						piece = "";
					} else {
						piece += colString.charAt(i);
					}
				}
				var result = [for (x in rgbString) Std.parseInt("0x"+x)];
				return result;
				
			case "Int":
				var hex:String = ("#" + StringTools.hex(cast(col, Int), 8));
				return parseToRGB(hex);
				
			case "Array<Int>", "Array<Float>", "Array<Number>":
				var list = cast( col, Array<Dynamic> );
				if ( list.length == 4 ) list = list.slice(1);
				return [for (x in list) Math.floor(x)];
				
			default:
				return parseToRGB(Std.string(col));
		}
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
	public static function mix( col1:Dynamic, col2:Dynamic, weight:Float=50 ):String {
		var color1 = parseToRGB( col1 );
		var color2 = parseToRGB( col2 );
		var p = (weight / 100.0);
		var w = p * 2 - 1;
		var a = 0;
		var w1 = (((w + a) / (1 + w * a)) + 1) / 2.0;
		var w2 = 1 - w1;
		var rgb = [
			(color1[0] * w1) + (color2[0] * w2),
			(color1[1] * w1) + (color2[1] * w2),
			(color1[2] * w1) + (color2[2] * w2)
		];
		for ( i in 0...rgb.length+1 ) {
			var channel = rgb[i];
			if ( channel > 255 ) rgb[i] = 255;
			if ( channel < 0 ) rgb[i] = 0;
		}
		return unparse( rgb );
	}
}