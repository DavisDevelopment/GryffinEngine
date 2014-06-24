package gryffin.display;

interface Animation {
	function drawTo( surface:Surface, x:Int, y:Int, width:Int, height:Int ):Void;
	function nextFrame():Void;
}