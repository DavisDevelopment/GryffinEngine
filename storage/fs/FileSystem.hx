package gryffin.storage.fs;

import haxe.io.Bytes;
import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;

using gryffin.utils.PathTools;
@:expose
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

	public static function tree(path : String):Array<String> {
		function branch(_path:String):Array<String> {
			var sub_files:Array<String> = readDirectory(_path);
			var files:Array<String> = [];
			for (f in sub_files) {
				#if !html5
				//f = _path.joinWith([f]);
				if (isDirectory(f)) {
					files.push(_path.joinWith([f]).simplify());
					files = files.concat(branch(f));
				}
				else if (isFile(f)) {
					files.push(_path.joinWith([f]).simplify());
				}
				#else
				if (isDirectory(f)) {
					files.push(f);
					files = files.concat(branch(f));
				} else {
					files.push(f);
				}
				#end
			}
			return files;
		}
		var branch:String->Array<String> = gryffin.Utils.memoize(branch);
		var found:Array<String> = branch(path);
		found = [for (f in found) f.normalize()];
		return found;
	}

	public static var folder:String -> Directory = MyFS.folder;

	public static var file:String -> File = MyFS.file;
}

#if (cpp||neko)

	typedef MyFS = gryffin.storage.fs.NativeFileSystem;

#elseif (html5)

	typedef MyFS = gryffin.storage.fs.JSFileSystem;

#end