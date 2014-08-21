package gryffin;

import gryffin.utils.Memory;
import flash.media.Sound;
import motion.actuators.GenericActuator;
import motion.Actuate;

import haxe.io.Bytes;
import openfl.utils.ByteArray;

class Utils {
	public static function setInterval(delay:Float, action:Dynamic, ?params:Array<Dynamic>):Int {
		if (params == null) params = new Array();
		var id:Int = Memory.uniqueID();
		var tween:Dynamic;

		function queueNext() {
			if (Reflect.isFunction(action))
				Reflect.callMethod(null, action, params);
			tween = Actuate.timer(delay);
			tweens.set(id, tween);
			tween.onComplete(queueNext, null);
		}
		tween = Actuate.timer(delay);
		tweens.set(id, tween);
		tween.onComplete(queueNext, null);
		return id;
	}
	public static function bindFunction( o:Dynamic, f:Dynamic ):Array < Dynamic > -> Dynamic {
		return function ( args:Array <Dynamic> ):Dynamic {
			return Reflect.callMethod( o, f, args );
		};
	}
	public static function invokeOnce( f:Dynamic ):Dynamic {
		if (Reflect.isFunction(f)) {
			var invoked:Bool = false;
			return Reflect.makeVarArgs(function(args:Array<Dynamic>):Dynamic {
				if (!invoked) {
					invoked = true;
					return Reflect.callMethod(null, f, args);
				} else {
					return null;
				}
			});
		} else {
			throw 'TypeError: Expected Function, got ${Types.basictype(f)}';
		}
	}
	/*
		returns a function that will only invoke if it has never received the given arguments before
	*/
	public static function picky( f:Dynamic, ?checker:Dynamic->Dynamic->Bool, ?repr:Dynamic->Dynamic ):Dynamic {
		var pastArgs:Array<Array<Dynamic>> = [];
		var checkEquality:Dynamic = function(x:Array<Dynamic>, y:Array<Dynamic>):Bool {
			if (x.length != y.length) return false;
			for (i in 0...x.length) {
				var val1:Dynamic = x[i];
				var val2:Dynamic = y[i];
				if (repr != null) {
					val1 = repr(val1);
					val2 = repr(val2);
				}
				if (!(checker != null ? checker(val1, val2) : val1 != val2)) return false;
			}
			return true;
		},
		isCached:Dynamic = function(args:Array<Dynamic>):Bool {
			if (pastArgs.indexOf(args) != -1) return true;
			if (pastArgs.length == 0) return false;
			for (set in pastArgs) {
				if (!checkEquality(args, set)) return false;
			}
			return true;
		};
		return Reflect.makeVarArgs(function(args:Array<Dynamic>):Dynamic {
			if (!isCached(args)) {
				trace((function() {
					var ids:Array<String> = [];
					for (set in pastArgs) {
						if (ids.indexOf(set[0].id) == -1) ids.push(cast(set[0].id, String));
					}
					return ids;
				}()));
				pastArgs.push(args);
				return Reflect.callMethod(null, f, args);
			} else {
				return null;
			}
		});
	}
	public static function memoize(func:Dynamic, ?owner:Dynamic):Dynamic {
		haxe.Serializer.USE_CACHE = true;
		haxe.Serializer.USE_ENUM_INDEX = true;

		var cache:Map<String, Dynamic> = new Map();
		return Reflect.makeVarArgs(function(args:Array<Dynamic>):Dynamic {
			var key:String = haxe.Serializer.run(args);
			if (cache.exists(key)) {
				return cache.get(key);
			} else {
				var retval = Reflect.callMethod(owner, func, args);
				cache.set(key, retval);
				return retval;
			}
		});
	}
	public static function DynamicToMap ( dyn:Dynamic ):Map<String, { v : Dynamic }> {
		var keys:Array<String> = Reflect.fields(dyn);
		var result:Map<String, { v : Dynamic }> = new Map();
		for ( key in keys ) {
			result.set(key, Reflect.getProperty(dyn, key));
		}
		return result;
	}
	public static function ByteArrayToBytes(bits:ByteArray):Bytes {
		var bytes:Bytes = Bytes.alloc(bits.length);
		bits.position = 0;

		while (bits.bytesAvailable > 0) {
			var pos:Int = bits.position;
			bytes.set(pos, bits.readByte());
		}

		return bytes;
	}
	public static function getClassName( o:Entity ):String {
		var klass = Type.getClass( o );
		var name = Type.getClassName( klass );
		return name;
	}
	public static function getTextures( list:Map<String, String> ):NativeMap< String, flash.display.BitmapData > {
		var result:NativeMap<String, flash.display.BitmapData> = new NativeMap();
		for ( key in list.keys() ) {
			result.set(key, openfl.Assets.getBitmapData(list.get(key)));
		}
		return result;
	}
	public static function getSounds( list:Map<String, String> ):NativeMap < String, Sound > {
		var result:NativeMap<String, Sound> = new NativeMap();
		for ( key in list.keys() ) {
			result.set(key, openfl.Assets.getSound(list.get(key)));
		}
		return result;
	}
	public static function contains( list:Array < Dynamic >, item:Dynamic ):Bool {
		for ( x in list ) if ( x == item ) return true;
		return false;
	}
	public static function hasField( o:Dynamic, field:String ):Bool {
		return (Reflect.getProperty( o, field ) != null);
	}
	public static inline function degrees(rads:Float):Float {
		return (rads * 180 / Math.PI);
	}
	public static inline function radians(degs:Float):Float {
		return (degs * Math.PI / 180);
	}
	public static inline function distance( x1:Float, y1:Float, x2:Float, y2:Float ):Int {
		var dx:Int = Math.round(Math.abs(x2 - x1));
		var dy:Int = Math.round(Math.abs(y2 - y1));
		dx = dx*dx;
		dy = dy*dy;
		return Math.round(Math.sqrt(dx + dy));
	}
	public static inline function angleBetween(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return (Math.atan2(x2 - x1, y2 - y1) * 180 / Math.PI);
	}
	public static function isPointInRect( point:{x:Int, y:Int}, rect:{x:Int, y:Int, width:Int, height:Int} ):Bool {
		var inX:Bool = (point.x > rect.x && point.x < rect.x + rect.width);
		var inY:Bool = (point.y > rect.y && point.y < rect.y + rect.height);
		return ( inX && inY );
	}
	public static inline function range(min:Int, max:Int):Array<Int> {
		return [for (i in 0...(max+1)) i];
	}
	public static function largest( list:Array < Float > ):Null<Float> {
		var largest:Null<Float> = null;
		for ( x in list ) {
			if ( largest == null || largest < x ) largest = x;
		}
		return largest;
	}
	public static function smallest( list:Array < Float > ):Null<Float> {
		var smallest:Null<Float> = null;
		for ( x in list ) {
			if ( smallest == null || smallest > x ) smallest = x;
		}
		return smallest;
	}
	public static function most_frequent(list:Iterable<Dynamic>):Dynamic {
		var arr:Array<Dynamic> = Lambda.array(list);
		var counts:Map<Int, Int> = new Map();
		for (index in 0...arr.length-1) {
			var item:Dynamic = arr[index];
			var count:Int = (counts.exists(index)?counts.get(index):0);
			counts.set(index, (count + 1));
		}
		var most:Null<Int> = null;
		for (item in list) {
			var index:Int = Lambda.indexOf(arr, item);
			if (most == null || counts.get(index) > counts.get(most)) most = index;
		}

		return (most != null ? arr[most] : Lambda.array(list)[0]);
	}
	public static function arraySmallest<T>(set:Array<T>, predicate:T->Float):Null<T> {
		var smallestItem:Null<T> = null;
		var smallestRating:Null<Float> = null;
		for (item in set) {
			var rating:Float = predicate(item);
			if (smallestItem == null || smallestRating > rating) {
				smallestItem = item;
				smallestRating = rating;
			}
		}
		return smallestItem;
	}
	public static function arrayLargest<T>(set:Array<T>, predicate:T->Float):Null<T> {
		var largestItem:Null<T> = null;
		var largestRating:Null<Float> = null;
		for (item in set) {
			var rating:Float = predicate(item);
			if (largestItem == null || largestRating < rating) {
				largestItem = item;
				largestRating = rating;
			}
		}
		return largestItem;
	}
	public static function dashedToCamel(str:String):String {
		var result:String = str;
		var bits:Array<String> = str.split('-');
		if (bits.length == 1) return result;
		else {
			result = bits[0];
			for (piece in bits.slice(1)) {
				result += (piece.substring(0, 1).toUpperCase() + piece.substring(1));
			}
		}
		return result;
	}
	public static inline function uniqueItems<T>(set:Iterable<T>):Array<T> {
		var list:Array<T> = Lambda.array(set);
		var unique:Array<T> = new Array();
		for (item in list) {
			if (!Lambda.has(unique, item))
				unique.push(item);
		}
		return unique;
	}


	private static var tweens:Map<Int, Dynamic>;

	private static function __init__():Void {
		tweens = new Map();
	}
}