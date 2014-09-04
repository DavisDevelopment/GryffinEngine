package gryffin.io;

import gryffin.utils.Buffer;

class Output extends NativeOutput {
	private var buffer:String;

	public function new():Void {
		this.buffer = "";
	}
	public function empty():Buffer {
		var result:Buffer = buffer;
		this.buffer = "";
		return result;
	}
	override public function writeByte(c : Int):Void {
		this.buffer += String.fromCharCode(c);
	}
}

private typedef NativeOutput = haxe.io.Output;