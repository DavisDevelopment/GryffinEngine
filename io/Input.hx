package gryffin.io;

import gryffin.utils.Buffer;
import gryffin.io.DataSource;

class Input extends NativeInput {
	public var source:DataSource<Buffer>;
	private var cursor:Int;
	private var data_available:Buffer;

	public function new(src:DataSource<Buffer>):Void {
		this.cursor = 0;

		//- Empty Buffer, only a placeholder
		this.data_available = Buffer.alloc(0);
		this.source = src;

		this.source.on(DataSource.DATA_AVAILABLE, function(data:Buffer):Void {
			this.giveData(data);
		});
	}
	public function giveData(buf:Buffer):Void {
		this.data_available = buf;
	}
	override public function readByte() : Int {
		try {
			var result:Int = data_available[0];
			data_available = data_available.slice(1);
			return result;
		} catch (err : String) {
			trace(err);
		}
	}
}

private typedef NativeInput = haxe.io.Input;