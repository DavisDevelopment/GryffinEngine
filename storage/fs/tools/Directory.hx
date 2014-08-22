package gryffin.storage.fs.tools;

import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.FSEntry;
import gryffin.storage.fs.FileSystem;

using gryffin.utils.PathTools;

@:forward(name, parent, parents, file, folder)
abstract Directory(IDirectory) {
	public inline function new(name : String):Void {
		this = new IDirectory(name);
	}

	@:to 
	public inline function toEntry():FSEntry {
		return this;
	}
}

class IDirectory implements FSEntry {
	public var name:String;
	public var entry_type:Int;
	public var parent(get, set):Null<Directory>;
	public var parents(get, never):Array<FSEntry>;

	public function new(name : String):Void {
		this.entry_type = 1;
		this.name = name;
	}
	private function get_parent():Null<Directory> {
		var parent_path:String = name.normalize().parent().normalize();
		if (parent_path == '') return null;

		if (FileSystem.exists(parent_path) && FileSystem.isDirectory(parent_path)) {
			return FileSystem.folder(parent_path);
		} else {
			return null;
		}
	}
	private function set_parent(dir:Null<Directory>):Null<Directory> {
		return dir;
	}
	private function get_parents():Array<FSEntry> {
		var ctx:Null<FSEntry> = this.parent;
		var list:Array<FSEntry> = new Array();

		while(ctx != null) {
			list.push(ctx);
			ctx = ctx.parent;
		}
		return list;
	}
	public function file(id : String):File {
		return FileSystem.file(this.name.normalize().joinWith([id.normalize()]));
	}
	public function folder(id : String):IDirectory {
		return cast FileSystem.folder(this.name.normalize().joinWith([id.normalize()]));
	}
}