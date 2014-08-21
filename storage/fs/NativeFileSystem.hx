package gryffin.storage.fs;

import haxe.io.Bytes;
import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;

class NativeFileSystem {
	public static function initialize():Void {
		return;
	}
	public static function exists(name : String):Bool {
		return FS.exists(name);
	}
	public static function isDirectory(name : String):Bool {
		return FS.isDirectory(name);
	}
	public static function isFile(name : String):Bool {
		return !FS.isDirectory(name);
	}
	public static function isEmpty(name : String):Bool {
		if (exists(name)) {
			if (isDirectory(name)) {
				return (readDirectory(name).length == 0);
			} else {
				return (getContent(name).length == 0);
			}
		} else {
			return true;
		}
	}
	public static function readDirectory(name : String):Array<String> {
		var found:Array<String> = FS.readDirectory(name);
		if (found == null) {
			if (name == '' || name == '/') {
				name = Sys.getCwd();
				return readDirectory(name);
			} else {
				return found;
			}
		}
		return found;
	}
	public static function createDirectory(name : String):Void {
		FS.createDirectory(name);
	}
	public static function deleteDirectory(name : String):Void {
		FS.deleteDirectory(name);
	}

	public static function getContent(name : String):String {
		return HFile.getContent(name);
	}
	public static function getBytes(name : String):Bytes {
		return HFile.getBytes(name);
	}

	public static function saveContent(name:String, content:String):Void {
		HFile.saveContent(name, content);
	}
	public static function saveBytes(name:String, content:Bytes):Void {
		HFile.saveBytes(name, content);
	}
	public static function deleteFile(name:String):Void {
		FS.deleteFile(name);
	}
	public static function rename(from:String, to:String):Void {
		FS.rename(from, to);
	}

	public static function file(name : String):File {
		return new File(name);
	}
	public static function folder(name : String):Directory {
		return new Directory(name);
	}
}

private typedef FS = sys.FileSystem;
private typedef HFile = sys.io.File;