package gryffin.fquery.selectors;

enum Token {
	TGroup(tokens:Array<Token>);
	TIdent(id : String);
	
	TColon;
	TSlash;
	TDot;
	TStar;
}