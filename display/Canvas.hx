package gryffin.display;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.Rectangle;
import flash.geom.Matrix;


import gryffin.Surface;
import gryffin.Types;
import gryffin.display.CanvasCommand;
import gryffin.display.Sprite;
import gryffin.display.ImageManipulation;
import gryffin.geom.Fragment;
import gryffin.Colors;
import gryffin.utils.MapTools;
import gryffin.utils.Memory;

class Canvas {
	private var updated:Bool;
	//- Geometric Properties
	public var x:Int;
	public var y:Int;
	public var width(default, set):Int;
	public var height(default, set):Int;
	public var rotation(default, set):Int;
	//- Internal Properties, used for carrying out "commands"
	public var bitmap:BitmapData;
	public var sprite:Sprite;
	public var commands:Array<Command>;
	private var _command_map:Map<Int, Command>;
	private var _command_data:Map<Int, State>;
	public var id:Int;
	public var state(get, set):State;
	public var queue:Array<State>;
	
	//- Aesthetic Properties, used to determine rendering appearance
	public var alpha:Float;

	public var lineSize:Float;
	public var lineColor:Dynamic;
	public var fillColor:PencilType;
	public var geoMatrix:Matrix;
	public var textSize:Float;
	public var textColor:Dynamic;
	public var textDecoration:String;
	public var textFont:String;
	public var filters:Array<BitmapFilter>;

