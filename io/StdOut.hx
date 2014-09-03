package gryffin.io;

import gryffin.io.Stream;
import gryffin.utils.Console;

class StdOut {
	public static var stream:Stream;

	private inline static function __init__():Void {
		stream = new Stream();
		stream.onInputReceived = function(x):Void {
			Console.log(x);
		};
	}
}