package gryffin;

import flash.Vector;
import flash.display.Graphics;
import flash.display.BitmapData;
import flash.display.GraphicsPathCommand;
import flash.display.GraphicsPathWinding;
import flash.geom.Rectangle;
import flash.geom.Point;

import gryffin.display.Image;
import gryffin.display.SpriteSheetAnimation;
import gryffin.display.ImageManipulation;
import gryffin.display.SurfaceCommand;
import gryffin.display.Canvas;
import gryffin.display.Sprite;
import gryffin.utils.MapTools;

import haxe.ds.StringMap;

typedef Pixel = {
	var x:Int;
	var y:Int;
	var color:Int;
};

class Surface {
	public var graphics:Graphics;
	public var stage:Stage;
	public var textDrawCache:Map<String, BitmapData>;

	private var attribute_stack:Array<Map<String, Dynamic>>;
	private var global_attributes:Map<String, Dynamic>;

	public function new( g:Graphics, stage:Stage ) {
		this.graphics = g;
		this.stage = stage;
		this.textDrawCache = new Map();

		this.global_attributes = new Map();

		this.attr('start-x', 0);
		this.attr('start-y', 0);
		this.attr('line-width', 2);
	}
	public function setGraphics( g:Graphics ) {
		this.graphics = g;
	}
	public function attr(key:String, ?value:Dynamic):Null<Dynamic> {
		if (value != null) { //- Setter
			this.global_attributes.set(key, value);
			return value;
		} else { //- Getter
			return this.global_attributes.get(key);
		}
	}
	public function save():Void {
		var state:Map<String, Dynamic> = MapTools.clone(this.global_attributes);
		this.attribute_stack.push(state);
	}
	public function restore():Void {
		this.global_attributes = this.attribute_stack.pop();
	}
	public function drawRect( x:Int, y:Int, width:Int, height:Int, col:Dynamic ):Void {
		var i:Float->Int = Math.ceil.bind(_);

		var color:Int = Colors.parse( col );
		this.graphics.beginFill( color );
		this.graphics.drawRect(i(attr('start-x') + x), i(attr('start-y') + y), width, height);
		this.graphics.endFill();
	}
	public function drawRoundRect(x:Int, y:Int, width:Int, height:Int, radius:Int, col:Dynamic):Void {
		var i:Float->Int = Math.ceil.bind(_);
		var color:Int = Colors.parse( col );
		this.graphics.beginFill( color );
		var rx:Int = i(attr('start-x') + x);
		var ry:Int = i(attr('start-y') + y);
		#if html5
			this.graphics.drawRect(rx, ry, width, height);
		#else
			this.graphics.drawRoundRect(rx, ry, width, height, radius, radius);
		#end
		this.graphics.endFill();	
	}
	public function drawPolygon(vertices:Array<Array<Int>>, col:Dynamic):Void {
		var i:Float->Int = Math.ceil.bind(_);
		var color:Int = Colors.parse(col);

	    graphics.beginFill(color);
	    var fp:Array<Int> = vertices.shift();
	    graphics.moveTo(i(attr('start-x') + fp[0]), i(attr('start-y') + fp[1]));
	    for(p in vertices) {
	        graphics.lineTo(i(attr('start-x') + p[0]), i(attr('start-y') + p[1]));
	    }
	    graphics.lineTo(i(attr('start-x') + fp[0]), i(attr('start-y') + fp[1]));
	    graphics.endFill();
	}
	public function drawCircle( x:Int, y:Int, radius:Int, col:Dynamic ):Void {
		var color:Int = Colors.parse( col );
		var i:Float->Int = Math.ceil.bind(_);
		this.graphics.beginFill( color );
		this.graphics.drawCircle(i(attr('start-x') + x), i(attr('start-y') + y), radius);
		this.graphics.endFill();
	}
	public function drawLine( sx:Int, sy:Int, ex:Int, ey:Int, col:Dynamic ):Void {
		var color:Int = Colors.parse( col );
		var i:Float->Int = Math.ceil.bind(_);
		this.graphics.beginFill( color );
		this.graphics.lineStyle(i(attr('line-width')), color);
		this.graphics.moveTo(i(attr('start-x') + sx)+0.0, i(attr('start-y') + sy)+0.0);
		this.graphics.lineTo(i(attr('start-x') + ex)+0.0, i(attr('start-y') + ey)+0.0);
		this.graphics.endFill();
	}
	public function drawCanvas(canvas:Canvas):Void {
		canvas.render(this);
	}
	public function execute(commandSet:Array<SurfaceCommand>):Void {
		for (command in commandSet) {
			switch (command) {
				case SLine(sx, sy, dx, dy, col):
					this.drawLine(sx, sy, dx, dy, col);

				case SRect(x, y, width, height, col):
					this.drawRect(x, y, width, height, col);

				case SRoundRect(x, y, width, height, radius, col):
					this.drawRoundRect(x, y, width, height, radius, col);

				case SCircle(x, y, radius, col):
					this.drawCircle(x, y, radius, col);

				default:
					null;
			}
		}
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
	public function measureText(txt:String, ?format:StringMap<Dynamic>):Array<Int> {
		if (format == null) 
			format = new StringMap();
		if (!format.exists('bold'))
			format.set('bold', false);
		if (!format.exists('italic'))
			format.set('italic', false);
		if (!format.exists('font'))
			format.set('font', 'Arial');
		if (!format.exists('size'))
			format.set('size', 12);
		if (!format.exists('align'))
			format.set('align', 'left');
		var field = new flash.text.TextField();
		field.text = txt;

		var form = new flash.text.TextFormat();
		form.bold = format.get('bold');
		form.italic = format.get('italic');
		form.size = format.get('size');
		form.font = format.get('font');
		form.align = (function() {
			var align:String = Std.string(format.get('align')).toLowerCase();
			switch(align) {
				case 'left': return flash.text.TextFormatAlign.LEFT;
				case 'right': return flash.text.TextFormatAlign.RIGHT;
				case 'center': return flash.text.TextFormatAlign.CENTER;
				default:
					return flash.text.TextFormatAlign.LEFT;
			}
		}());

		field.setTextFormat(form);

		return [Math.ceil(field.textWidth), Math.ceil(field.textHeight)];
	}
	public function captureText(txt:String, x:Int, y:Int, width:Int, height:Int, col:Dynamic, ?format:StringMap<Dynamic>):BitmapData {
		var i:Float->Int = Math.ceil.bind(_);
		if (format == null)
			format = new StringMap();
		if (!format.exists('bold'))
			format.set('bold', false);
		if (!format.exists('italic'))
			format.set('italic', false);
		if (!format.exists('font'))
			format.set('font', 'Arial');
		if (!format.exists('size'))
			format.set('size', 12);
		if (!format.exists('align'))
			format.set('align', 'left');
		var queryStr:String = '["$txt", $col, $width, $height, $format]';
		if (this.textDrawCache.exists(queryStr)) {
			var pic:BitmapData = this.textDrawCache.get(queryStr);
			return pic;
		} else {
			var color:Int = Colors.parse(col);
			var textRenderer = new flash.text.TextField();
			textRenderer.width = width;
			textRenderer.height = height;
			textRenderer.text = txt;
			textRenderer.textColor = color;
			var form = new flash.text.TextFormat();
			form.bold = format.get('bold');
			form.italic = format.get('italic');
			form.font = format.get('font');
			form.size = format.get('size');
			form.align = (function() {
				var align:String = Std.string(format.get('align')).toLowerCase();
				switch(align) {
					case 'left': return flash.text.TextFormatAlign.LEFT;
					case 'right': return flash.text.TextFormatAlign.RIGHT;
					case 'center': return flash.text.TextFormatAlign.CENTER;
					default:
						return flash.text.TextFormatAlign.LEFT;
				}
			}());
			textRenderer.setTextFormat(form);
			var lmarg:Null<Float> = textRenderer.getTextFormat().leftMargin;
			if (lmarg == null) lmarg = 2;
			var margin:Int = Math.ceil(lmarg);
			var bit:BitmapData = new BitmapData( width + (margin*2), height, true, 0x000000FF );
			bit.draw( textRenderer );
			var final:BitmapData = ImageManipulation.translate( bit, "#00FFFFFF", 0xFFFFFFFF );
			this.textDrawCache.set( queryStr, bit );
			return bit;
		}
	}
	public function drawText( txt:String, x:Int, y:Int, width:Int, height:Int, col:Dynamic, ?format:StringMap<Dynamic> ):Void {
		var bit:BitmapData = captureText(txt, x, y, width, height, col, format);
		this.drawImage(bit, x, y, width, height);
	}
	public function snapshot(x:Int, y:Int, width:Int, height:Int):Sprite {
		var sprite:Sprite = new Sprite('');
		var bm:BitmapData = new BitmapData(this.stage.boundX, this.stage.boundY, true);
		bm.draw(this.stage.shape);
		sprite.data = bm;
		var desiredPiece = sprite.getFragment(x, y, width, height);
		sprite.data = desiredPiece;
		
		return sprite;
	}
}