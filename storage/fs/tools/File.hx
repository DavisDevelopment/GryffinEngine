package gryffin.storage.fs.tools;

import haxe.io.Bytes;
import gryffin.utils.Buffer;
import haxe.crypto.Base64;


import gryffin.utils.MimeTypes;
import gryffin.storage.fs.tools.Directory;
import gryffin.storage.fs.tools.FSEntry;
import gryffin.storage.fs.FileSystem;

using gryffin.utils.PathTools;
class File implements FSEntry {
	public var name:String;
	public var entry_type:Int;
	public var mime_type:Null<String>;
	public var bytes(get, set):Null<Bytes>;
	public var buffer(get, set):Null<Buffer>;
	public var content(get, set):Null<String>;
	public var parent(get, set):Null<Directory>;
	public var parents(get, never):Array<FSEntry>;

	public function new(name:String):Void {
		this.name = name;
		this.entry_type = 1;

		var extension:String = this.name.normalize().extname();
		this.mime_type = MimeTypes.getMimeType(extension);
	}
	private inline function get_bytes():Null<Bytes> {
		return FileSystem.getBytes(name);
	}
	private inline function get_buffer():Null<Buffer> {
		return (FileSystem.exists(name) ? (new Buffer(this.bytes)) : null);
	}
	private inline function get_content():Null<String> {
		return FileSystem.getContent(name);
	}
	private inline function set_bytes(nbytes:Null<Bytes>):Null<Bytes> {
		FileSystem.saveBytes(name, nbytes);
		return nbytes;
	}
	private inline function set_buffer(nbuffer:Null<Buffer>):Null<Buffer> {
		FileSystem.saveBytes(name, cast nbuffer);
		return nbuffer;
	}
	private inline function set_content(ncontent:Null<String>):Null<String> {
		FileSystem.saveContent(name, ncontent);
		return ncontent;
	}
	private inline function get_parent():Null<Directory> {
		var parent_path:String = this.name.normalize().parent().normalize();

		if (parent_path != '') {
			return FileSystem.folder(parent_path);
		} else {
			return null;
		}
	}
	private inline function set_parent(nparent:Directory):Directory {
		return nparent;
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
}