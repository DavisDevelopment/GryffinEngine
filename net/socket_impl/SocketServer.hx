package gryffin.net.socket_impl;

import haxe.io.Bytes;
import gryffin.utils.Buffer;
import gryffin.net.socket_impl.NodeConnection;

class NodeSocketServer {
	public var app:Dynamic;
	public var connections:Map<Int, NodeConnection>
}