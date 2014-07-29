package gryffin.display;

enum CanvasCommand {
	SLine(sx:Int, sy:Int, dx:Int, dy:Int, col:State);
	SRect(x:Int, y:Int, width:Int, height:Int, col:State);
	SRoundRect(x:Int, y:Int, width:Int, height:Int, radius:Int, col:State);
	SCircle(x:Int, y:Int, radius:Int, col:State);
	SText(text:String, x:Int, y:Int, width:Int, height:Int, state:State);
}
typedef State = {
	alpha:Float,
	lineSize:Float,
	lineColor:Dynamic,
	fillColor:Dynamic
};