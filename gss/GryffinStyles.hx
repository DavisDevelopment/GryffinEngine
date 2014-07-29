package gryffin.gss;

import gryffin.gss.Parser;
import gryffin.gss.Compiler;

class GryffinStyles {
	public static function compile(code:String) {
		var parser:Parser = new Parser();
		var compiler:Compiler = new Compiler();
		var ast = parser.parse(code);
		var runner = compiler.compile(ast);
		return runner;
	}
}