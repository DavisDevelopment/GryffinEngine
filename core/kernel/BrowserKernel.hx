package gryffin.core.kernel;

class BrowserKernel {
	public static function notify(title:String, msg:String):Void {
		null;
	}
	public static function alert(msg : String):Void {
		js.Browser.window.alert(msg);
	}
}