	public function new(width:Int, height:Int) {
		this.updated = true;

		this.width = width;
		this.height = height;
		this.x = 0;
		this.y = 0;

		this.bitmap = new BitmapData(width, height, true, 0x000000);
		this.sprite = new Sprite('');
		this.sprite.data = this.bitmap;
		this.commands = new Array();
		this.queue = new Array();
		this.id = Memory.uniqueID();

		this._command_map = new Map();
		this._command_data = new Map();

		this.restoreState(this.defaultState());
	}
//= Internal Methods
	private function dummShape():Shape {
		var dummy:Shape = new Shape();
		//dummy.alpha = this.alpha;
		dummy.width = this.width;
		dummy.height = this.height;
		dummy.rotation = this.rotation;

		return dummy;
	}
	private function defaultState():State {
		return {
			'geoMatrix': new Matrix(),
			'alpha': 255,
			'lineSize': 3,
			'lineColor': "#000000",
			'fillColor': PencilType.PSolidColor('#000000'),
			'textSize': 12,
			'textColor': '#000000',
			'textFont': 'Arial',
			'textDecoration': '',
			'filters': new Array()
		};
	}
	private function restoreState(state:State):Void {
		var props:Map<String, Dynamic> = MapTools.fromDynamic(state);
		for (key in props.keys()) {
			Reflect.setProperty(this, key, props.get(key));
		}
	}
	private function currentState():State {
		var dummy:State = defaultState();
		var props:Map<String, Dynamic> = MapTools.fromDynamic(dummy);
		for (key in props.keys()) {
			var val:Dynamic = Reflect.getProperty(this, key);
			Reflect.setProperty(dummy, key, val);
		}
		return dummy;
	}
	private function get_state():State {
		return this.currentState();
	}
	private function set_state(st:State):State {
		this.restoreState(st);
		return st;
	}
	public function setFillColor(st:Dynamic):PencilType {
		var type:String = Types.basictype(st);
		var ptype:Null<PencilType> = null;
		switch (type) {
			case "String", "Int":
				ptype = PencilType.PSolidColor(st);

			case "Canvas":
				ptype = PencilType.PCanvasPattern(cast(st, Canvas));

			case "PencilType":
				ptype = cast(st, PencilType);
		}
		this.fillColor = ptype;
		return ptype;
	}
	public function save():Void {
		this.queue.push(this.state);
	}
	public function restore():Void {
		var st:Null<State> = this.queue.pop();
		if (st == null) return;
		this.restoreState(st);
	}
	public function transform(x:Float, y:Float):Void {
		this.state.geoMatrix.translate(x, y);
	}
	public function rotate(byX:Float, byY:Float, degrees:Int):Void {
		this.state.geoMatrix.rotate(Utils.radians(degrees));
	}
	public function scale(x:Float, y:Float):Void {
		this.state.geoMatrix.scale(x, y);
	}
	public function invert():Void {
		this.geoMatrix.invert();
	}
	public function shadow(?distance:Float, ?angle:Float, ?color:UInt, ?alpha:Float, ?blurX:Float, ?blurY:Float, ?strength:Float, ?quality:Int, ?inner:Bool, ?knockout:Bool, ?hideObject:Bool):Void {
		var filter:BitmapFilter = new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
		this.filters.push(filter);
	}
	public function blur(?blurX:Float, ?blurY:Float, ?quality:Int):Void {
		var filter:BitmapFilter = new BlurFilter(blurX, blurY, quality);
		this.filters.push(filter);
	}
	public function colorTransform(matrix:Array<Float>):Void {
		var filter:BitmapFilter = new ColorMatrixFilter(matrix);
		this.filters.push(filter);
	}
	private function set_width(w:Int):Int {
		this.width = w;
		this.updated = true;
		return w;
	}
	private function set_height(h:Int):Int {
		this.height = h;
		this.updated = true;
		return h;
	}
	private function set_rotation(r:Int):Int {
		this.updated = true;
		this.rotation = r;
		return r;
	}
	private function recordCommand(com:Command):Void {
		var id:Int = Memory.uniqueID();
		this._command_map.set(id, com);
		this._command_data.set(id, this.state);
	}
	private function getCommandState(id:Int):State {
		return this._command_data.get(id);
	}
	private function command(name:String, args:Array<Dynamic>):Void {
		var en:Command = Type.createEnum(Command, name, args);
		recordCommand(en);
		this.commands.push(en);
		this.updated = true;
	}
//= Public Drawing Methods
	public function clear():Void {
		this.commands = new Array();
	}
	public function line(sx:Int, sy:Int, dx:Int, dy:Int):Void {
		var args:Array<Dynamic> = [sx, sy, dx, dy, this.state];
		command('SLine', args);
	}
	public function rect(x:Int, y:Int, width:Int, height:Int, ?radius:Int):Void {
		var round:Bool = (radius != null);
		var args:Array<Dynamic> = [x, y, width, height];
		if (round) args.push(radius);
		args.push(this.state);
		command((round ? 'SRoundRect' : 'SRect'), args);
	}
	public function text(txt:String, x:Int, y:Int):Void {
		var args:Array<Dynamic> = [txt, x, y, this.state];
		command('SText', args);
	}
	public function circle(x:Int, y:Int, radius:Int):Void {
		var args:Array<Dynamic> = [x, y, radius, this.state];
		command('SCircle', args);
	}
	public function image(img:BitmapData, sx:Int, sy:Int, sw:Int, sh:Int, dx:Int, dy:Int, dw:Int, dh:Int):Void {
		var args:Array<Dynamic> = [img, sx, sy, sw, sh, dx, dy, dw, dh, this.state];
		command('SImage', args);
	}

//= Private Drawing Methods
	public function startAppropriateFill(g:Graphics, s:Surface):Void {
		switch (this.fillColor) {
			case PencilType.PSolidColor(color):
				g.beginFill(Colors.parse(color), this.alpha);

			case PencilType.PLinearGradient(fcp, colorStops):
			#if !html5
				var colors:Array<Float> = [];
				var alphas:Array<Float> = [];
				var ratios:Array<Float> = [];
				for (pair in colorStops) {
					var ratio:Float = Std.parseFloat(pair[0] + '');
					var color = Colors.parse(pair[1] + '');
					var alpha:Null<Float> = (pair[2] != null?Std.parseFloat(pair[2] + ''):null);
					ratios.push(Math.round(ratio * 255));
					alphas.push(alpha != null?alpha:1);
					colors.push(color);
				}
				var icolors:Array<UInt> = [for (c in colors) cast(Std.int(c), UInt)];
				g.beginGradientFill(flash.display.GradientType.LINEAR, icolors, alphas, ratios, null, null, null, fcp);
			#else
				var color:Int = 0;
				color = Colors.parse(colorStops[colorStops.length - 1][1] + '');
				var alpha:Float = Std.parseFloat(colorStops[colorStops.length - 1][2] + '');
				g.beginFill(color, alpha);
			#end

			case PencilType.PCanvasPattern(canvas):
				canvas.x = -1000;
				canvas.y = -2000;
				s.drawCanvas(canvas);
				var bitmap:BitmapData = canvas.bitmap;
				g.beginBitmapFill(bitmap, this.state.geoMatrix, true);
			default:
				trace(this.fillColor);
		}
	}
	public function drawCommand(com:Command, s:Surface):Void {
		var c:BitmapData = this.bitmap;
		switch (com) {
			case SLine(sx, sy, dx, dy, state):
				save();
				restoreState(state);
				var dum:Shape = dummShape();
				var g:Graphics = dum.graphics;
				g.lineStyle(this.lineSize, Colors.parse(this.lineColor), this.alpha);
				g.beginFill(Colors.parse(this.fillColor), this.alpha);
				g.moveTo(sx, sy);
				g.lineTo(dx, dy);
				g.endFill();

				this.bitmap.draw(dum, this.state.geoMatrix);
				restore();

			case SRect(x, y, width, height, state):
				save();
				restoreState(state);
				var dum:Shape = dummShape();
				var g:Graphics = dum.graphics;
				//g.lineStyle(this.lineSize, Colors.parse(this.lineColor), this.alpha);
				startAppropriateFill(g, s);
				g.drawRect(x, y, width, height);
				g.endFill();

				this.bitmap.draw(dum, this.state.geoMatrix);
				restore();

			case SRoundRect(x, y, width, height, radius, state):
				save();
				restoreState(state);
				var dum:Shape = dummShape();
				var g:Graphics = dum.graphics;
				startAppropriateFill(g, s);
				g.drawRect(x, y, width, height);
				g.endFill();
				restore();

			case SCircle(x, y, radius, state):
				save();
				restoreState(state);
				var dum = dummShape();
				var g:Graphics = dum.graphics;

				startAppropriateFill(g, s);
				g.drawCircle(x, y, radius);
				g.endFill();

				this.bitmap.draw(dum, this.state.geoMatrix);

				#if !html5
				for (filter in this.filters) {
					var copy = new BitmapData(this.bitmap.width, this.bitmap.height, true, 0x000000);
					copy.applyFilter(this.bitmap, this.bitmap.rect, new flash.geom.Point(0, 0), filter);
					this.bitmap = copy;
				}
				#end
				restore();

			case SText(text, x, y, state):
				save();
				restoreState(state);
				var decs:Array<String> = this.state.textDecoration.split(' ');
				var tform:Map<String, Dynamic> = [
					"size" => this.state.textSize,
					"font" => this.state.textFont,
					"bold" => Lambda.has(decs, 'bold'),
					"italic" => Lambda.has(decs, 'italic')
				];
				var area:Array<Int> = s.measureText(text, tform);
				var frac:Float = (4 / 3);
				var txtImg:BitmapData = s.captureText(text, x, y, Math.round(frac * area[0]), Math.round(frac * area[1]), this.state.textColor, tform);

				this.bitmap.draw(txtImg, this.state.geoMatrix);

				#if !html5
				for (filter in this.filters) {
					var copy = new BitmapData(this.bitmap.width, this.bitmap.height, true, 0x000000);
					copy.applyFilter(this.bitmap, this.bitmap.rect, new flash.geom.Point(0, 0), filter);
					this.bitmap = copy;
				}
				#end

				this.restore();

			case SImage(img, sx, sy, sw, sh, dx, dy, dw, dh, state):
				this.save();
				var renderer:Sprite = new Sprite('');
				renderer.data = img;
				var scaled:BitmapData = renderer.getScaledBitmap(sx, sy, sw, sh, dx, dy, dw, dh);

				this.bitmap.draw(scaled, this.state.geoMatrix);

				#if !html5
				for (filter in this.filters) {
					var copy = new BitmapData(this.bitmap.width, this.bitmap.height, true, 0x000000);
					copy.applyFilter(this.bitmap, this.bitmap.rect, new flash.geom.Point(0, 0), filter);
					this.bitmap = copy;
				}
				#end

				this.restore();

			default:
				null;
		}
	}
	public function render(surface:Surface):Void {
		if (this.updated == true) {
			this.bitmap = new BitmapData(this.width, this.height, true, 0x000000);
			for (command in this.commands) {
				drawCommand(command, surface);
			}
			this.sprite.data = this.bitmap;
			// var dummy:BitmapData = this.sprite.getScaledBitmap(0, 0, this.sprite.imageWidth, this.sprite.imageHeight, this.x, this.y, this.width, this.height);
			var dummy:BitmapData = this.bitmap;
			surface.drawImage(dummy, this.x, this.y, this.width, this.height);
			this.updated = false;
		} else {
			surface.drawImage(this.bitmap, this.x, this.y, this.width, this.height);
		}
	}
	public function createLinearGradient(focalPoint:Float, colorStops:Array<Array<Dynamic>>):PencilType {
		return PencilType.PLinearGradient(focalPoint, colorStops);
	}
	public function createPattern(width:Int, height:Int):Canvas {
		return new Canvas(width, height);
	}
}

private typedef Command = CanvasCommand;