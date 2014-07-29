package gryffin.gss;

enum Node {
//= Structures
	NBlock( sel:String, rules:Node );
	NSelectorString( str:String );
	NRuleSet( set:Array<Node> );
	NRule( name:String, value:Value );

//= Atoms
}
enum Value {
	VString( str:String );
	VNumber( num:Float );
	VExpr( expr:String );
	VPropRef( prop:String );
}