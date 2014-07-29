package gryffin.gss;

import gryffin.gss.Node;

class Parser {
	public var input:Array<String>;
	public var cursor:Int;
	public var nodes:Array<Node>;

	public function new() {
		this.input = new Array();
		this.cursor = 0;
		this.nodes = new Array();
	}
	public function node(nd:Node):Void {
		this.nodes.push(nd);
	}
	public function advance(d:Int = 1):Void {
		this.cursor += d;
	}
	public function next(d:Int = 1):String {
		return this.input[this.cursor + d];
	}
	public function last():Null<Node> {
		return this.nodes.pop();
	}
	public function getScope(opener:String, closer:String):String {
		var scope:String = "";
		var level:Int = 1;
		var d:Int = 1;
		while(next(d) != null && level > 0) {
			var n:String = next(d);
			if (n == closer) level--;
			else if (n == opener) level++;
			
			if (level != 0) {
				scope += n;
			}
			d++;
		}
		return scope;
	}
	public function parseValue( val:String ):Value {
		val = StringTools.trim(val);
		var chars:Array<String> = val.split('');
		switch (chars[0]) {
			case '(':
				return Value.VExpr(val);
			case '@':
				return Value.VPropRef(chars.slice(1).join(''));
			default:
				if (~/[A-Za-z_]+\(.*\)/.match(val)) {
					return Value.VExpr(val);
				}
				var v:Dynamic = haxe.Json.parse(val);
				var type:String = gryffin.Types.basictype(v);
				switch (type) {
					case "String": return Value.VString(cast(v, String));
					case "Int", "Float":
						return Value.VNumber(Std.parseFloat(v + ''));

					default:
						throw 'Invalid property value';
				}
		}
	}
	public function parseBlock( code:String ):Node {
		var strRules:Array<String> = code.split(';');
		var rules:Array<Node> = new Array();
		for (bit in strRules) {
			bit = StringTools.trim(bit);
			if (bit == "") continue;
			var name:String = (bit.substring(0, bit.indexOf(':')));
			name = StringTools.trim(name);
			name = gryffin.Utils.dashedToCamel(name);
			var value:String = (bit.substring(bit.indexOf(':') + 1));
			value = StringTools.trim(value);
			rules.push(Node.NRule(name, parseValue(value)));
		}
		return Node.NRuleSet(rules);
	}
	public function parseStructure(keyword:String):Null<Node> {
		switch (keyword) {

			default:
				throw 'Unexpected $keyword';
		}
		return null;
	}
	public function parseNext():Null<Node> {
		var c:Null<String> = this.input[this.cursor];
		if (c == null) throw '__eof__';
		else if (isWhiteSpace(c)) {
			advance(1);
			return null;
		}
		else if (isSelectorString(c)) {
			//- Grab bytes of selector until we reach a curly brace
			var selector:String = (c + '');
			var d:Int = 1;
			while (next(d) != null && next(d) != '{') {
				selector += next(d);

				d++;
			}
			advance(d + 1);
			selector = StringTools.trim(selector);
			var strBlock:String = getScope('{', '}');
			var block:Node = parseBlock(strBlock);
			advance(strBlock.length + 2);
			
			var sel:Node = Node.NSelectorString(selector);
			return Node.NBlock(selector, block);
		}
		else if (isAlphaNumeric(c)) {
			var ident:String = c;
			var d:Int = 1;
			while (next(d) != null && isAlphaNumeric(next(d))) {
				ident += next(d);
				d++;
			}
			trace(ident);
			advance(d + 1);
			return parseStructure(ident);
		}
		else {
			throw 'Unrecognized $c';
		}
		return null;
	}
	public function parse(gssCode:String):Array<Node> {
		trace(gssCode);
		this.input = gssCode.split('');
		this.cursor = 0;
		this.nodes = [];

		var nd:Null<Node> = null;

		while (true) {
			try {
				nd = parseNext();
				if (nd != null)
					this.node(nd);
			} catch (error : String) {
				if (error == '__eof__') break;
				else {
					throw error;
				}
			}
		}

		return this.nodes;
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