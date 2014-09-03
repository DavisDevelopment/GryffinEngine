package gryffin.storage.fs;

import haxe.io.Bytes;
import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;
import gryffin.utils.CompileTime;
import gryffin.utils.CompileTimeClassList;

using gryffin.utils.PathTools;
@:expose
@:keep
class FileSystem {
	public static var initialize:Void -> Void = MyFS.initialize;

	public static var exists:String -> Bool = MyFS.exists;

	public static var isDirectory:String -> Bool = MyFS.isDirectory;

	public static var isFile:String -> Bool = MyFS.isFile;

	public static var isEmpty:String -> Bool = MyFS.isEmpty;

	public static var createDirectory:String -> Void = MyFS.createDirectory;

	public static var readDirectory:String -> Array<String> = MyFS.readDirectory;

	public static var getContent:String -> Null<String> = MyFS.getContent;

	public static var getBytes:String -> Null<Bytes> = MyFS.getBytes;

	public static var saveContent:String -> String -> Void = MyFS.saveContent;

	public static var saveBytes:String -> Bytes -> Void = MyFS.saveBytes;

	public static var deleteDirectory:String -> Void = MyFS.deleteDirectory;

	public static var deleteFile:String -> Void = MyFS.deleteFile;

	public static var rename:String -> String -> Void = MyFS.rename;

	public static var mount:String -> Void = MyFS.mount;

	public static function tree(path : String):Array<String> {
		return MyFS.getAll();
	}

	public static var folder:String -> Directory = MyFS.folder;
	public static var file:String -> File = MyFS.file;
}

#if (cpp||neko)

	typedef MyFS = gryffin.storage.fs.NativeFileSystem;

#elseif (html5)

	typedef MyFS = gryffin.storage.fs.JSFileSystem;

#end