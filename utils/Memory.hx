package gryffin.utils;

class Memory {
	private static var lastID:Int = 0;
	
	public static function uniqueID():Int {
		lastID++;
		return lastID;
	}
}