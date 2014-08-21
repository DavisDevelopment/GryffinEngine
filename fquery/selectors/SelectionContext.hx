package gryffin.fquery.selectors;


import gryffin.utils.PathTools;
import gryffin.utils.ArrayTools;

import gryffin.storage.fs.FileSystem;
import gryffin.storage.fs.tools.FSEntry;
import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;
import gryffin.fquery.selectors.Lexer;
import gryffin.fquery.selectors.Parser;
import gryffin.fquery.selectors.Compiler;


class SelectionContext {
	public var selector:String;
	public var entries:Array<FSEntry>;
	public var matches:Array<FSEntry>;
	public var filters:Array<Filter>;
	public var generics:Map<String, String>;

	public function new(sel : String):Void {
		this.selector = sel;
		var pieces:Array<String> = [sel];

		this.filters = [for (piece in pieces) getFilter(piece).bind(_)];
		this.entries = getAllEntries();
		this.matches = new Array();

		this.update();
	}
	private function getMatches():Void {
		var filter_from = entries.copy();
		this.matches = filter_from;

		for (filter in filters) {
			this.matches = this.matches.filter(filter);
		}
	}
	public function update():Void {
		getMatches();
	}

	private inline function getFilter(sel:String):Filter {
		return Compiler.compile(Parser.staticParse(Lexer.staticLex(sel)));
	}

	private static inline function getFileSet(paths:Array<String>):Array<FSEntry> {
		var files:Array<FSEntry> = new Array();

		for (name in paths) {
			if (FileSystem.isDirectory(name)) {
				files.push(cast FileSystem.folder(name));
			} else {
				files.push(FileSystem.file(name));
			}
		}

		return files;
	}
	private static inline function getAllEntries():Array<FSEntry> {
		var all_names:Array<String> = FileSystem.tree('');
		var files:Array<FSEntry> = new Array();

		for (name in all_names) {
			if (FileSystem.isDirectory(name)) {
				files.push(cast FileSystem.folder(name));
			} else {
				files.push(FileSystem.file(name));
			}
		}

		return files;
	}
}

private typedef Filter = FSEntry -> Bool;