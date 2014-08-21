package gryffin;

class Random {
	public var state:Int;

	public function new(?seed:Int):Void {
		state = seed != null ? seed : Math.floor(Math.random() * INT_MAX);
	}
	public inline function nextInt():Int {
		state = cast ((1103515245.0 * state + 12345) % INT_MAX);
		return state;
	}
	public inline function nextFloat():Float {
		return (nextInt() / INT_MAX);
	}
	public inline function randomint(min:Int, max:Int):Int {
		return Math.floor(nextFloat()*(max-min+1)+min);
	}
	public inline function randombool():Bool {
		return (randint(0, 1) == 1);
	}
	public inline function randomchoice<T>(list:Iterable<T>):T {
		var set:Array<T> = [for (x in list) x];
		return set[randint(0, set.length - 1)];
	}
	public inline function array_shuffle<T>( list:Array<T> ):Array<T> {
		var copy:Array < T > = list.copy();
		var result:Array < T > = new Array();
		var l:Int = copy.length;
		while ( result.length != l ) {
			var el:T = choice(copy);
			result.push(el);
			copy.remove(el);
		}
		return result;
	}

	public static inline function randint( min:Int, max:Int ):Int {
		var r:Random = new Random();
		return r.randomint(min, max);
	}
	public static inline function randbool():Bool {
		return new Random().randombool();
	}
	public static function choice<T>( list:Iterable<T> ):T {
		var set:Array<T> = [for (x in list) x];
		return set[randint(0, set.length-1)];
	}
	public static function shuffle<T>( list:Array<T> ):Array<T> {
		var copy:Array < T > = list.copy();
		var result:Array < T > = new Array();
		var l:Int = copy.length;
		while ( result.length != l ) {
			var el:T = choice(copy);
			result.push(el);
			copy.remove(el);
		}
		return result;
	}
	public static function chance( _percents:Array<String>, choices:Array<Dynamic>, total:Int=100 ):Dynamic {
		var percents:Array<Float> = [for (x in _percents) (Std.parseInt(x) / 100)];
		var choiceList:Array<Dynamic> = [];
		for (i in 0...percents.length) {
			var count:Int = Math.round(percents[i] * total);
			for (x in 0...count) choiceList.push(choices[i]);
		}
		//- for (x in 0...randint(1, 4)) choiceList = shuffle(choiceList);
		return choice(choiceList);
	}

	private static var INT_MAX:Int = 2147483647;
}