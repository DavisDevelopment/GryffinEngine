package gryffin.display;

import flash.display.BitmapData;

class ImageManipulation {
	public static function translate ( image:BitmapData, f:Dynamic, t:Int ) {
		var from:String = Colors.unparse(f);
		var to:Int = t;
		var result:BitmapData = new BitmapData( image.width, image.height );
		
		for ( x in 0...image.width ) {
			for ( y in 0...image.height ) {
				var color:String = Colors.unparse(image.getPixel(x, y));
				var newColor:Int = Colors.parse(color);
				if ( color == from ) {
					newColor = to;
				}
				result.setPixel(x, y, newColor);
			}
		}
		return result;
	}
}