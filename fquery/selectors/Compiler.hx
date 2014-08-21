package gryffin.fquery.selectors;

import gryffin.fquery.selectors.FileDesc;
import gryffin.fquery.selectors.SelectionContext;
import gryffin.storage.fs.FileSystem;

import gryffin.storage.fs.tools.FSEntry;
import gryffin.storage.fs.tools.File;
import gryffin.storage.fs.tools.Directory;

using gryffin.utils.PathTools;
class Compiler {
	public var ctx:Null<SelectionContext>;
	public var descriptors:Array<FileDesc>;
	public var tests:Array<SelectionOp>;

	public function new(?ctx:Null<SelectionContext>):Void {
		this.ctx = ctx;
		this.descriptors = new Array();
		this.tests = new Array();
	}
	private function getChildren(fse:FSEntry):Array<FSEntry> {
		var paths:Array<String> = FileSystem.readDirectory(fse.name.simplify());
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
	public function getFilterFunction(desc : FileDesc):SelectionOp {
		var isfolder:FSEntry->Bool = function(x:FSEntry) return (x.entry_type == 0);

		switch (desc) {
			case FileDesc.FAny:
				return function(fse:FSEntry) {
					
				};

			case FileDesc.FName(name):
				function testName(fse:FSEntry):Null<Array<FSEntry>> {
					var res:Array<FSEntry> = new Array();
					var hierarchy:Array<String> = [for (entry in fse.parents) entry.name.normalize()];
					hierarchy.push(fse.name.normalize());

					if (!isfolder(fse)) {
						if (Lambda.has(hierarchy, fse.name.normalize())) {
							res.push(fse);
						} else {
							return null;
						}
					} else {
						var kids:Array<FSEntry> = getChildren(fse);
						for (kid in kids) {
							res = res.concat(testName(kid));
						}
					}
					
					return res;
				};
				return testName;

			case FileDesc.FGeneric(key):
				return function(fse:FSEntry) {
					return (isfolder(fse)?[fse].concat(getChildren(fse)):[fse]);
				};

			case FileDesc.FChildOf(parent, child):
				var parent_tester = getFilterFunction(parent);
				var child_tester = getFilterFunction(child);
				return function(fse:FSEntry) {
					return [];
				};

			case FileDesc.FHasExtension(file, ext):
				var file_tester = getFilterFunction(file);
				return function(fse:FSEntry) {
					var res:Array<FSEntry> = new Array();
					
					var test_from:Null<Array<FSEntry>> = file_tester(fse);
					if (test_from == null) test_from = [];

					for (entry in test_from) {
						if (entry.name.extname() == ext) {
							res.push(entry);
						}
					}

					return res;
				};

			case FileDesc.FBlock(set):
				return (new Compiler().compileDescriptors(set));

			default:
				trace(desc);
		}
	}
	private inline function getTests(ops : Array<FileDesc>):Array<SelectionOp> {
		var tests:Array<SelectionOp> = new Array();
		for (op in ops) {
			var test =  getFilterFunction(op);
			if (test != null) {
				tests.push(test);
			}
		}
		return tests;
	}
	public function compileDescriptors(ops : Array<FileDesc>):SelectionOp {
		trace(ops);
		this.descriptors = ops;
		this.tests = getTests(ops);

		return function(entry : FSEntry):Bool {
			for (test in tests) {
				if (!test(entry)) return false;
			}
			return true;
		};
	}

	public static function compile(ops:Array<FileDesc>, ?ctx:Null<SelectionContext>):SelectionOp {
		return new Compiler(ctx).compileDescriptors(ops);
	}
}

private typedef SelectionOp = FSEntry -> Bool;