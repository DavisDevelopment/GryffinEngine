/*
	gryffin.utils.Console - debugging/logging utility class
 #===========================================================#
	When the [debug] flag is set, it will print to standard-output, otherwise, it will
	write all "logs" to a file.
*/
package gryffin.utils;

import gryffin.io.StdOut;
import gryffin.io.Stream;
import gryffin.io.DataSource;
import gryffin.storage.fs.FileSystem;

class Console {
	public static var out:Stream = StdOut.stream;

	public static function log(dat : Dynamic):Void {
		#if debug
			trace(dat);
		#else
			writeLogToFile(dat);
		#end
	}
	private static function writeLogToFile(dat : Dynamic):Void {
		return;
	}

	public static function prompt(msg:String):String {
		var src = new DataSource<String>(function():String {
			#if desktop
				return Sys.stdin().readLine();
			#elseif html5
				return untyped window.prompt(msg, '');
			#end
			return '';
		});
		#if desktop
		out.open();
		out << msg;
		out.close();
		#end
		return src.get();
	}
}