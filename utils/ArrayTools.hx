package gryffin.utils;

class ArrayTools {
	public static function common<T>(lists:Array<Array<T>>):Array<T> {
		var result:Array<T> = new Array();

		for (list in lists) {
			for (item in list) {
				var isCommon:Bool = true;
				for (_list in lists) {
					if (!Lambda.has(_list, item)) {
						isCommon = false;
						break;
					}
				}
				if (!Lambda.has(result, item)) {
					result.push(item);
				}
			}
		}

		return result;
	}
}