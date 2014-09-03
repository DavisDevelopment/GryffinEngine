package gryffin.core;

#if html5
	private typedef CurrentSystem = gryffin.core.systems.BrowserSystem;
#elseif desktop
	private typedef CurrentSystem = gryffin.core.systems.DesktopSystem;
#end

private typedef CS = CurrentSystem;

class System {
	public static var name(get, never):String;
	private static inline function get_name():String {
		return (CS.name);
	}
}