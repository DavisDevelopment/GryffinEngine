package gryffin.net;

abstract Packet<T>(IPacket<T>) {
	public inline function new(msg:T):Void {
		this = new IPacket(msg);
	}
	public inline function read():T {
		return this.message;
	}
	public inline function write(res:T):Void {
		this.response = res;
	}
}

private class IPacket <T> {
	public var message:T;
	public var response:Null<T>;

	public function new(msg:T):Void {
		this.message = msg;
		this.response = null;
	}
}