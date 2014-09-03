/*
	gryffin.utils.Console - debugging/logging utility class
 #===========================================================#
	When the [debug] flag is set, it will print to standard-output, otherwise, it will
	write all "logs" to a file.
*/
package gryffin.utils;

import gryffin.io.StdOut;
import gryffin.io.Stream;
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
}