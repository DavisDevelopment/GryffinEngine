package gryffin.display;

import flash.display.BitmapData;

class Scene extends Container {
	public var backgroundColor:Dynamic;
	public var backgroundImage:Dynamic;
	public var scrolling:Bool;
	public var scrollDirection:String;
	public var scrollSpeed:Int;
	public var grid:TileGrid;
	public var anchor:Entity;
	
	public function new( stage:Stage ) {
		super( stage );
		
		this.backgroundColor = "white";
		this.scrollX = 0;
		this.scrollSpeed = 5;
		this.scrolling = false;
		this.scrollDirection = "right";
		this.on("click", this.on_click);
	}
	
	override public function render( g:Surface, stage:Stage ):Void {
		if ( this.backgroundImage != null ) {
			g.drawImage( this.backgroundImage, 0, 0, this.width, this.height );
		} else {
			g.drawRect( 0, 0, this.width, this.height, this.backgroundColor );
		}
		super.render( g, stage );
	}
	override public function update( g:Surface, stage:Stage ):Void {
		this.width = stage.boundX;
		this.height = stage.boundY;
		if ( this.anchor != null ) {
			var player = this.anchor;
			
			//If player is mostly to the right of the page.
			if ( player.x + player.width > this.width - 50 && player.vx > 0 ) {
				this.scrolling = true;
				this.scrollDirection = "right";
			}
			//If player is mostly to the left of the page.
			else if ( player.x < 50 && player.vx < 0 ) {
				this.scrolling = true;
				this.scrollDirection = "left";
			}
			//else if ( player.x + player.width > this.width - 50 && player.vx < 0 ) this.scrolling = false;
			//else if ( player.x < 50 && player.vx > 0 ) this.scrolling = false;
			
		}
		if ( this.scrolling ) {
			if ( this.scrollDirection == "right" ) {
				if ( this.anchor.vx >= 0 ) {
					this.scrollX += this.scrollSpeed;
					this.anchor.x -= this.scrollSpeed;
				} else {
					this.scrolling = false;
				}
			}
			else if ( this.scrollDirection == "left" ) {
				if ( this.anchor.vx <= 0 ) {
					this.scrollX -= this.scrollSpeed;
					this.anchor.x += this.scrollSpeed;
				} else {
					this.scrolling = false;
				}
			}
		}
		super.update( g, stage );
	}
	public function on_click( data:Dynamic ):Dynamic {
		var x:Float = data.stageX;
		var y:Float = data.stageY;
		var children = this.childNodes.copy();
		children.reverse();
		for ( item in children ) {
			var touchingX:Bool = ( x > item.x && x < item.x + item.width );
			var touchingY:Bool = ( y > item.y && y < item.y + item.height );
			if ( touchingX && touchingY ) {
				item.handleEvent( data );
				break;
			}
		}
		//this.emit('click', data);
		return null;
	}
}