package gryffin.selector;

class Compiler {
	public var ops:Array < SelOp >;
	public var testStack:Array < Entity -> Bool >;
	
	public function new( opList:Array < SelOp > ) {
		this.ops = opList;
		this.testStack = new Array();
	}
	public function next():SelOp {
		return this.ops.shift();
	}
	public function compileOp( op:SelOp ):Entity -> Bool {
		switch ( op ) {
			case IdTest( id ):
				return function ( ent ) {
					return (ent.id == id);
				};
			case BoolPropTest( id ):
				return function( ent ) {
					if ( Utils.hasField( ent, id ) ) {
						var prop = Reflect.getProperty(ent, id);
						if (Types.basictype(prop) == "Bool") {
							return cast(prop, Bool);
						} else {
							return true;
						}
					} else {
						return false;
					}
				};
			case ClassTest( id ):
				return function( ent ) return Types.isInstanceOf( ent, id );
			case LooseClassTest( id ):
				return function( ent ) return Types.looseInstanceOf( ent, id );
			case Negate( op ):
				var selFunc = compileOp(op);
				return function ( ent ) {
					return !selFunc(ent);
				};
			case Or( lop, rop ):
				var left = compileOp(lop);
				var right = compileOp(rop);
				return function( ent ) {
					return (left(ent)||right(ent));
				};
			case And( lop, rop ):
				var left = compileOp(lop);
				var right = compileOp(rop);
				return function( ent ) {
					return (left(ent) && right(ent));
				};
			case Any:
				return function ( ent ) {
					return true;
				};
			case Group ( ops ):
				var comp = new Compiler(ops);
				return comp.compile();
		}
	}
	public function compile(): Entity -> Bool {
		var conditionStack:Array < Entity -> Bool > = new Array();
		var op = next();
		
		while ( op != null ) {
			var test = compileOp(op);
			conditionStack.push(test);
			op = next();
		}
		
		return function( ent:Entity ):Bool {
			for ( f in conditionStack ) if (!f(ent)) return false;
			return true;
		};
	}
}