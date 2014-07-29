package gryffin.ui;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.Entity;
import gryffin.Types;
import gryffin.geom.Rectangle;
import gryffin.utils.MapTools;
import gryffin.Colors;

class Tooltip extends Entity {
	public var text:Dynamic;
	public var direction:Int;
	public var padding:Int;
	public var tform:Map<String, Dynamic>;
	public var owner:Entity;

	public function new(owner:Entity, txt:Dynamic, direction:String) {
		super();
		this.owner = owner;
		this.text = txt;
		this.padding = 5;
		this.direction = (function() {
			switch (direction.toLowerCase()) {
				case 'left' : return 0;
				case 'right' : return 1;
				case 'top' : return 2;
				case 'bottom' : return 3;
				default: return 0;
			}
		}());
		this.tform = [
			'size' => 11
		];
	}
	public function getText():String {
		if (Types.basictype(this.text) == 'String') {
			return cast(this.text, String);
		}
		else if (Types.basictype(this.text) == "Function") {
			var res:Dynamic = this.text();
			if (Types.basictype(res) == "String") return cast(res, String);
		}
		return 'Invalid "text" value ${this.text}';
	}
	public function resolvePosition():Void {
		switch (this.direction) {
			case 0: 
				this.x = (this.owner.x - this.width - (this.padding * 2));
				this.y = Std.int(this.owner.y - (this.height - this.owner.height) / 2);
			case 1:
				this.x = (this.owner.x + this.owner.width + (this.padding * 2));
				this.y = Std.int(this.owner.y - (this.height - this.owner.height) / 2);
		}
	}
	override public function update(c:Surface, stage:Stage):Void {
		var area:Array<Int> = c.measureText(this.getText(), this.tform);
		this.width = (area[0] + 5);
		this.height = Std.int(area[1] + 5);
		this.resolvePosition();
	}
	override public function render(c:Surface, stage:Stage):Void {
		this.update(c, stage);

		var msg:String = this.getText();
		var area:Array<Int> = c.measureText(msg, tform);

		c.drawRect(this.x, this.y, this.width, this.height, '#FFFFFF');
		var vertices:Array<Array<Int>> = [];
		switch (this.direction) {
			case 0:
				vertices.push([this.x + this.width + this.padding, this.y + Std.int(this.height / 2)]);
				var bit:Int = Std.int(this.height/4);
				vertices.push([this.x + this.width, this.y + bit*1]);
				vertices.push([this.x + this.width, this.y + bit*3]);
			case 1:
				var bit:Int = Std.int(this.height/4);
				vertices.push([this.x, this.y + bit*1]);
				vertices.push([this.x - this.padding, this.y + Std.int(this.height / 2)]);
				vertices.push([this.x, this.y + bit*3]);
				vertices.reverse();
		}
		c.drawPolygon(vertices, '#FFFFFF');
		c.drawText(msg, this.x + 2, this.y + 2, area[0] + 4, area[1] + 2, '#000000', tform);
	}
}