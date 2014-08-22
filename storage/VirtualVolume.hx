package gryffin.storage;

//import gryffin.utils.PathTools;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;

import gryffin.utils.Buffer;


using gryffin.utils.PathTools;
class VirtualVolume {
	public var entries:Array<Entry>;

	public function new():Void {
		this.entries = new Array();
	}
	private function createEntry(type:Int, name:String, ?data:Null<Bytes>):Entry {
		var entry:Entry = {
			'name' : name,
			'type' : type,
			'data' : null,
			'meta' : new Map()
		};
		switch (type) {
			case FILE:
				data = Bytes.alloc(0);
			default:
				null;
		}

		return entry;
	}
	private function retrieve_entry_by_name(id : String):Null<Entry> {
		for (entry in entries) {
			if (entry.name == id) return entry;
		}
		return null;
	}
	public function exists(id : String):Bool {
		for (entry in this.entries) {
			if (entry.name == id) return true;
		}
		return false;
	}
	public function isDirectory(id : String):Bool {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null) {
			return (entry.type == FOLDER);
		} else {
			return false;
		}
	}
	public function isFile(id : String):Bool {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null) {
			return (entry.type == FILE);
		} else {
			return false;
		}
	}
	public function isEmpty(id : String):Bool {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null) {
			switch (entry.type) {
				case FILE:
					return (entry.data == null || entry.data.length == 0);
				case FOLDER:
					return (readDirectory(id).length == 0);
				default:
					return true;
			}
		} else {
			return true;
		}
	}
	public function createDirectory(id : String):Void {
		var parent:String = id.normalize().parent().normalize();
		if (parent != '') {
			if (!exists(parent)) {
				createDirectory(parent);
			}
			else if (!isDirectory(parent)) {
				throw 'IOError: Cannot create sub-directory of a file that is not a directory';
			}
		}
		if (!exists(id)) {
			this.entries.push(createEntry(FOLDER, id, null));
		}
	}
	public function readDirectory(id : String):Array<String> {
		var kids:Array<String> = new Array();
		for (entry in entries) {
			if (entry.name.normalize().parent().normalize() == id.normalize()) {
				kids.push(entry.name.normalize());
			}
		}
		return kids;
	}
	public function createFile(id : String):Void {
		var parent:String = id.normalize().parent().normalize();
		if (parent != '') {
			if (!isDirectory(parent))
				throw 'IOError: Cannot append file to non-directory filesystem entry';
		}
		if (!exists(id)) {
			this.entries.push(createEntry(FILE, id));
		}
	}
	public function getContent(id : String):String {
		var entry:Entry = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			return (entry.data.toString());
		} else {
			return '';
		}
	}
	public function saveContent(id:String, content:String):Void {
		var entry:Entry = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			entry.data = Bytes.ofString(content);
		} else {
			throw 'IOError: Cannot manipulate non-standard and/or non-existent file';
		}
	}
	public function getBytes(id : String):Bytes {
		var entry:Entry = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			return entry.data;
		} else {
			throw 'IOError: Cannot read byte-values in an empty / open file';
		}
	}
	private function cloneBytes(bits:Bytes):Bytes {
		return cast (new Buffer(bits).copy());
	}
	public function saveBytes(id:String, bits:Bytes):Void {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			entry.data = cloneBytes(bits);
		} else {
			null;
		}
	}
	public function deleteDirectory(name : String):Void {
		if (isDirectory(name)) {
			var pointers:Array<String> = [name];
			pointers = pointers.concat(readDirectory(name));

			for (entry_name in pointers) {
				var entry = retrieve_entry_by_name(entry_name);
				entries.remove(entry);
			}
		}
	}
	public function deleteFile(name : String):Void {
		entries.remove(retrieve_entry_by_name(name));
	}
	public function getMeta(id:String, key:String):Null<Dynamic> {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			return entry.meta.get(key);
		} else {
			return null;
		}
	}

	public function setMeta(id:String, key:String, value:Dynamic):Void {
		var entry:Null<Entry> = retrieve_entry_by_name(id);
		if (entry != null && entry.type == FILE) {
			entry.meta.set(key, value);
		}
	}

	public function serialize():String {
		return Serializer.run(entries);
	}

	public static function unserialize(serial : String):VirtualVolume {
		var vv:VirtualVolume = new VirtualVolume();
		var _pkids:Array<Dynamic> = Unserializer.run(serial);
		var kids:Array<Entry> = [for (kid in _pkids) kid];

		vv.entries = kids;

		return vv;
	}


	public static inline var FILE:Int = 0;
	public static inline var FOLDER:Int = 1;
}

typedef Entry = {
	type : Int,
	name : String,
	data : Null<Bytes>,
	meta : Map<String, Dynamic>
};