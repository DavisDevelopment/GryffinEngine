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
import gryffin.loaders.Parent;
import gryffin.display.Scrollable;

class Page extends Entity implements Parent<Entity> implements Scrollable {
	public var background:Canvas;
	public var childNodes:Array<Entity>;
	public var _cascading:Bool;
	public var scrollX:Int;
	public var scrollY:Int;

	public function new(name:String) {
		super();
		this._cascading = true;
		this.id = name;
		this.childNodes = new Array();
		this.scrollX = 0;
		this.scrollY = 0;
		this.background = new Canvas(this.width, this.height);
	}
	public function add(item:Entity):Void {
		this.childNodes.push(item);
		item.emit('activate', this);
	}
	public function configureBackground(configFunc:Canvas->Void):Void {
		configFunc(this.background);
	}
	override public function update(s:Surface, stage:Stage):Void {
		this.background.x = this.x;
		this.background.y = this.y;

		haxe.ds.ArraySort.sort(this.childNodes, function ( x:Entity, y:Entity ):Int {
			return (x.z - y.z);
		});
		var _x:Int = 0;
		var _y:Int = 0;
		for (kid in this.childNodes) {
			_x = kid.x;
			_y = kid.y;

			kid.x = (kid.x + this.x + this.scrollX);
			kid.y = (kid.y + this.y + this.scrollY);
			kid.update(s, stage);

			kid.x = _x;
			kid.y = _y;
		}
	}
	override public function render(s:Surface, stage:Stage):Void {
		this.background.render(s);
		this.emit('render', this);
		var _x:Int = 0;
		var _y:Int = 0;
		for (kid in this.childNodes) {
			_x = kid.x;
			_y = kid.y;

			kid.x = (kid.x + this.x + this.scrollX);
			kid.y = (kid.y + this.y + this.scrollY);
			kid.render(s, stage);

			kid.x = _x;
			kid.y = _y;
		}
	}
}