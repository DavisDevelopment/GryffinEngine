package gryffin.fquery;

import gryffin.fquery.selectors.Lexer;
import gryffin.fquery.selectors.Parser;
import gryffin.fquery.selectors.Compiler;
import gryffin.fquery.selectors.SelectionContext;

class FileSelectors {
	public static function compile(sel : String) {
		var ctx:SelectionContext = new SelectionContext(sel);
		ctx.update();
		return ctx.matches;
	}
}