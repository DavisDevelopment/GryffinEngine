package gryffin.storage.fs;

import gryffin.Utils;
import gryffin.storage.VirtualVolume;
import haxe.io.Bytes;

import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;
import gryffin.storage.fs.AssetFileSystem;

import openfl.Assets;

using gryffin.utils.PathTools;

@:allow(gryffin.storage.fs.FileSystem)
class NativeFileSystem {
	private static inline var LOAD_ASSETS:Bool = true;
	private static var volume:VirtualVolume;
	private static var all:Array<String>;

	public static function initialize():Void {
		load();
		AFS.initialize();

		all = getAll();
	}
	private static function getAll():Array<String> {
		var entries:Array<String> = [for (e in volume.entries) e.name];
		entries = entries.concat(AFS.getAll());
		return entries;
	}
	private static function load():Void {
		if (FS.exists(LS_KEY)) {
			var content:String = HFile.getContent(LS_KEY);
			try {
				volume = VirtualVolume.unserialize(content);
				return;
			} catch (err : String) {
				null;
			}
		}
		volume = new VirtualVolume();
		HFile.saveContent(LS_KEY, volume.serialize());
	}
	private static function save():Void {
		HFile.saveContent(LS_KEY, volume.serialize());
	}

	public static function exists(name : String):Bool {
		return volume.exists(name);
	}
	/**
	 * Determines whether given path exists **only** in our virtual filesystem registry,
	 * as oppposed to checking if it exists in either our registry **or** the asset registry
	 * ---
	 * @return Bool
	 */
	public static function isLocal(name:String):Bool {
		return ((isFile(name) && !AFS.isFile(name)) || (isDirectory(name) && !AFS.isDirectory(name)));
	}
	public static function isDirectory(name:String):Bool {
		return (volume.isDirectory(name) || AFS.isDirectory(name));
	}
	public static function isFile(name:String):Bool {
		return (volume.isFile(name) || AFS.isFile(name));
	}
	public static function isEmpty(name:String):Bool {
		return (volume.isEmpty(name) || AFS.isEmpty(name));
	}

	public static function createDirectory(name : String):Void {
		volume.createDirectory(name);
		save();
	}
	private static function readRoot():Array<String> {
		var all_entries = volume.entries;
		var root_entries:Array<String> = all_entries.map(function(x) {
			return (x.name.root());
		});
		root_entries.pop();
		root_entries = Utils.uniqueItems(root_entries);

		return root_entries;
	}
	public static function readDirectory(name : String):Array<String> {
		name = name.simplify();
		var all:Array<String> = [for (entry in volume.entries) entry.name];
		if (name == '') {
			return readRoot().concat(AFS.readDirectory(''));
		} else {
			var ret:Array<String> = all.filter(function(x:String):Bool {
				return (x.parent().simplify() == name);
			});
			ret = ret.concat(AFS.readDirectory(name));
			return ret;
		}
	}

	public static function getContent(name : String):String {
		if (isFile(name)) {
			return (isLocal(name) ? volume.getContent(name) : AFS.getContent(name));
		} else {
			return '';
		}
	}

	public static function getBytes(name : String):Bytes {
		if (isFile(name)) {
			return (isLocal(name) ? volume.getBytes(name) : AFS.getBytes(name));
		} else {
			return Bytes.alloc(0);
		}
	}

	public static function saveContent(name:String, content:String):Void {
		var dir:String = name.simplify().dirname();
		if (!exists(name)) {
			if (dir != '') {
				if (isDirectory(dir)) {
					if (!isLocal(dir)) {
						volume.createDirectory(dir);
					}
				} else {
					volume.createDirectory(dir);
				}
			}
			volume.createFile(name);
		}
		volume.saveContent(name, content);
		save();
	}
	public static function saveBytes(name:String, content:Bytes):Void {
		var dir:String = name.simplify().dirname();
		if (!exists(name)) {
			if (dir != '') {
				if (isDirectory(dir)) {
					if (!isLocal(dir)) {
						volume.createDirectory(dir);
					}
				} else {
					volume.createDirectory(dir);
				}
			}
			volume.createFile(name);
		}
		volume.saveBytes(name, content);
		save();
	}
	public static function deleteDirectory(name : String):Void {
		volume.deleteDirectory(name);
		save();
	}
	public static function deleteFile(name : String):Void {
		volume.deleteFile(name);
		save();
	}
	public static function rename(from:String, to:String):Void {
		if (isDirectory(from)) {
			if (!exists(to))
				createDirectory(to);
			for (file_name in readDirectory(from)) {
				var oldp:String = from.joinWith([file_name.basename()]).simplify();
				var newp:String = (to.simplify().joinWith([file_name.basename()]).simplify());
				trace([oldp, newp]);
				rename(oldp, newp);
			}
			deleteDirectory(from);
		} else {
			saveBytes(to, getBytes(from));
			deleteFile(from);
		}

		//save();
	}
	public static function mount(path : String):Void {
		var data:Null<String> = getContent(path);
		if (data != null) {
			try {
				var partition:VirtualVolume = VirtualVolume.unserialize(data);
				for (entry in partition.entries) {
					if (!exists(entry.name)) {
						switch (entry.type) {
							case 0:
								saveBytes(entry.name, entry.data);

							case 1:
								createDirectory(entry.name);
						}
					}
				}
			} catch (err : String) {
				trace(err);
			}
		}
	}

	public static function file(name : String):File {
		return new File(name);
	}
	public static function folder(name : String):Directory {
		return new Directory(name);
	}


	private static inline var LS_KEY:String = '__gryffin_fs__.vfs';
}

private typedef AFS = AssetFileSystem;
private typedef FS = sys.FileSystem;
private typedef HFile = sys.io.File;