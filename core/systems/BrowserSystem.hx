package gryffin.core.systems;

import gryffin.core.SystemKernel;

class BrowserSystem {
	public static var name(get, never):String;
	private static inline function get_name():String {
		return "web";
	}
}