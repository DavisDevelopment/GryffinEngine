package gryffin.utils;

import motion.Actuate;
import gryffin.EventDispatcher;
import sys.FileSystem;
import sys.FileStat;

class File extends EventDispatcher {
	public var full_name:String;
	private var last_known_stats:Null<FileStat>;
	public var stats(get, never):Null<FileStat>;

	private var _content:String;
	//public var content(get, set):String;

	public function new(name : String):Void {
		super();

		this.full_name = name;
		this.last_known_stats = null;
		this._content = "";

		this.startCheckLoop();
	}
	
	private function startCheckLoop():Void {
		var me = this;
		var last_lmodded:Null<Float> = null;
		function runCheck() {
			if (me.stats != null) {
				var last_modified:Float = (me.stats.mtime).getTime();
				if (last_lmodded == null) {
					last_lmodded = last_modified;
				} else {
					if (last_modified != last_lmodded) {
						me.emit('modify', me);
					}
				}
			}
			Actuate.timer(0.02).onComplete(runCheck, null);
		}
		runCheck();
	}


	private function get_stats():Null<FileStat> {
		if (FileSystem.exists(full_name)) {
			var res = FileSystem.stat(full_name);
			return res;
		} else {
			return null;
		}
	}
}