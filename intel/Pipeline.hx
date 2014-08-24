package gryffin.intel;

import gryffin.utils.Stream;
import gryffin.intel.Packet;

class Pipeline<T> {
	public var listening:Bool;
	public var connected(get, never):Bool;

	//- Server Pipeline Classes
	public var streams:Array<Stream<T>>;
	public var onMessage:Null<Packet<T> -> Void>;

	//- Client Pipeline Classes
	public var client:Null<Stream<T>>;
	public var connection:Null<Stream<T>>;

	public function new():Void {
		this.listening = false;
		this.streams = new Array();
	}

	public function send(message:T):Void {
		if (this.connected) {
			var response:Null<T> = this.client.postMessage(message);
		}
	}

	public function broadcast(message:T):Void {
		if (this.listening) {
			for (client in this.streams) {
				var response:Null<T> = client.postMessage(message);
				if (response != null) {

					this.send(response);

				}
			}
		}
	}

	public function connect(server:Pipeline<T>):Void {
		if (!listening)	{
			this.client = new Stream();
			this.client.onMessage = function(msg:Packet<T>):Void {
				if (onMessage != null) onMessage(msg);
			};
			this.connection = server.requestConnection(this.client);
		}
	}

	public function listen():Void {
		this.listening = true;
	}

	public function requestConnection(from:Stream<T>):Stream<T> {
		var peer:Stream<T> = new Stream();
		peer.onMessage = function(msg:Packet<T>):Void {
			if (this.onMessage != null) {
				this.onMessage(msg);
			}
		};
		peer.connect(from);
		from.connect(peer);
		streams.push(peer);

		return peer;
	}

	private inline function get_connected():Bool {
		return (this.client != null && this.connection != null);
	}
}