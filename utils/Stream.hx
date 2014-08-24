package gryffin.utils;

import gryffin.EventDispatcher;
import gryffin.intel.Packet;

@:allow(Stream)
class Stream <T> {
	public var peer:Null<Stream<T>>;
	public var connected(get, never):Bool;

	private var es:EventDispatcher;

	public var onMessage:Dynamic;

	public function new():Void {
		this.peer = null;
		this.onMessage = null;
		this.es = new EventDispatcher();

		es.on('msg', function(msg:Packet<T>):Void {
			if (Reflect.isFunction(onMessage)) {
				onMessage(msg);
			}
		});
	}
	public function connect(other:Stream<T>):Void {
		this.peer = other;
	}
	private function _getMessage(msg:Packet<T>):Void {
		es.emit('msg', msg);
	}
	public function postMessage(message:T):Null<T> {
		if (connected) {
			var packt:Packet<T> = new Packet(message);
			peer._getMessage(packt);

			return packt.read();
		} else {
			return null;
		}
	}
	private inline function get_connected():Bool {
		return (peer != null);
	}
}