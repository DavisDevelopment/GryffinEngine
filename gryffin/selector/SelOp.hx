package gryffin.selector;

enum SelOp {
	IdTest( id:String );
	BoolPropTest( id:String );
	ClassTest( id:String );
	LooseClassTest( id:String );
	Negate( op:SelOp );
	Or( lop:SelOp, rop:SelOp );
	And( lop:SelOp, rop:SelOp );
	Group( content:Array < SelOp > );
	Any;
}