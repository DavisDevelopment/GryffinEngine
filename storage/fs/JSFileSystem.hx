package gryffin.storage.fs;

import gryffin.storage.VirtualVolume;
import haxe.io.Bytes;

import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;

import openfl.Assets;

using gryffin.utils.PathTools;
class JSFileSystem {
	private static inline var LOAD_ASSETS:Bool = true;

	private static var volume:VirtualVolume;
	public static function initialize():Void {
		load();
	}

	private static function load():Void {
		var ls = js.Browser.getLocalStorage();
		if (ls.getItem(LS_KEY) != null) {
			var DNA:String = ls.getItem(LS_KEY);
			volume = VirtualVolume.unserialize(DNA);
		} else {
			volume = new VirtualVolume();
			ls.setItem(LS_KEY, volume.serialize());
		}
	}
	private static function getBytesFromAsset(path : String):Bytes {
		var bits:Null<flash.utils.ByteArray> = Assets.getBytes(path);
		if (bits == null)
			return Bytes.alloc(0);
		var bytes:Bytes = Bytes.alloc(bits.length);
		bits.position = 0;

		while (bits.bytesAvailable > 0) {
			var pos:Int = bits.position;
			bytes.set(pos, bits.readByte());
		}

		return bytes;
	}
	private static function save():Void {
		if (volume != null) {
			js.Browser.getLocalStorage().setItem(LS_KEY, volume.serialize());
		}
	}

	public static function exists(name : String):Bool {
		return volume.exists(name) || Assets.exists(name);
	}
	public static function isDirectory(name:String):Bool {
		return volume.isDirectory(name);
	}
	public static function isFile(name:String):Bool {
		return volume.isFile(name) || Assets.exists(name);
	}
	public static function isEmpty(name:String):Bool {
		return volume.isEmpty(name);
	}

	public static function createDirectory(name : String):Void {
		volume.createDirectory(name);
		save();
	}
	private static function readRoot():Array<String> {
		var all_entries = volume.entries;
		var root_entries:Array<String> = new Array();

		for (entry in all_entries) {
			if (entry.name.normalize().dirname() == '') root_entries.push(entry.name.normalize().basename().normalize());
		}

		return root_entries;
	}
	public static function readDirectory(name : String):Array<String> {
		if (name == '') {
			return readRoot();
		}
		if (volume.exists(name)) {
			return volume.readDirectory(name);
		} else {
			return Assets.list().filter(function(x:String) {
				return (x.parent() == name);
			});
		}
	}

	public static function getContent(name : String):String {
		return (volume.exists(name) ? volume.getContent(name) : Assets.getText(name));
	}
	public static function getBytes(name : String):Bytes {
		return (volume.exists(name) ? volume.getBytes(name) : getBytesFromAsset(name));
	}

	public static function saveContent(name:String, content:String):Void {
		if (!exists(name)) volume.createFile(name);
		volume.saveContent(name, content);
		save();
	}
	public static function saveBytes(name:String, content:Bytes):Void {
		if (!exists(name)) volume.createFile(name);
		volume.saveBytes(name, content);
		save();
	}

	public static function file(name : String):File {
		return new File(name);
	}
	public static function folder(name : String):Directory {
		return new Directory(name);
	}


	private static inline var LS_KEY:String = '__gryffin_fs__';
}