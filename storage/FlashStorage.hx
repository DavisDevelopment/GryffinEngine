package gryffin.storage;

import gryffin.storage.fs.FileSystem;

class FlashStorage {
	private static var data:Map<String, Dynamic> = {
		new Map();
	};

	public static function get(key : String):Dynamic {
		return data[key];
	}
	public static function set(key:String, val:Dynamic):Void {
		data[key] = val;
	}
	public static function remove(key:String):Void {
		data.remove(key);
	}
}