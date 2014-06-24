package gryffin.display;

import flash.display.BitmapData;

enum DrawOp {
	DrawRect( x:Int, y:Int, width:Int, height:Int, col:Dynamic );
	DrawCircle( x:Int, y:Int, radius:Int, col:Dynamic );
	DrawLine( sx:Int, sy:Int, ex:Int, ey:Int, col:Dynamic );
	DrawImage( img:Dynamic, x:Int, y:Int, width:Int, height:Int );
	DrawImageFragment( img:BitmapData, sx:Int, sy:Int, sw:Int, sh:Int, dx:Int, dy:Int, dw:Int, dh:Int );
}

class ImageFrame {
	public var width:Int;
	public var height:Int;
	public var ops:Array<DrawOp>;
	
	public function new( width:Int, height:Int ) {
		this.width = width;
		this.height = height;
		this.ops = new Array();
	}
	
	public function render( surface:Surface, destx:Int, desty:Int, dw:Int, dh:Int ):Void {
		for ( op in this.ops ) {
			switch ( op ) {
				case DrawRect( x, y, w, h, col ):
					surface.drawRect( destx+x, desty+y, w, h, col );
					
				case DrawCircle( x, y, radius, col ):
					surface.drawCircle( destx+x, desty+y, radius, col );
				
				case DrawLine( sx, sy, ex, ey, col ):
					surface.drawLine( destx+sx, desty+sy, destx+ex, desty+ey, col );
				
				case DrawImage( img, x, y, w, h ):
					surface.drawImage( img, destx+x, desty+y, w, h );
					
				case DrawImageFragment( img, sx, sy, sw, sh, dx, dy, dw, dh ):
					surface.drawImageFragment( img, sx, sy, sw, sh, destx+dx, desty+dy, dw, dh );
			}
		}
	}
	
/* --- Drawing Methods --- */
	//Clear the op-list
	public function clear():Void {
		this.ops = new Array();
	}
	//Draw Rectangle
	public function drawRect( x:Int, y:Int, width:Int, height:Int, col:Dynamic ):Void {
		this.ops.push(DrawRect(x, y, width, height, col));
	}
	//Draw Circle
	public function drawCircle( x:Int, y:Int, radius:Int, col:Dynamic ):Void {
		this.ops.push(DrawCircle(x, y, radius, col));
	}
	//Draw Line
	public function drawLine( sx:Int, sy:Int, ex:Int, ey:Int, col:Dynamic ):Void {
		this.ops.push(DrawLine(sx, sy, ex, ey, col));
	}
	//Draw Image
	public function drawImage( img:Dynamic, x:Int, y:Int, width:Int, height:Int ):Void {
		this.ops.push(DrawImage(img, x, y, width, height));
	}
	//Draw Piece of Image
	public function drawImageFragment( img:BitmapData, sx:Int, sy:Int, sw:Int, sh:Int, dx:Int, dy:Int, dw:Int, dh:Int ):Void {
		this.ops.push(DrawImageFragment( img, sx, sy, sw, sh, dx, dy, dw, dh ));
	}
}