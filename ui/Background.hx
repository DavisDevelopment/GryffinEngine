package gryffin.ui;

import flash.display.BitmapData;

import gryffin.Stage;
import gryffin.Surface;
import gryffin.Entity;
import gryffin.display.Sprite;
import gryffin.display.Canvas;

class Background extends Entity {
	public var color:Dynamic;
	public var image(default, set):Null<String>;

	public var sprite:Null<Sprite>;
	public var canvas:Canvas;
	public var bitmap:Null<BitmapData>;
	public var mode:Int;

	private var canvasController:Null<Canvas->Void>;

	public function new(x:Int, y:Int, width:Int, height:Int) {
		super();

		this.mode = 0;
		this.x = x;
		this.y = y;
		this.z = -999;
		this.width = width;
		this.height = height;

		this.color = null;
		this.sprite = null;
		this.canvas = new Canvas(this.width, this.height);
		this.canvasController = null;

		var me = this;
		this.on('activate', function(e:Dynamic) {
			me.init();
			return null;
		});
	}
	function init():Void {
		var me = this;
		if (this.stage != null) {
			this.stage.on('resize', function(e:Dynamic) {
				switch (me.mode) {
					case 1:
						me.bitmap = me.sprite.getScaledBitmap(0, 0, me.sprite.imageWidth, me.sprite.imageHeight, 0, 0, me.width, me.height);
					case 2:
						if (me.canvasController != null) {
							me.canvas.clear();
							me.canvasController(me.canvas);
						}
				}
				return null;
			});
		}
	}
	public function setupCanvas(setupper:Canvas->Void):Void {
		setupper(this.canvas);
		this.mode = 2;
		this.canvasController = setupper;
	}
	override public function render(c:Surface, stage:Stage):Void {
		switch (this.mode) {
			case 0:
				var col:Dynamic = this.color;
				if (col == null) col = '#FFFFFF';
				c.drawRect(this.x, this.y, this.width, this.height, col);

			case 1:
				c.drawImage(this.bitmap, this.x, this.y, this.width, this.height);

			case 2:
				c.drawCanvas(this.canvas);
		}
		this.emit('render', this);
	}
	override public function update(c:Surface, stage:Stage):Void {
		super.update(c, stage);
	}
	public function updateBitmap():Void {
		this.bitmap = this.sprite.getScaledBitmap(0, 0, this.sprite.imageWidth, this.sprite.imageHeight, 0, 0, this.width, this.height);
	}
	private function set_image(img:String):String {
		this.sprite = new Sprite(img);
		this.bitmap = this.sprite.getScaledBitmap(0, 0, this.sprite.imageWidth, this.sprite.imageHeight, 0, 0, this.width, this.height);
		this.image = img;
		this.mode = 1;
		return img;
	}
}