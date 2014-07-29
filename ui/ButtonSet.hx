package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.Entity;
import gryffin.geom.Rectangle;
import gryffin.utils.MapTools;
import gryffin.Colors;

class ButtonSet extends Entity {
	public var buttons:Array<Button>;

	public function new(?btns:Array<Button>) {
		super();
		if (btns == null) btns = new Array();
		this.buttons = new Array();
		for (btn in btns) {
			this.append(btn);
		}
	}
	public function append(button:Button):Void {
		if (!Lambda.has(this.buttons, button)) {
			this.buttons.push(button);
			this.bindEvents(button);
		}
	}
	override public function update(c:Surface, stage:Stage):Void {
		var padding:Int = 5;
		var y:Int = this.y, i:Int = 0;
		var lwidth:Int = 0;
		for (button in this.buttons) {
			y += padding;
			if (i != 0)
				y += button.height;

			button.y = y;
			button.x = this.x;

			if (button.width > lwidth)
				lwidth = button.width;

			i++;
		}
		this.height = y;
		this.width = lwidth;
	}
	private function bindEvents(button:Button):Void {
		var toBind:Array<String> = ['show', 'hide', 'cache', 'uncache'];
		for (event in toBind) {
			this.bindEvent(event, button);
		}
	}
	private function bindEvent(type:String, button:Button):Void {
		this.on(type, function(e:Dynamic):Dynamic {
			var func:Dynamic = Reflect.getProperty(button, type);
			try {
				if (Reflect.isFunction(func)) {
					Reflect.callMethod(button, func, []);
				}
			} catch (error : String) {
				trace(error);
			}
			return null;
		});
	}
}