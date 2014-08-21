package gryffin.fquery.selectors;

import gryffin.utils.Buffer;

import gryffin.fquery.selectors.Token;

class Lexer {
	public var cursor:Int;
	public var input:Buffer;
	public var tokens:Array<Token>;

	public function new():Void {
		this.cursor = 0;
		this.input = Buffer.fromString('');
		this.tokens = new Array();
	}
//= Buffer Navigation Methods
	public function currentByte():Null<Int> {
		return this.input[this.cursor];
	}
	public function nextByte(d:Int = 1):Null<Int> {
		return this.input[this.cursor + d];
	}
	public function current():Null<String> {
		var cb:Null<Int> = currentByte();
		return (cb != null ? String.fromCharCode(cb) : null);
	}
	public function next(d:Int = 1):Null<String> {
		var nb:Null<Int> = nextByte(d);
		return (nb != null ? String.fromCharCode(nb) : null);
	}
	public function advance(d:Int = 1):Null<String> {
		this.cursor += d;
		return current();
	}
	public function hasNext(c : String):Bool {
		var dis:Int = 1;

		while(next(dis) != null && nextByte(dis) != 0) {
			if (next(dis) == c) return true;
			dis++;
		}
		return false;
	}


//= Lexical Analysis Methods
	public function blit(set : Array<Null<Token>>):Void {
		for (tk in set) {
			if (tk != null) {
				tokens.push(tk);
			}
		}
	}
	public function lexNext():Null<Token> {
		var cb:Null<Int> = currentByte();
		var c:Null<String> = current();

		if (c == null || cb == 0) {
			throw '__EOI__';
		} else {

			if (isWhiteSpace(c)) {
				advance(1);
			}
			else if (isAlphaNumeric(c)) {
				var id:String = (c + '');
				var d:Int = 1;
				while (next(d) != null && (isAlphaNumeric(next(d)) || next(d) == '.')) {
					id += next(d);
					d++;
				}
				var lastDot:Int = id.lastIndexOf('.');
				if (lastDot != -1) {
					var _id:String = id;
					id = _id.substring(0, lastDot);
					var withDot:String = _id.substring(lastDot);
					d -= withDot.length;
				}
				var tk:Token = Token.TIdent(id);
				advance(d);
				return tk;
			} else {
				switch (cb) {
					case 42:
						advance();
						return Token.TStar;
					case 46:
						advance();
						return Token.TDot;

					case 47:
						advance();
						blit([Token.TSlash]);

						trace(hasNext('/'));
						var d:Int = 0;
						var sub:String = '';

						while (next(d) != null && next(d) != '/' && nextByte(d) != 0) {
							sub += next(d);
							d++;
						}
						sub += next(d);
						trace(sub);
						var group:Token = Token.TGroup(staticLex(sub));
						advance(d);
						return group;

					case 58:
						advance();
						return Token.TColon;
				}
			}

		}
		return null;
	}

	public function lex(sel : String):Array<Token> {
		this.input = Buffer.fromString(sel);
		this.tokens = new Array();
		this.cursor = 0;

		while (true) {
			try {
				var tk:Null<Token> = lexNext();
				if (tk != null) {
					tokens.push(tk);
				}
			} catch (err : String) {
				if (err == '__EOI__') {
					break;
				} else {
					throw err;
				}
			}
		}

		return tokens;
	}

//= Utility Methods
	private static inline function isWhiteSpace(c:String):Bool {
		return Lambda.has([9, 10, 11, 12, 13, 32], c.charCodeAt(0));
	}
	private static inline function isAlphaNumeric(c:String):Bool {
		return ~/[A-Za-z0-9_\-]/.match(c);
	}

	public static inline function staticLex(str : String):Array<Token> {
		return (new Lexer().lex(str));
	}
}