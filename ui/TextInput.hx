package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.display.Sprite;
import gryffin.display.Canvas;
import gryffin.Entity;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import gryffin.utils.MapTools;
import gryffin.Colors;
import gryffin.events.GryffinEvent;

class TextInput extends Entity {
	public var validCharacters:String;
	private var canvas:Canvas;

	public var styles:Map<String, Dynamic>;
	public var placeholder:String;
	public var value:String;
	public var cursor:Int;

	public var multiline:Bool;
	public var autosize:Bool;
	public var readonly:Bool;

	public var focused(get, never):Bool;
	public function new() {
		super();
		this.placeholder = '';
		this.value = '';
		this.cursor = 3;
		this.styles = new Map();
		this.validCharacters = "ABCDEFGHIJKLMNOPQRSTUVQXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()-_+=[]{}|\\/<>?,.~`'\";: \n\r";
		this.multiline = false;
		this.autosize = true;

		this.z = 32;


		this.on('activate', function(e:Dynamic):Dynamic {
			init();
			return null;
		});
	}
	public function init():Void {
		if (this.stage != null) {
			this.canvas = new Canvas(this.width, this.height);
			this.canvas.x = this.x;
			this.canvas.y = this.y;
			canvas.setFillColor('#FF0000');

			var me = this;
			var prevFocused:Null<Entity> = null;

			if (!this.readonly) {
				this.on('click', function(e:Dynamic):Dynamic {
					if (!me.focused) {
						prevFocused = me.stage.getEnv('__focused__');
						me.stage.setEnv('__focused__', me);
						me.cursor = me.value.length - 1;
						trace("You Clicked me, bitch!");
					}
					me.resolveCursor(e);
					return null;
				});
				this.on('stage:click', function(e:Dynamic):Dynamic {
					if (e.target != me) {
						var fc = me.stage.getEnv('__focused__');
						if (fc != me)
							me.stage.setEnv('__focused__', fc);
						else
							me.stage.setEnv('__focused__', null);
					}
					return null;
				});
				this.on('key-down', function(e:GryffinEvent):Dynamic {
					me.keyDown(e);
					return null;
				});
				this.on('key-up', function(e:GryffinEvent):Dynamic {
					me.keyUp(e);
					return null;
				});
			}
			this.on('render', function(e:Dynamic):Dynamic {

				return null;
			});
		}
		this.styles = MapTools.merge(this.styles, this.defaultStyles());
	}
	public function defaultStyles():Map<String, Dynamic> {
		return [
			"padding" => 4,
			"min-width" => 50,
			"background-color" => "#FFFFFF",
			"color" => "#000000",
			"font-size" => 12,
			"font-weight" => ""
		];
	}
	public function getTextFormat():Map<String, Dynamic> {
		var tform:Map<String, Dynamic> = new Map();
		tform.set('size', styles.get('font-size'));
		tform.set('bold', Lambda.has(styles.get('font-weight').split(' '), 'bold'));
		tform.set('italic', Lambda.has(styles.get('font-weight').split(' '), 'italic'));
		return tform;
	}
	override public function update(s:Surface, stage:Stage):Void {
		if (!this.multiline) {
			this.value = StringTools.replace(this.value, '\r', '');
			this.value = StringTools.replace(this.value, '\n', '');
		}
		if (this.autosize) {
			var txt:String = (this.value == '' ? this.placeholder : this.value);

			var area:Array<Int> = s.measureText(txt, this.getTextFormat());
			var newWidth:Int = Math.round(area[0] + this.styles.get('padding') * 2);
			var newHeight:Int = Math.round(area[1] + this.styles.get('padding') * 2);
			this.width = Math.round(Math.max(Math.round(this.styles.get('min-width')), newWidth));
			this.height = newHeight;
		}
		this.canvas.x = this.x;
		this.canvas.y = this.y;
	}
	override public function render(s:Surface, stage:Stage):Void {
		canvas.alpha = 255;
		if (this.cursor <= 0) this.cursor = 0;
		if (this.cursor > this.value.length)
			this.cursor = this.value.length;

		var color:Dynamic = this.styles.get('background-color');

		canvas.setFillColor(color);
		canvas.rect(0, 0, this.width, this.height);
		canvas.text(this.value, this.x + this.styles.get('padding'), this.y + this.styles.get('padding'));
		stage.surface.drawCanvas(canvas);

		var tform:Map<String, Dynamic> = this.getTextFormat();
		var tarea:Array<Int> = s.measureText(this.value, tform);
		var tcolor:Dynamic = this.focused ? this.styles.get('color') : Colors.lighten(this.styles.get('color'), 0.5);
		var args:Array<Dynamic> = [this.value, this.x + this.styles.get('padding'), this.y + this.styles.get('padding'), tarea[0] + 15, tarea[1] + 15, tcolor, this.getTextFormat()];
		
		//s.drawText(this.value, this.x + this.styles.get('padding'), this.y + this.styles.get('padding'), tarea[0] + this.styles.get('padding'), tarea[1] + this.styles.get('padding'), tcolor, this.getTextFormat());

		var rects:Array<Rectangle> = this.getLetterSizes(tform);
		var rect:Rectangle = rects[this.cursor];
		if (rect == null) return;
		canvas.clear();
	}
	public function getLetterSizes(tform:Map<String, Dynamic>):Array<Rectangle> {
		var sizes:Array<Rectangle> = new Array();
		var bits:Array<String> = this.value.split('');
		var i:Int = 0;
		var widthSoFar:Int = Math.round(this.x + this.styles.get('padding'));
		var y:Int = this.y + this.styles.get('padding');
		for (c in bits) {
			var farea:Array<Int> = this.stage.surface.measureText(c, tform);
			var area:Array<Float> = [for (n in farea) Std.parseFloat(n + '')+2];
			sizes.push(new Rectangle([widthSoFar, y], area));
			widthSoFar += Math.round(area[0]);
			i++;
		}

		return sizes;
	}
	public inline function valid(code:Int):Bool {
		var validCodes:Array<Int> = [for (c in this.validCharacters.split('')) c.charCodeAt(0)];
		return Lambda.has(validCodes, code);
	}
	public function getText(event:GryffinEvent):Null<String> {
		if (!valid(event.charCode)) return null;
		return String.fromCharCode(event.charCode);
	}
	public function keyDown(event:GryffinEvent):Void {
		return;
	}
	public function keyUp(event:GryffinEvent):Void {
		var bits:Array<String> = this.value.split('');
		var letter:String = getText(event);
		if (letter != null) {
			bits.insert(this.cursor, letter);
			this.cursor += 1;
		} else {
			switch (event.keyCode) {
				case 8:
					bits.splice(this.cursor - 1, 1);
					this.cursor -= 1;
				case 37:
					this.cursor -= 1;
					trace(this.cursor);
				case 38:
					trace(this.cursor);
				case 40:
					trace(this.cursor);
				case 39:
					this.cursor += 1;
					trace(this.cursor);
				default:
					trace(event.charCode + ' => ' + String.fromCharCode(event.charCode));
			}
		}
		this.value = bits.join('');
	}
	public function resolveCursor(event:Dynamic):Void {
		var sizes:Array<Rectangle> = getLetterSizes(this.getTextFormat());
		var i:Int = 0;

		for (rect in sizes) {
			if (event.x > Math.round(rect.x)) {
				i++;
			}
		}
		trace(i);
		this.cursor = i;
	}
	private function get_focused():Bool {
		return (this.stage.getEnv('__focused__') == this);
	}
}