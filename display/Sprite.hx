package gryffin.display;

import gryffin.Stage;
import gryffin.Surface;

import flash.display.BitmapData;
import flash.display.Bitmap;
import openfl.Assets;

class Sprite extends Entity {
	public var path(default, set):String;
	public var data(default, set):Null<BitmapData>;
	public var pixels(get, never):Array<Dynamic>;

	public var imageWidth(get, never):Float;
	public var imageHeight(get, never):Float;

	private var dataCache:Map<Array<Float>, BitmapData>;

	public function new( id:String ) {
		super();
		this.path = id;
		this.data = Assets.exists(id) ? Assets.getBitmapData(id) : null;

		this.dataCache = new Map();
	}

	private function get_imageWidth():Float {
		return this.data.width;
	}
	private function get_imageHeight():Float {
		return this.data.height;
	}
	private function get_pixels():Array<Dynamic> {
		if (this.data != null)
			return this.getFragmentPixels(0, 0, this.imageWidth, this.imageHeight);
		else
			return new Array();
	}
	private function set_data(d:BitmapData):BitmapData {
		this.data = d;
		this.dataCache = new Map();
		return d;
	}
	private function set_path(npath:String):String {
		path = npath;
		this.data = Assets.exists(npath) ? Assets.getBitmapData(npath) : null;
		return npath;
	}

	private function getFragmentPixels(sx:Float, sy:Float, width:Float, height:Float):Array<Dynamic> {
		var pixels:Array<Dynamic> = [];
		for (x in (Std.int(sx)...Std.int(width))) {
			for (y in (Std.int(sy)...Std.int(height))) {
				var pixel:Dynamic = {
					'value' : this.data.getPixel32(x, y),
					'x' : x,
					'y' : y
				};
				pixels.push(pixel);
			}
		}
		return pixels;
	}
	public function getFragment(sx:Float, sy:Float, width:Float, height:Float, ?scaleX:Float, ?scaleY:Float):BitmapData {
		var i:Float -> Int = Std.int;
		//- Get Pixel List
		var isCached:Bool = this.dataCache.exists([sx, sy, width, height]);
		if (isCached) {
			return this.dataCache.get([sx, sy, width, height]);
		} else {
			var pixels:Array<Dynamic> = this.getFragmentPixels(sx, sy, width, height);

			//- Create Image Fragment
			var dummy:BitmapData = new BitmapData(i(width), i(height));

			for (pixel in pixels) {
				dummy.setPixel32(pixel.x, pixel.y, pixel.value);			
			}
			//- Cache it
			this.dataCache.set([sx, sy, width, height], dummy);
			//- return it
			return dummy;
		}
	}
	public function resizeFragment(frag:BitmapData, width:Float, height:Float):BitmapData {
		var scaleX:Float = (width / frag.width);
		var scaleY:Float = (height / frag.height);
		var matrix:flash.geom.Matrix = new flash.geom.Matrix();
		matrix.scale(scaleX, scaleY);
		var scaled:BitmapData = new BitmapData(Std.int(frag.width * scaleX), Std.int(frag.height * scaleY));
		scaled.draw(frag, matrix, null, null, null, true);
		return scaled;
	}
	public function drawFragment(g:Surface, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float):Void {
		var i:Float -> Int = Std.int;
		var fragment:BitmapData = this.getFragment(sx, sy, sw, sh);
		fragment = this.resizeFragment(fragment, dw, dh);
		var wrapper:Bitmap = new Bitmap(fragment);
		wrapper.width = dw;
		wrapper.height = dh;

		var drawer:BitmapData = new BitmapData(i(dw), i(dh));
		drawer.draw(wrapper);

		g.drawImage(drawer, i(dx), i(dy), i(dw), i(dh));
	}
}