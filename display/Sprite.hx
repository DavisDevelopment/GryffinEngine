package gryffin.display;

import gryffin.Stage;
import gryffin.Surface;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.utils.ByteArray;
import haxe.io.Bytes;

import openfl.Assets;
import haxe.Json;

class Sprite extends Entity {
	public var path(default, set):String;
	public var data(default, set):Null<BitmapData>;
	public var pixels(get, never):Null<ByteArray>;

	public var imageWidth(get, never):Float;
	public var imageHeight(get, never):Float;

	private var dataCache:Map<String, BitmapData>;
	private var resizeCache:Map<String, BitmapData>;
	private var original_data:Null<BitmapData>;

	public function new( id:String ) {
		super();
		this.path = id;
		this.data = Assets.exists(id) ? Assets.getBitmapData(id) : null;
		this.original_data = (this.data != null) ? this.data : null;

		this.dataCache = new Map();
		this.resizeCache = new Map();
	}

	private function get_imageWidth():Float {
		return this.data.width;
	}
	private function get_imageHeight():Float {
		return this.data.height;
	}
	private function get_pixels():Null<ByteArray> {
		if (this.data != null)
			return this.getFragmentPixels(0, 0, this.imageWidth, this.imageHeight);
		else
			return null;
	}
	private function set_data(d:BitmapData):BitmapData {
		this.data = d;
		this.dataCache = new Map();
		return d;
	}
	private function set_path(npath:String):String {
		path = npath;
		this.data = Assets.exists(npath) ? Assets.getBitmapData(npath) : null;
		this.original_data = this.data != null ? this.data : null;
		return npath;
	}
	public function reload():Void {
		this.path = this.path;
	}
	public function getFragmentPixels(sx:Float, sy:Float, width:Float, height:Float):ByteArray {
		var sourceRect:Rectangle = new Rectangle(sx, sy, width, height);
		var pixelArray:ByteArray = this.data.getPixels(sourceRect);

		return pixelArray;
	}
	public function getFragmentRows(sx:Int, sy:Int, width:Int, height:Int):Array<Array<Int>> {
		var rows:Array<Array<Int>> = new Array();

		for (y in (sy...height)) {
			var row:Array<Int> = new Array();
			for (x in (sx...width)) {
				row.push(this.data.getPixel32(x, y));
			}
			rows.push(row);
		}
		return rows;
	}
	public function getFragment(sx:Float, sy:Float, width:Float, height:Float, ?scaleX:Float, ?scaleY:Float):BitmapData {
		var i:Float -> Int = Math.floor.bind(_);
		var key:String = Json.stringify([sx, sy, width, height]);
		if (this.dataCache.exists(key)) {
			return this.dataCache.get(key);
		} else {
			var dumm:BitmapData = new BitmapData(i(width), i(height), true, 0x000000);
			var sourc:Rectangle = new Rectangle(sx, sy, width, height);
			var dest:Point = new Point(0, 0);
			dumm.copyPixels(this.data, sourc, dest, null, null, true);
			return dumm;
		}
	}
	public function resizeFragment(frag:BitmapData, width:Float, height:Float):BitmapData {
		var scaleX:Float = (width / frag.width);
		var scaleY:Float = (height / frag.height);
		var matrix:flash.geom.Matrix = new flash.geom.Matrix();
		matrix.scale(scaleX, scaleY);
		var scaled:BitmapData = new BitmapData(Std.int(frag.width * scaleX), Std.int(frag.height * scaleY), true, 0x000000);
		scaled.draw(frag, matrix, null, null, null, true);
		return scaled;
	}
	public function getScaledBitmap(sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float):BitmapData {
		var numkey:Array<Float> = [this.data.width, this.data.height, sx, sy, sw, sh, dx, dy, dw, dh];
		var key:String = Json.stringify(numkey);
		if (this.resizeCache.exists(key)) {
			return cast(this.resizeCache.get(key), BitmapData);
		} else {
			var i:Float -> Int = Std.int;
			var fragment:BitmapData = this.getFragment(sx, sy, sw, sh);
			fragment = this.resizeFragment(fragment, dw, dh);
			var wrapper:Bitmap = new Bitmap(fragment);
			wrapper.width = dw;
			wrapper.height = dh;

			var drawer:BitmapData = new BitmapData(i(dw), i(dh), true, 0x000000);
			drawer.draw(wrapper);
			this.resizeCache.set(key, drawer);
			return drawer;
		}
	}
	public function resize(width:Int, height:Int):Void {
		var nbm:BitmapData = this.getScaledBitmap(0, 0, this.imageWidth, this.imageHeight, 0, 0, width, height);
		this.data = nbm;
	}
	public function drawFragment(g:Surface, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float):Void {
		var i:Float -> Int = Std.int;
		var drawer:BitmapData = this.getScaledBitmap(sx, sy, sw, sh, dx, dy, dw, dh);
		g.drawImage(drawer, i(dx), i(dy), i(dw), i(dh));
	}

	override public function render(g:Surface, stage:Stage):Void {
		this.drawFragment(g, 0, 0, this.imageWidth, this.imageHeight, this.x, this.y, this.width, this.height);
	}


	public static function scaleBitmap(bm:BitmapData, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float):BitmapData {
		var dummy:Sprite = new Sprite('');
		dummy.data = bm;
		return dummy.getScaledBitmap(sx, sy, sw, sh, dx, dy, dw, dh);
	}
}