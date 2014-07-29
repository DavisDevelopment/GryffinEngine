package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.display.Sprite;
import gryffin.Entity;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import gryffin.utils.MapTools;
import gryffin.Colors;

class Heading extends Entity {
	public var text:String;
	public var text_settings:Map<String, Dynamic>;
	public var color:Dynamic;

	public function new(text:String) {
		super();
		this.text = text;
		this.color = "#000000";
		this.text_settings = new Map();
		var me = this;
		this.on('activate', function(e:Dynamic) {
			me.init();
			return null;
		});
	}
	public function init():Void {
		var defaults:Map<String, Dynamic> = [
			"size" => 24,
			"bold" => false,
			"italic" => false
		];
		this.text_settings = MapTools.merge(this.text_settings, defaults);
	}
	public function configure(key:String, value:Dynamic):Void {
		this.text_settings.set(key, value);
	}
	override public function render(g:Surface, stage:Stage):Void {
		var size = g.measureText(this.text, this.text_settings);
		g.drawText(this.text, this.x, this.y, size[0] + 5, size[1] + 5, this.color, this.text_settings);
		super.render(g, stage);
	}
	override public function update(g:Surface, stage:Stage):Void {
		this.init();
	}
}