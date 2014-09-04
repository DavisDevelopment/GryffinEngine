package gryffin.core.systems;

import gryffin.core.SystemKernel;

class DesktopSystem {
	public static var name(get, never):String;
	private static inline function get_name():String {
		return (Sys.systemName().toLowerCase());
	}
}