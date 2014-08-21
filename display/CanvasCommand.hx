package gryffin.display;

import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.filters.BitmapFilter;

enum CanvasCommand {
	SLine(sx:Int, sy:Int, dx:Int, dy:Int, col:State);
	SRect(x:Int, y:Int, width:Int, height:Int, col:State);
	SRoundRect(x:Int, y:Int, width:Int, height:Int, radius:Int, col:State);
	SPolygon(vertices:Array<Array<Int>>, col:State);
	SCircle(x:Int, y:Int, radius:Float, col:State);
	SText(text:String, x:Int, y:Int, state:State);
	SImage(img:BitmapData, sx:Int, sy:Int, sw:Int, sh:Int, dx:Int, dy:Int, dw:Int, dh:Int, state:State);
}
enum PencilType {
	PSolidColor(color:Dynamic);
	PLinearGradient(focalPoint:Float, colorStops:Array<Array<Dynamic>>);
	PCanvasPattern(canv:Canvas);
}
typedef State = {
	geoMatrix:Matrix,
	alpha:Float,
	lineSize:Float,
	lineColor:PencilType,
	fillColor:PencilType,
	textSize:Float,
	textColor:Dynamic,
	textFont:String,
	textDecoration:String,
	filters:Array<BitmapFilter>
};