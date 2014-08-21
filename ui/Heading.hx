package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.display.Sprite;
import gryffin.Entity;
import gryffin.geom.Rectangle;
import gryffin.geom.Point;
import gryffin.utils.MapTools;
import gryffin.Colors;

import gryffin.display.Canvas;
import gryffin.ui.UIElement;

class Heading extends UIElement {

	public var text:String;
	public var canvas:Canvas;

	public function new(text:String) {
		super();
		this.text = text;
		this.color = "#000000";

		var me = this;
		this.on('activate', init);
	}
	public function init():Void {
		this.canvas = new Canvas(this.width, this.height);
		draw();
	}
	public function draw():Void {
		this.canvas.width = this.width;
		this.canvas.height = this.height;
		canvas.clear();
		canvas.save();

		canvas.textColor = this.color;
		canvas.textSize = this.fontSize;
		canvas.text(this.text, 1, 1);

		canvas.restore();
	}
	override public function render(g:Surface, stage:Stage):Void {
		g.drawCanvas(this.canvas);
	}
	override public function update(g:Surface, stage:Stage):Void {
		var area:Array<Int> = canvas.measureText(this.text);

		this.width = Math.ceil(area[0] + this.padding);
		this.height = Math.ceil(area[1] + this.padding);
	}
}