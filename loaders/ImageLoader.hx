package gryffin.loaders;

//- Standard Library Imports
import haxe.io.Bytes;

//- Flash/OpenFL Imports
import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.media.Sound;
import flash.media.Loader;
import flash.events.Event;

//- Gryffin Imports
import gryffin.EventDispatcher;
import gryffin.display.Sprite;
import gryffin.core.assets.manager.FileLoader;
import gryffin.core.assets.manager.misc.FileType;
import gryffin.core.assets.manager.misc.FileInfo;

class ImageLoader {
	private static var _images:Map<String, BitmapData>;

	public static function get(name:String):Null<BitmapData> {
		return _images.get(name);
	}

	private static function __init__():Void {
		_images = new Map();

		linkToBaseLoader();
	}
	private static function linkToBaseLoader():Void {
		gryffin.loaders.BaseLoader.once('initial:load-complete', function(files:Array<Dynamic>):Void {
			files = files.filter(function(x:Dynamic):Bool return (x.type == 'image'));
			for (file in files) {
				(function(file:Dynamic):Void {
					var picLoader:Loader = new Loader();
					picLoader.addEventListener(Event.COMPLETE, function(e):Void {
						var data = picLoader.content;
						var pic:BitmapData = new BitmapData(data.width, data.height, true, 0x00000000);
						var matrx = new flash.geom.Matrix();
						pic.draw(data, matrx, null, null, null, true);
						_images.set(file.id, pic);
					});
				}(file));
			}
		});
	}
}