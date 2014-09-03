package gryffin.utils;

import haxe.io.Bytes;

#if openfl
import openfl.utils.ByteArray;
#end

import gryffin.Utils;

@:forward(length)
abstract Buffer(Bytes) {
	public inline function new(bytes : Bytes):Void {
		this = bytes;
	}

	public inline function slice(start:Int, ?end:Null<Int>):Buffer {
		if (end == null) end = this.length;
		if (end < 0) {
			end = (this.length - end);
		}
		var len:Int = (end - start) - 1;
		return new Buffer(this.sub(start, len));
	}

	public inline function copy():Buffer {
		return Buffer.fromBytes(this).slice(0);
	}

	public inline function iterator():Iterator<Int> {
		var buf:Buffer = new Buffer(this);
		var i:Int = 0;

		var iter:Iterator<Int> = {
			'next' : function():Int {
				i++;
				return buf[i];
			},
			'hasNext' : function():Bool {
				return (i <= buf.length);
			}
		};
		return iter;
	}
	
	private static inline function add(one:Buffer, other:Buffer):Buffer {
		other = cast(other, Buffer);
		one = cast(one, Buffer);

		var sum:Bytes = Bytes.alloc(one.length + other.length);

		sum.blit(0, one, 0, one.length);
		sum.blit(one.length, other, 0, other.length);

		return new Buffer(sum);
	}

	@:op(A + B)
	public inline function addBuffer(other : Buffer):Buffer {
		return add(Buffer.fromBytes(this), other);
	}
	@:op(A + B)
	public inline function addBytes(other : Bytes):Buffer {
		return add(Buffer.fromBytes(this), Buffer.fromBytes(other));
	}

#if openfl
	@:op(A + B)
	public inline function addByteArray(other : ByteArray) {
		return add(Buffer.fromBytes(this), Buffer.fromByteArray(other));
	}
#end

	@:op(A + B)
	public inline function addString(other : String):Buffer {
		return add(Buffer.fromBytes(this), Buffer.fromString(other));
	}

	@:op(A + B)
	public inline function addInt(other : Int):Buffer {
		var copy:Buffer = Buffer.fromBytes(this).copy();
		copy[copy.length] = other;

		return copy;
	}

	@:op(A / B)
	public inline function divide(by : Int):Array<Buffer> {
		var index:Int = 0;
		var buf:Buffer = Buffer.fromBytes(this);
		var buffers:Array<Buffer> = new Array();

		while (index < buf.length) {
			var piece:Buffer = Buffer.alloc(by);
			for (i in 0...by) {
				piece[i] = buf[index++];
			}
			buffers.push(piece);
		}

		return buffers;
	}

	@:op(A * B)
	public inline function repeat(times : Int):Buffer {
		var int_list:Array<Int> = Buffer.fromBytes(this).toArray();
		var result:Array<Int> = int_list.copy();

		for (i in 0...(times - 1)) {
			result = result.concat(int_list);
		}

		return Buffer.fromIntArray(result);
	}

	private static function compare(one:Buffer, other:Buffer):Bool {
		if (one.length == other.length) {
			for (i in 0...(one.length - 1)) {
				if (!(one[i] == other[i])) return false;
			}
			return true;
		} else {
			return false;
		}
	}

	@:op(A == B)
	public inline function compareToBuffer(other : Buffer):Bool {
		return compare(Buffer.fromBytes(this), other);
	}

	@:op(A == B)
	public inline function compareToBytes(other : Bytes):Bool {
		return compare(Buffer.fromBytes(this), Buffer.fromBytes(other));
	}

	@:op(A == B)
	public inline function compareToString(other : String):Bool {
		return compare(Buffer.fromBytes(this), Buffer.fromString(other));
	}

	@:arrayAccess(Int)
	public inline function getIntAt(index : Int):Null<Int> {
		try {
			return this.get(index);
		} catch (err:String) {
			return null;
		}
	}

	@:arrayAccess(Int)
	public inline function setIntAt(index:Int, val:Int):Int {
		this.set(index, val);
		return val;
	}

	@:to
	public inline function toBytes():Bytes {
		return this;
	}

	@:to
	public inline function toString():String {
		return this.toString();
	}

	@:to
	public inline function toArray():Array<Int> {
		var set:Array<Int> = new Array();
		var i:Int = 0;
		while (i < this.length) {
			set.push(this.get(i));
			i++;
		}
		return set;
	}

#if openfl
	@:to
	public inline function toByteArray():ByteArray {
		var intArray:Array<Int> = (new Buffer(this).toArray());
		var ba:ByteArray = new ByteArray();

		for (i in 0...intArray.length) {
			ba.position = i;
			ba.writeInt(intArray[i]);
		}
		ba.position = 0;

		return ba;
	}
#end

	@:from
	public static inline function fromBytes(bits : Bytes):Buffer {
		return new Buffer(bits);
	}

#if openfl
	@:from
	public static inline function fromByteArray(bits : ByteArray):Buffer {
		return new Buffer(Utils.ByteArrayToBytes(bits));
	}
#end

	@:from
	public static inline function fromString(chars:String):Buffer {
		return new Buffer(Bytes.ofString(chars));
	}

	@:from
	public static inline function fromIntArray(set:Array<Int>):Buffer {
		var bytes:Bytes = Bytes.alloc(set.length);

		for (i in 0...set.length) {
			bytes.set(i, set[i]);
		}

		return bytes;
	}

	@from
	public static inline function fromFloatArray(set:Array<Float>):Buffer {
		var bytes:Bytes = Bytes.alloc(set.length);

		for (i in 0...set.length) {
			bytes.setFloat(i, set[i]);
		}

		return bytes;
	}

	public static inline function alloc(size:Int):Buffer {
		return new Buffer(Bytes.alloc(size));
	}
}
