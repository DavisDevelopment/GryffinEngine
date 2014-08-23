package gryffin.utils;

import gryffin.utils.Buffer;

import openfl.Assets;
import flash.display.BitmapData;

@:forward(name, exists, bytes, content, bitmap)
abstract Asset(IAsset) {
	private var self(get, never):Asset;
	public inline function new(ref:String):Void {
		this = new IAsset(ref);
	}
	private inline function get_self():Asset {
		return cast this;
	}
//== Implicit Casting Methods ==//
	@:to 
	public inline function toIAsset():IAsset {
		return cast this;
	}
	@:to 
	public inline function toBuffer():Buffer {
		return this.bytes;
	}
	@:to 
	public inline function toString():String {
		return this.content;
	}
	@:to 
	public inline function toBitmapData():BitmapData {
		return this.bitmap;
	}

	@:from 
	public static inline function fromString(ref:String):Asset {
		return new Asset(ref);
	}
}

class IAsset {
	public var name:String;
	public var exists(get, never):Bool;
	public var bytes(get, never):Buffer;
	public var content(get, never):String;
	public var bitmap(get, never):BitmapData;

	private var _bytes:Null<Buffer>;
	private var _content:Null<String>;
	private var _bitmap:Null<BitmapData>;

	public function new(ref : String):Void {
		this.name = ref;
	}
	private inline function get_exists():Bool {
		return Assets.exists(name);
	}
	private inline function get_bytes():Buffer {
		if (_bytes != null) return _bytes;
		
		var bits:Null<Buffer> = cast Assets.getBytes(name);
		_bytes = bits;
		return bits;
	}
	private inline function get_content():String {
		if (_content != null) return _content;

		var str:String = Assets.getText(name);
		_content = str;
		return str;
	}
	private inline function get_bitmap():BitmapData {
		if (_bitmap != null) return _bitmap;

		var bm:BitmapData = Assets.getBitmapData(name);
		_bitmap = bm.clone();
		return _bitmap;
	}
}