package gryffin.display;

enum SurfaceCommand {
	SLine(sx:Int, sy:Int, dx:Int, dy:Int, col:Dynamic);
	SRect(x:Int, y:Int, width:Int, height:Int, col:Dynamic);
	SRoundRect(x:Int, y:Int, width:Int, height:Int, radius:Int, col:Dynamic);
	SCircle(x:Int, y:Int, radius:Int, col:Dynamic);
	SText(text:String, x:Int, y:Int, width:Int, height:Int, col:Dynamic);
}