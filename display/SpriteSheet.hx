package gryffin.display;

import flash.display.BitmapData;

import gryffin.display.Sprite;
import gryffin.geom.Rectangle;

class SpriteSheet {
	public var mode:Int;
	public var data:BitmapData;
	public var frames:Array<BitmapData>;
	public var dimensions:Rectangle;

	public function new(mode:Int, data:BitmapData, dimensions:Rectangle):Void {
		this.data = data;
		this.mode = mode;
		this.dimensions = dimensions;
		this.frames = new Array();
		this.getFrames();
	}
	private function getFrames():Void {
		var numFrames:Int = 0;
		if (mode == HORIZONTAL)
			numFrames = Math.round(data.rect.width / dimensions.width);

		if (mode == HORIZONTAL) {
			var x:Int = 0;
			var sprite:Sprite = new Sprite('');
			sprite.data = this.data;

			for (i in 0...numFrames) {
				var frame:BitmapData = sprite.getFragment(x, 0, dimensions.width, data.rect.height);
				frames.push(frame);
				x += Math.round(dimensions.width);
			}
		}
	}

	public static inline var VERTICAL:Int = 0;
	public static inline var HORIZONTAL:Int = 1;
}