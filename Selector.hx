package gryffin;


import gryffin.ore.Lexer;
import gryffin.ore.Parser;
import gryffin.ore.Compiler;

class Selector {
	private static function print( x:Dynamic ):Void {
		#if debug
			trace( x );
		#end
	}
	public static function compile( selector:String ):Entity -> Bool {
		var time_compilation:Bool = false;
		var start:Float = (Date.now().getTime());
		var func:Entity -> Bool;
		if (func_cache.exists(selector) && use_cache) {
			func = func_cache.get(selector);
		} else {
			var lexer = new Lexer(selector);
			var tokens = lexer.lex();
			var parser = new Parser(tokens);
			var sel = parser.parse();
			var compiler = new Compiler(sel);
			func = compiler.compile();
			func_cache.set(selector, func);
		}
		var end:Float = (Date.now().getTime());
		var took:Float = (end - start);
		if (time_compilation) {
			trace('Parsed and Compiled "$selector" in $took milliseconds');
		}
		return func;
	}

	private static function __init__():Void {
		func_cache = new Map();
	}
	private static var func_cache:Map<String, Entity -> Bool>;
	private static var use_cache:Bool = true;
}