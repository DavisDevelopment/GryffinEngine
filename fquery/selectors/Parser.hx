package gryffin.fquery.selectors;

import gryffin.fquery.selectors.Token;
import gryffin.fquery.selectors.FileDesc;

class Parser {
	public var tokens:Array<Token>;
	public var descriptors:Array<FileDesc>;

	public function new():Void {
		this.tokens = new Array();
		this.descriptors = new Array();
	}
	public function advance():Null<Token> {
		return tokens.shift();
	}
	public function revert(tk:Token):Void {
		tokens.unshift(tk);
	}
	public function next(d:Int = 1):Null<Token> {
		return tokens[0 + d];
	}
	public function last(d:Int = 1):Null<FileDesc> {
		return this.descriptors[this.descriptors.length - (d + 1)];
	}
	public function undo():Null<FileDesc> {
		return this.descriptors.pop();
	}
	public function blit(set:Array<FileDesc>):Void {
		for (desc in set) {
			this.descriptors.push(desc);
		}
	}

	public function parseNext():Null<FileDesc> {
		var tk:Token = advance();
		switch (tk) {
			case Token.TStar:
				var nxt:Token = next();
				if (nxt != null) {
					switch (nxt) {
						case Token.TDot:
							descriptors.push(FileDesc.FAny);
							return parseNext();

						default:
							trace(nxt);
							return FileDesc.FAny;
					}
				} else {
					return FileDesc.FAny;
				}

			case Token.TIdent(id):
				return FileDesc.FName(id);

			case Token.TColon:
				var nxt:Token = advance();
				switch (nxt) {
					case Token.TIdent(id):
						return FileDesc.FGeneric(id);
					default:
						throw 'Unexpected ":"';
				}

			case Token.TDot:
				var left:FileDesc = undo();
				if (left == null) {
					left = FileDesc.FAny;
				}
				var tright:Token = advance();
				switch (tright) {
					case Token.TIdent(id):
						return FileDesc.FHasExtension(left, id);

					default:
						throw 'Invalid extension definition $tright';
				}

			case Token.TSlash:
				var left:FileDesc = undo();
				if (left == null) left = FileDesc.FAny;

				var right:Null<FileDesc> = parseNext();
				if (right == null) {
					right = FileDesc.FAny;
				}
				trace(right);

				return FileDesc.FChildOf(left, right);


			case Token.TGroup(tokens):
				var set:Array<FileDesc> = staticParse(tokens);
				return FileDesc.FBlock(set);


			default:
				trace('Cannot handle $tk');
				return null;
		}
	}

	public function parse(tree : Array<Token>):Array<FileDesc> {
		this.tokens = tree.copy();
		this.descriptors = new Array();

		while (this.tokens.length > 0) {
			var fd:Null<FileDesc> = parseNext();
			if (fd != null) {
				this.descriptors.push(fd);
			}
		}

		return descriptors;
	}

	public static inline function staticParse(tree : Array<Token>):Array<FileDesc> {
		return (new Parser().parse(tree));
	}
}