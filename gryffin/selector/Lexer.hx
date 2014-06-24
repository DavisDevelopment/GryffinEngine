package gryffin.selector;

class Lexer {
	public var input:Array < String >;
	public var tokens:Array < Token >;
	public function new(sel:String) {
		this.input = sel.split('');
		this.tokens = [];
	}
	private function isAlphaNumeric( c:String ) {
		return ~/[A-Za-z0-9_]/.match(c);
	}
	private function advance():String {
		return this.input.shift();
	}
	private function next():String {
		return this.input[0];
	}
	private function push( tk : Token ):Void {
		this.tokens.push(tk);
	}
	public function lex():Array < Token > {
		var c:String = "";
		while( true ) {
			c = advance();
			if ( c == null ) break;
			else if (isAlphaNumeric(c)) {
				var ident:String = c;
				while (next() != null && isAlphaNumeric(next())) {
					c = advance();
					ident += c;
				}
				push(TIdent(ident));
			}
			else if (c == "(") {
				var content:String = "";
				var groupers = 1;
				while ( groupers > 0 ) {
					if ( next() == ")" ) --groupers;
					else if ( next() == "(" ) ++groupers;
					else {
						c = advance();
						if ( groupers > 0 ) content += c;
					}
				}
				advance();
				var tokens = new Lexer( content ).lex();
				push(TGroup(tokens));
			}
			else if ( c == "#" ) {
				push(THash);
			}
			else if ( next() != null && c == "." && next() == "." ) {
				push(TDoubleDot);
				advance();
			}
			else if ( c == "." ) {
				push(TDot);
			}
			else if ( c == "!" ) push(TNeg);
			else if ( c == "&" ) push(TAnd);
			else if ( c == "|" ) push(TOr);
			else if ( c == ":" ) push(TColon);
			else if ( c == "*" ) push(TAny);
		}
		return this.tokens;
	}
}