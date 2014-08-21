package gryffin.storage.fs.tools;

interface FSEntry {
	var entry_type:Int;
	var name:String;
	var parent(get, set):Directory;
	var parents(get, never):Array<FSEntry>;
}