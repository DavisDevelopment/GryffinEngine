package gryffin.selector;

class Parser {
	public var ops:Array < SelOp >;
	public var input:Array < Token >;
	
	public function new( tokens:Array < Token > ) {
		this.input = tokens;
		this.ops = new Array();
	}
	private function push( op:SelOp ):Void {
		this.ops.push(op);
	}
	private function last():SelOp {
		return this.ops.pop();
	}
	private function token():Token {
		return this.input.shift();
	}
	private function unexpected( tk:Token ) {
		throw "SelectorParseError: Unexpected token " + Std.string(tk) + ".";
	}
	public function parseToken( tk:Token ):SelOp {
		switch ( tk ) {
			case TAny: return Any;
			case THash:
				var next = token();
				switch ( next ) {
					case TIdent( id ):
						return IdTest(id);
					default:
						unexpected(tk);
						return Any;
				}
			case TNeg:
				var next = token();
				if ( next == null ) unexpected(tk);
				return Negate(parseToken(next));
				
			case TColon:
				var next = token();
				if ( next == null ) unexpected(tk);
				switch ( next ) {
					case TIdent( id ):
						return BoolPropTest(id);
						
					default:
						unexpected(tk);
						return Any;
				}
			case TDoubleDot:
				var next = token();
				if ( next == null ) unexpected(tk);
				switch ( next ) {
					case TIdent( id ):
						return LooseClassTest(id);
					default:
						unexpected(tk);
						return Any;
				}
			case TDot:
				var next = token();
				if ( next == null ) unexpected(tk);
				switch ( next ) {
					case TIdent(id):
						return ClassTest(id);
					default:
						unexpected(tk);
						return Any;
				}
			case TOr:
				var left = last();
				if ( left == null ) unexpected(tk);
				var next = token();
				if ( next == null ) unexpected(tk);
				var right = parseToken(next);
				return Or( left, right );
			case TAnd:
				var left = last();
				if ( left == null ) unexpected(tk);
				var next = token();
				if ( next == null ) unexpected(tk);
				var right = parseToken(next);
				return And( left, right );
			case TGroup( tokens ):
				return Group(new Parser(tokens).parse());
			default:
				unexpected(tk);
				return Any;
		}
	}
	public function parse():Array < SelOp > {
		while ( this.input.length > 0 ) {
			var tk:Token = token();
			if ( tk == null ) break;
			else {
				var op:SelOp = parseToken(tk);
				push(op);
			}
		}
		return this.ops;
	}
}