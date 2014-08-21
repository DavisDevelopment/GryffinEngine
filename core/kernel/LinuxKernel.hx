package gryffin.core.kernel;

class LinuxKernel {
	public function alert(message:String):Void {
		var proc:sys.io.Process = new sys.io.Process('notify-send', [message]);
	}
}