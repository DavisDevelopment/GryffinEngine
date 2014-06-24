package gryffin.display;

import gryffin.Entity;
import gryffin.Colors;
import flash.display.BitmapData;

typedef Pixel = {
	var x:Int;
	var y:Int;
	var color:Dynamic;
}
typedef Frame = Array < Pixel >;

class Image extends Entity {
	public var animated:Bool;
	public var frames:Array<ImageFrame>;
	public var curFrame:Int;
	
	public function new( width:Int, height:Int ) {
		super();
		this.width = width;
		this.height = height;
		this.frames = new Array();
		this.curFrame = 0;
	}
	public function addFrame():ImageFrame {
		var frame:ImageFrame = new ImageFrame( this.width, this.height );
		this.frames.push( frame );
		return frame;
	}
	public function nextFrame():Void {
		if ( this.curFrame < this.frames.length-2 ) {
			this.curFrame++;
		} else {
			this.curFrame = 0;
		}
	}
	public function getFrame( pos:Int ):ImageFrame {
		return this.frames[pos];
	}
	public function drawTo( surface:Surface, x:Int, y:Int, width:Int, height:Int ):Void {
		var frame:ImageFrame = this.getFrame( this.curFrame );
		frame.render( surface, x, y, width, height );
	}
}