package gryffin;

import gryffin.selector.Lexer;
import gryffin.selector.Parser;
import gryffin.selector.Compiler;

class Selector {
	private static function print( x:Dynamic ):Void {
		#if debug
			trace( x );
		#end
	}
	private static function isWhiteSpace( x:String ):Bool {
		return ~/\s/.match(x);
	}
	private static function isSymbol( x:String ):Bool {
		var symbols:Array <String> = [
			"#", ".", "!", "=", "(", ")", "[", "]", ":"
		];
		for ( sym in symbols ) {
			if ( x == sym ) return true;
		}
		return false;
	}
	private static function isDigit( x:String ):Bool {
		return ~/\d/.match(x);
	}
	private static function isLetter( x:String ):Bool {
		return ~/\w/.match(x);
	}
	private static function isAlpha( x:String ):Bool {
		return (isLetter(x) || isDigit(x));
	}
	private static function isKeyword( x:String ):Bool {
		var keywords:Array <String> = [
			"when", "and", "or"
		];
		for ( word in keywords ) {
			if ( word == x ) return true;
		}
		return false;
	}
	public static function lex( str:String ):Array<Array<String>> {
		var input:Array <String> = str.split('');
		var i:Int = 0, c:String = input[i];
		var tokens:Array<Array<String>> = [];
		function advance( dis:Int=1 ):Void {
			i += dis;
			c = input[i];
		}
		function next( dis:Int=1 ):String {
			return input[i+dis];
		}
		function addToken( type:String, value:String ):Void {
			tokens.push([type, value]);
		}
		
		while ( i < input.length ) {
			c = input[i];
			
			if (isWhiteSpace(c)) advance();
			//Symbols
			else if (isSymbol(c)) {
				addToken("symbol", c);
				advance();
			}
			//Numbers
			else if (isDigit(c)) {
				var v:String = c, d:Int = 1;
				while ( next(d) != null && (isDigit(next(d)) || ~/\./.match(next(d))) ) {
					v += next(d);
					d++;
				}
				addToken("number", v);
				advance(d+1);
			}
			//Identifiers and Keywords
			else if ( isLetter(c) ) {
				var v:String = c, d:Int = 1;
				while ( next(d) != null && isAlpha(next(d)) ) {
					v += next(d);
					d++;
				}
				//Keywords
				if (isKeyword(v)) addToken("keyword", v);
				else addToken("ident", v);
				advance(d);
			}
			else if ( c == "*" ) {
				addToken("ident", "any");
				advance();
			}
			else {
				throw 'SelectorSyntaxError: Unexpected $c.';
			}
			
		}
		
		return tokens;
	}
	public static function parse( input:Array<Array<String>> ):Entity -> Bool {
		var conditionStack:Array<Entity->Bool> = [];
		var i:Int = 0, c:Array<String> = input[i];
		function addFunc( f:Entity->Bool ):Void {
			conditionStack.push( f );
		}
		function advance( dis:Int=1 ):Void {
			i += dis;
			c = input[i];
		}
		function next( dis:Int=1 ):Array<String> {
			return input[i + dis];
		}
		
		while ( i < input.length ) {
			c = input[i];
			
			//Class Name Selection
			if ( c[1] == "#" && next()[0] == "ident" ) {
				var className:String = next()[1];
				addFunc(function( g:Entity ):Bool {
					return (Types.basictype(g) == className);
				});
				advance(2);
			}
			else if ( c[1] == "any" ) {
				addFunc(function(g:Entity):Bool {
					return true;
				});
				advance(1);
			}
			//Negation
			else if ( c[1] == "!" && next()[1] == "(" ) {
				var group:Array<Array<String>> = [];
				var pars:Int = 1, d:Int = 2;
				while ( pars > 0 ) {
					if ( next(d)[1] == "(" ) pars++;
					else if ( next(d)[1] == ")" ) pars--;
					if (!(pars == 0 || next(d)[1] == ")")) {
						group.push(next(d));
					}
					d++;
				}
				advance(d);
				var f:Entity -> Bool = parse(group);
				addFunc(function( g:Entity ):Bool {
					return !f(g);
				});
			}
			//Boolean property Testing
			else if ( c[1] == ":" && next()[0] == "ident" ) {
				var propName:String = next()[1];
				addFunc(function( g:Entity ):Bool {
					if ( Utils.hasField( g, propName ) ) {
						var prop = Reflect.getProperty(g, propName);
						if (Types.basictype(prop) == "Bool") {
							return cast(prop, Bool);
						} else {
							return true;
						}
					} else {
						return false;
					}
				});
				advance( 2 );
			}
			else {
				throw 'SelectorError:  Unexpected Token $c';
			}
		}
		return function( g:Entity ):Bool {
			for ( f in conditionStack ) {
				if (!f(g)) return false;
			}
			return true;
		}
	}
	public static function compile( selector:String ):Entity -> Bool {
		var lexer = new Lexer(selector);
		var tokens = lexer.lex();
		var parser = new Parser(tokens);
		var sel = parser.parse();
		var compiler = new Compiler(sel);
		var func = compiler.compile();
		return func;
	}
}