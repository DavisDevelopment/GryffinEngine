package gryffin.ui;

import gryffin.Entity;
import gryffin.Stage;
import gryffin.Surface;

class UIElement extends Entity {
	public var color:Dynamic;
	public var margin:Float;
	public var padding:Float;
	public var fontFamily:String;
	public var fontSize:Float;
	public var borderSize:Float;
	public var borderRadius:Float;
	public var borderColor:Dynamic;

	public var backgroundColor:Dynamic;
	public var backgroundImage:flash.display.BitmapData;

	public function new() {
		super();
		this.color = '#000000';
		this.margin = 0;
		this.padding = 0;
		this.fontFamily = 'Arial';
		this.fontSize = 12;
		this.borderRadius = 1;
		this.borderColor = '#000000';
		this.backgroundColor = '#000000';
	}
}