package gryffin.display;

class BasicLight extends Entity {
	public var brightness:Float;
	public var color:Dynamic;
	public var active:Bool;
	
	public function new( x:Int, y:Int ) {
		super();
		this.x = x;
		this.y = y;
		this.color = "#00FF00";
		this.brightness = 1;
		this.active = true;
	}
	override public function render( g:Surface, stage:Stage ):Void {
		g.drawCircle( this.x, this.y, 5, this.color );
	}
}