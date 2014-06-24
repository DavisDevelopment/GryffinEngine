package gryffin.selector;

enum Token {
	TIdent( id:String );
	TGroup( content:Array < Token > );
	TAny;
	THash;
	TDot;
	TNeg;
	TOr;
	TAnd;
	TDoubleDot;
	TColon;
}