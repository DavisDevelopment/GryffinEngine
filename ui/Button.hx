package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.display.Sprite;
import gryffin.Entity;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import gryffin.utils.MapTools;
import gryffin.Colors;

class Button extends UIElement {
	public var text:String;
	public var format:Map<String, Dynamic>;
	public var tooltip:Null<Tooltip>;
	public var onClick:Dynamic;
	public var styles:Dynamic;

	public function new(txt:String, ?rect:Rectangle, ?format:Map<String, Dynamic>, ?tooltip:Dynamic) {
		super();
		var int:Float->Int = Math.ceil.bind(_);
		if (rect == null) {
			rect = new Rectangle([0, 0], [0, 0]);
		}
		this.x = int(rect.x);
		this.y = int(rect.y);
		this.z = 0;
		this.width = int(rect.width);
		this.height = int(rect.height);

		this.text = txt;
		this.format = (format != null ? format : new Map());
		this.styles = {
			'padding': 5
		};
		this.onClick = null;

		if (tooltip != null) {
			var args:Array<Dynamic> = [this, tooltip, 'right'];
			this.tooltip = Type.createInstance(tooltip_class, args);
		}

		this.fontSize = 12;
		this.backgroundColor = '#666666';
		this.color = '#000000';

		this.init();
	}
	public function initDefaults():Void {
		var defaults:Map<String, Dynamic> = [
			"color" => "#000000",
			"background-color" => "#666666",
			"border-radius" => 1,
			"auto-size" => true,
			"padding" => 2,
			"font-size" => 12,
			"font-weight" => '',
			"font-family" => this.fontFamily
		];
		this.format = MapTools.merge(this.format, defaults);
	}
	public function init():Void {
		var me = this;
		this.on('*', function(e:Dynamic) {
			return null;
		});
		this.on('click', function(e:Dynamic) {
			trace('${this.id} was clicked');
			if (Reflect.isFunction(me.onClick)) {
				try {
					me.onClick(e);
				} catch (e:String) {
					me.onClick();
				}
			}
			return null;
		});
		this.initDefaults();
		trace(this.textFormat());
	}
	public function textFormat():Map<String, Dynamic> {
		var tform:Map<String, Dynamic> = new Map();
		tform['color'] = this.color;
		tform['size'] = this.fontSize;
		tform['bold'] = (Lambda.has(format['font-weight'].split(''), 'bold'));
		tform['italic'] = (Lambda.has(format['font-weight'].split(''), 'italic'));
		tform['font'] = this.fontFamily;
		return tform;
	}
	public function captureText(g:Surface):flash.display.BitmapData {
		var i:Float->Int = Math.round.bind(_);
		var tform = this.textFormat();
		var area:Array<Int> = g.measureText(this.text, tform);
		return g.captureText(this.text, i(this.x + this.padding), i(this.y + this.padding), (area[0] + 4), (area[1] + 4), this.color, tform);
	}
	override public function update(c:Surface, stage:Stage):Void {
		this.emit('update', this);
	}
	override public function render(c:Surface, stage:Stage):Void {
		var i:Float->Int = Math.round.bind(_);
		var tform:Map<String, Dynamic> = this.textFormat();
		var area:Array<Int> = c.measureText(this.text, tform);
		//- Draw Backgroud
		if (this.backgroundImage == null) {
			var col:Dynamic = format['background-color'];
			if (format['auto-size'] == true) {
				this.width = area[0];
				this.height = area[1];
				this.width += Std.int(format['padding'] * 4);
				this.height += Std.int(format['padding'] * 2);
			}
			c.drawRoundRect(this.x, this.y, i(this.width + this.padding*2), i(this.height + this.padding*2), i(this.borderRadius), this.backgroundColor);
		} else {
			c.drawImage(this.backgroundImage, this.x, this.y, i(this.width + this.padding*2), i(this.height + this.padding*2));
		}

		//c.drawText(this.text, i(this.x + this.padding), i(this.y + this.padding), (area[0] + 4), (area[1] + 4), this.color, tform);
		c.drawImage(this.captureText(c), i(this.x + this.padding), i(this.y + this.padding), (area[0] + 4), area[1] + 4);

		if (this.tooltip != null && this.mouse_over) {
			this.tooltip.render(c, stage);
		}
		this.emit('render', this);
	}
	override public function contains(x:Float, y:Float, ?z:Float):Bool {
		var mrect:Rectangle = new Rectangle([this.x, this.y, this.z], [this.width, this.height]);
		var tpoint:Point = new Point(x, y, this.z);
		return mrect.contains(tpoint);
	}

	public static var tooltip_class:Class<Tooltip>;
	private static function __init__():Void {
		tooltip_class = Tooltip;
	}
}