package gryffin.storage;

import haxe.Serializer;
import haxe.Unserializer;
import gryffin.utils.PathTools;

class LocalStorage {
	public static function get( key:String ):Dynamic {
		if (data.get(key) != null) {
			return Unserializer.run(data.get(key));
		} else {
			return null;
		}
	}
	public static function set( key:String, value:Dynamic ):Void {
		data.set(key, Serializer.run(value));
		saveData();
	}
	public static function remove( key:String ):Void {
		data.remove(key);
		saveData();
	}

	public static function loadData():Void {
		#if (cpp||neko)
			var path:String = PathTools.join([Sys.executablePath(), '$localStorageName.dat']);
			path = PathTools.normalize(path);
			if (sys.FileSystem.exists(path)) {
				data = Unserializer.run(sys.io.File.getContent(path));
			}
		#elseif (html5)
			var ls:Dynamic = js.Browser.getLocalStorage();
			if (ls.getItem(localStorageName) != null) {
				data = Unserializer.run(ls.get(localStorageName));
			}
		#else

		#end
	}
	public static function saveData():Void {
		#if (cpp||neko)
			var path:String = PathTools.join([Sys.executablePath(), '$localStorageName.dat']);
			sys.io.File.saveContent(path, Serializer.run(data));
		#elseif html5
			js.Browser.getLocalStorage().setItem(localStorageName, Serializer.run(data));
		#else

		#end
	}

	private static var localStorageName:String = 'gryffinls';

	private static var data:Map<String, String>;

	public static function init():Void {
		data = new Map();
		loadData();
	}
}