package gryffin.storage;

import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.AssetType;

using gryffin.utils.PathTools;
class Assets {
	public static var getText:String -> Null<String> = FAssets.getText;

	public static function getBytes(path : String):Bytes {
		var bytelist:ByteArray = FAssets.getBytes(path);
		var bits:Bytes = Bytes.alloc(bytelist.length);

		for (i in 0...bytelist.length) {
			bytelist.position = i;
			bits.set(i, bytelist.readInt());
		}
		bytelist.position = 0;
		return bits;
	}

	public static var exists:String -> Bool = FAssets.exists;

	public static function list(?type : Int = -1):Array<String> {
		var ftype:Null<AssetType>;
		switch (type) {
			case -1: ftype = null;
			case BINARY: ftype = AssetType.BINARY;
			case TEXT: ftype = AssetType.TEXT;
			case IMAGE: ftype = AssetType.IMAGE;
			case FONT: ftype = AssetType.FONT;
			case SOUND: ftype = AssetType.SOUND;
			case MUSIC: ftype = AssetType.MUSIC;
			case MOVIE_CLIP: ftype = AssetType.MOVIE_CLIP;
			case TEMPLATE: ftype = AssetType.TEMPLATE;
			default: throw 'Invalid Asset Type $type';
		}
		return FAssets.list(ftype);
	}

	public static function isDirectory(path : String):Bool {
		for (name in list()) {
			if (name.parent().normalize() == path.normalize()) {
				return true;
			}
		}
		return false;
	}

	public static var BINARY:Int = 0;
	public static var TEXT:Int = 1;
	public static var IMAGE:Int = 2;
	public static var FONT:Int = 3;
	public static var SOUND:Int = 4;
	public static var MUSIC:Int = 5;
	public static var MOVIE_CLIP:Int = 6;
	public static var TEMPLATE:Int = 7;
}

private typedef FAssets = openfl.Assets;