package gryffin;
import flash.display.Graphics;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import gryffin.display.Image;
import gryffin.display.SpriteSheetAnimation;
import gryffin.display.ImageManipulation;

typedef Pixel = {
	var x:Int;
	var y:Int;
	var color:Int;
};

class Surface {
	public var graphics:Graphics;
	public var stage:Stage;
	public var textDrawCache:Map<String, BitmapData>;
	public function new( g:Graphics, stage:Stage ) {
		this.graphics = g;
		this.stage = stage;
		this.textDrawCache = new Map();
	}
	public function setGraphics( g:Graphics ) {
		this.graphics = g;
	}
	public function drawRect( x:Int, y:Int, width:Int, height:Int, col:Dynamic ):Void {
		var color:Int = Colors.parse( col );
		this.graphics.beginFill( color );
		this.graphics.drawRect( x, y, width, height );
		this.graphics.endFill();
	}
	public function drawCircle( x:Int, y:Int, radius:Int, col:Dynamic ):Void {
		var color:Int = Colors.parse( col );
		this.graphics.beginFill( color );
		this.graphics.drawCircle( x, y, radius );
		this.graphics.endFill();
	}
	public function drawLine( sx:Int, sy:Int, ex:Int, ey:Int, col:Dynamic ):Void {
		var color:Int = Colors.parse( col );
		this.graphics.beginFill( color );
		this.graphics.lineStyle( 2, color );
		this.graphics.moveTo( sx+0.0, sy+0.0 );
		this.graphics.lineTo( ex+0.0, ey+0.0 );
		this.graphics.endFill();
	}
	public function drawImage( image:Dynamic, x:Int, y:Int, w:Int, h:Int ):Void {
		var me = this;
		if(Types.typename(image) == "Image") {
			var pic:Image = cast(image, Image);
			pic.drawTo(this, x, y, w, h);
			pic.nextFrame();
		}
		else if (Types.typename(image) == "SpriteSheetAnimation") {
			var pic:SpriteSheetAnimation = cast(image, SpriteSheetAnimation);
			pic.drawTo( this, x, y, w, h );
			pic.nextFrame();
		}
		else if (Types.typename(image) == "Function") {
			image(this);
		} else {
			var pic:BitmapData = (function() {
				var type:String = Types.typename(image);
				switch ( type ) {
					case "String":
						if (this.stage.textures.exists(cast image))
						return this.stage.textures.get(cast image);
						else throw 'ReferenceError: Could not find specified image $image';
					
					case "BitmapData":
						return cast( image, BitmapData );
					
					default:
						throw 'TypeError: Cannot render $type objects with "drawImage"';
				}
			}());
			var transform = new flash.geom.Matrix();
			transform.translate(Math.abs(0.0-x), Math.abs(0.0-y));
			var sx:Float = pic.width / w;
			var sy:Float = pic.height / h;
			transform.scale( sx, sy );
			this.graphics.beginBitmapFill( pic, transform, false );
			this.graphics.drawRect( x, y, w, h );
			this.graphics.endFill();
		}
	}
	public function drawImageFragment( img:BitmapData, sx:Int, sy:Int, sw:Int, sh:Int, dx:Int, dy:Int, dw:Int, dh:Int ):Void {
		var renderer:BitmapData = new BitmapData( sw, sh );
		var clipper:Rectangle = new Rectangle( sx, sy, sw, sh );
		var dest:Point = new Point( 0, 0 );
		renderer.copyPixels( img, clipper, dest );
		this.drawImage( renderer, dx, dy, dw, dh );
	}
	public function drawText( txt:String, x:Int, y:Int, width:Int, height:Int, col:Dynamic ):Void {
		var queryStr:String = '["$txt", $col, $width, $height]';
		if (this.textDrawCache.exists(queryStr)) {
			var pic:BitmapData = this.textDrawCache.get(queryStr);
			this.drawImage( pic, x, y, width, height );
		} else {
			var color:Int = Colors.parse(col);
			var textRenderer = new flash.text.TextField();
			textRenderer.text = txt;
			textRenderer.textColor = color;
			var bit:BitmapData = new BitmapData( width, height );
			bit.draw( textRenderer );
			var final:BitmapData = ImageManipulation.translate( bit, "#00FFFFFF", 0xFFFFFFFF );
			this.textDrawCache.set( queryStr, final );
			this.drawImage(final, x, y, width, height);
		}
	}
}