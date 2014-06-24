package gryffin.display;

import flash.display.BitmapData;

class SpriteSheetAnimation implements Animation {
	public var frames:Array < Image >;
	public var curFrame:Int;
	public var source:BitmapData;
	public var width:Int;
	public var height:Int;
	public var x:Int;
	public var y:Int;
	private var playDirection:Int;
	
	public function new( pic:BitmapData, frameDimensions:Array <Int>, ?orientation:Int=0 ) {
		this.source = pic;
		this.frames = new Array();
		this.curFrame = 0;
		this.width = frameDimensions[0];
		this.height = frameDimensions[1];
		this.x = 0;
		this.y = 0;
		this.playDirection = 0;
		
		this.initialize();
	}
	public function initialize():Void {
		var numFrames:Int = Math.floor( this.source.width/this.width );
		for ( i in 0...numFrames ) {
			var pic:Image = new Image( this.width, this.height );
			this.frames.push( pic );
			var frame = pic.addFrame();
			var x = i*this.width;
			frame.drawImageFragment( this.source, x, 0, this.width, this.height, this.x, this.y, this.width, this.height );
		}
	}
	public function reverse():Void {
		this.playDirection = (this.playDirection == 1) ? 0 : 1;
	}
	public function setPosition( x:Int, y:Int ):Void {
		this.x = x;
		this.y = y;
	}
	public function getFrame( pos:Int ):Null<Image> {
		return this.frames[pos];
	}
	public function drawTo( g:Surface, x:Int, y:Int, width:Int, height:Int ):Void {
		var frame = this.getFrame(this.curFrame);
		frame.drawTo( g, x, y, width, height );
	}
	public function nextFrame():Void {
		if ( this.playDirection == 0 ) { //Forward
			if ( this.curFrame < this.frames.length-2 ) {
				this.curFrame++;
			} else {
				this.reverse();
			}
		} else { //Backward
			if ( this.curFrame >= 1 ) {
				this.curFrame--;
			} else {
				this.reverse();
			}
		}
	}
}