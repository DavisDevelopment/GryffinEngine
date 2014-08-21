package gryffin.core.kernel;

#if android
	import openfl.utils.JNI;

	class AndroidKernel {
		private static var _present:Void->Int;
		public static function present():Int {
			return _present();
		}

		private static var _alert:String->String->(Bool->Void)->Void;
		public static function alert(title : String, content : String, callback : Bool -> Void):Void {
			_alert(title, content, callback);
		}

		public static function __init__():Void {
			_present = JNI.createStaticMethod("org/davisdevelopment/kernel/AndroidKernel", "present", "()I");
			_alert = JNI.createStaticMethod("org/davisdevelopment/kernel/AndroidKernel", "alert", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)");
		}
	}
#end