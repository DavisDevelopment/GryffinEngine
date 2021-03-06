package gryffin.geom;

enum PathComponent {
	CLine(sx:Int, sy:Int, dx:Int, dy:Int);
	CRect(x:Int, y:Int, width:Int, height:Int);
	CPixel(x:Int, y:Int);
	CEllipse(x:Int, y:Int, rx:Int, ry:Int);
}