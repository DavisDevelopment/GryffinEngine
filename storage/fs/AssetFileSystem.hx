package gryffin.storage.fs;

import openfl.Assets;
import haxe.io.Bytes;
import gryffin.Utils;
import gryffin.utils.Buffer;

using gryffin.utils.PathTools;
class AssetFileSystem {
	private static var _all:Array<String>;
	private static var _root:Array<String>;

	public static function initialize():Void {
		_all = getAll();
		_root = new Array();
		for (path in _all) {
			path = path.simplify();
			if (!Lambda.has(_root, path.root())) {
				_root.push(path.root());
			}
		}
	}
	public static function getAll():Array<String> {
		var files:Array<String> = Assets.list();
		var names:Array<String> = files.copy();

		for (name in names) {
			files = files.concat(name.ancestry());
		}
		return Utils.uniqueItems(files);
	}
	public static function exists(id : String):Bool {
		return Assets.exists(id);
	}
	public static function isDirectory(id : String):Bool {
		if (exists(id)) {
			return false;
		} else {
			for (path in _all) {
				if (path.simplify().indexOf(id.simplify()) == 0) {
					return true;
				}
			}
			return false;
		}
	}
	public static function isFile(id : String):Bool {
		return exists(id);
	}
	public static function isEmpty(id : String):Bool {
		if (exists(id)) {
			return (getBytes(id).length == 0);
		} else {
			return true;
		}
	}
	public static function readDirectory(id : String):Array<String> {
		id = id.simplify();
		if (id == '') return _root;
		else {
			return _all.filter(function(x:String):Bool {
				return (x.parent().simplify() == id);
			});
		}
	}
	public static function getBytes(id : String):Bytes {
		if (exists(id)) {
			return Buffer.fromByteArray(Assets.getBytes(id)).toBytes();
		} else {
			return Bytes.alloc(0);
		}
	}
	public static function getContent(id : String):String {
		if (exists(id)) {
			return Assets.getText(id);
		} else {
			return '';
		}
	}
}