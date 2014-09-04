package gryffin.io;

import gryffin.EventDispatcher;
import gryffin.io.Output;
import gryffin.utils.Buffer;

import haxe.macro.Context;
import haxe.macro.Expr;

@:forward(onInputReceived, out)
abstract Stream(IStream) {
	private var self(get, never):Stream;
	public inline function new():Void {
		this = new IStream();
	}
	private inline function get_self():Stream {
		return cast this;
	}
	public inline function open():Stream {
		this.open();
		return self;
	}

	@:op(A << B)
	public inline function write(inp : Dynamic):Stream {
		return cast this.write(inp);
	}

	public inline function close():Void {
		this.close();
	}
}

class IStream extends EventDispatcher {
	public var onInputReceived(default, set):Null<Dynamic->Void>;
	public var out:Null<Output>;

	public function new():Void {
		super();
		this.out = null;
		this.onInputReceived = null;
	}
	public function open():Void {
		this.out = new Output();
	}
	public function write(inp : Dynamic):IStream {
		this.out.writeString(Std.string(inp));
		return this;
	}
	public function close():Void {
		var data:Buffer = this.out.empty();
		this.emit('input-received', data);
	}

	private inline function set_onInputReceived(oir:Null<Dynamic->Void>):Null<Dynamic->Void> {
		this.unbind('input-received');
		this.on('input-received', oir);
		return oir;
	}
}