package gryffin;

class Random {
	public static function randint( min:Int, max:Int ):Int {
		return Math.floor(Math.random()*(max-min+1)+min);
	}
	public static function randbool():Bool {
		var i:Int = randint(0, 1);
		return (i == 1);
	}
	public static function choice<T>( list:Array<T> ):T {
		return list[randint(0, list.length-1)];
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
}