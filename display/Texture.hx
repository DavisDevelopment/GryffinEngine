package gryffin.display;

import gryffin.display.PixelMask;
import gryffin.utils.Buffer;
import gryffin.utils.Asset;

import flash.display.BitmapData;

import gryffin.geom.Rectangle;
import gryffin.geom.Point;

class Texture {
	public var mask:PixelMask;
	public var imageData:Buffer;
	public var originalSource:Asset;
	public var _bitmap:BitmapData;
	public var _changed:Bool;

	public var width(default, set):Int;
	public var height(default, set):Int;

	public function new(asst:Asset):Void {
		this.originalSource = asst;
		this.width = Math.round(asst.bitmap.rect.width);
		this.height = Math.round(asst.bitmap.rect.height);
		this._bitmap = new BitmapData(this.width, this.height, false, 0x00000000);
		this.imageData = asst.bitmap.getPixels(_bitmap.rect);
		this.mask = new PixelMask(imageData, Rectangle.fromFlashRectangle(_bitmap.rect));
		this._changed = false;

		this.redraw();
	}
	private inline function set_width(nwidth:Int):Int {
		_changed = (nwidth == this.width);
		return this.width = nwidth;
	}
	private inline function set_height(nheight:Int):Int {
		_changed = (nheight == this.height);
		return this.height = nheight;
	}
	public function redraw():Void {
		//this._bitmap.setPixels(_bitmap.rect, this.imageData.toByteArray());
		var i:Float->Int = Math.round.bind(_);
		var plot:Array<Point> = Rectangle.fromFlashRectangle(_bitmap.rect).points();
		_bitmap.lock();
		var x:Int;
		var y:Int;
		for (point in plot) {
			x = i(point.x);
			y = i(point.y);
			_bitmap.setPixel32(x, y, mask.get(x, y));
		}
		_bitmap.unlock();
	}

	public function toBitmapData():BitmapData {
		if (this._changed) {
			this.redraw();
			_changed = false;
		}
		return this._bitmap;
	}
}