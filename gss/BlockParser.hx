package gryffin.gss;

import gryffin.gss.Node;

class BlockParser {
	public var input:Array<String>;
	public var cursor:Int;

	public function new() {
		this.input = new Array();
		this.cursor = 0;
	}
	public function next(?d:Int = 1):Null<String> {
		return this.input[this.cursor + d];
	}
	public function previous(?d:Int = 1):Null<String> {
		return this.input[this.cursor - d];
	}
	public function advance(?d:Int = 1):Null<String> {
		this.cursor += d;
		return this.input[this.cursor];
	}
	public function lookahead(dis:Int):String {
		var d:Int = 0;
		var slice:String = "";
		while (d < dis) {
			slice += next(d);

			d++;
		}
		return slice;
	}
	public function distanceToNext(c:String):Int {
		var d:Int = 0;
		while (true) {
			if (next(d) == null) return -1;
			else if (next(d) == c) break;
			d++;
		}
		return d;
	}
	public function until(c:String):String {
		var d:Int = distanceToNext(c);
		var bit:String = lookahead(d);
		advance(d);
		return bit;
	}
	public function parseScope(opener:String, closer:String):String {
		var d:Int = 1;
		var level:Int = 0;
		var scope:String = "";
		do {
			if (next(d) == null) return null;
			else if (next(d) == opener) level++;
			else if (next(d) == closer) level--;
			
			if (level != 0) {
				scope += next(d);
			}

			d++;
		} while (level != 0);

		return scope;
	}
	public function parseStructure(keyword:String):Null<Node> {
		switch (keyword) {
			default:
				if (next() == ':') {
					advance();
					var key:String = keyword;

				}
		}
	}
	public function parseNext():Node {
		var c:Null<String> = this.input[this.cursor];
		if (c == null) throw '__eoi__';
		else {
			if (isWhiteSpace(c)) advance();
			else if (isAlphaNumeric(c)) {
				var ident:String = c;
				var d:Int = 1;
				while (next(d) != null && isAlphaNumeric(next(d))) {
					ident += next(d);
					d++;
				}
				advance(d + 1);
				var nd:Null<Node> = parseStructure(ident);
				return nd;
			}
		}
	}

	public function parse(inp:String):Array<Node> {
		var nodes:Array<Node> = new Array();
		this.input = inp.split('');
		this.cursor = 0;

		while (true) {
			try {
				var nd:Node = this.parseNext();
				nodes.push(nd);
			} catch (err:String) {
				if (err == '__eoi__') break;
				else {
					throw err;
				}
			}
		}
	}

	public static inline function isWhiteSpace(c:String):Bool {
		return Lambda.has([9, 10, 11, 12, 13, 32], c.charCodeAt(0));
	}
	public static inline function isSelectorString(c:String):Bool {
		var selStarters:Array<String> = ['#', '!', '.', ':', '[', '('];
		return Lambda.has(selStarters, c);
	}
	public static inline function isAlphaNumeric(c:String):Bool {
		return ~/[A-Za-z0-9_\-]/.match(c);
	}
}