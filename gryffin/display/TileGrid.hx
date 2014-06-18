package gryffin.display;

import flash.display.BitmapData;

/* --- Entity Grid Class, for Implementing Grid Systems --- */

class TileGrid extends Container {
	public var tiles: Array < Tile >;
	public var anchor:Entity;
	
	public function new( stage:Stage, width:Int, height:Int ) {
		super( stage );
		this.x = 0;
		this.y = 0;
		this.width = width;
		this.height = height;
		this.textures = stage.textures;
		this.tiles = new Array();
	}
	override public function render( g:Surface, stage:Stage ):Void {
		for ( tile in this.tiles ) {
			if ( tile != null ) {
				if (tile.texture != null && this.textures.exists(tile.texture)) {
					g.drawImage(tile.texture, tile.x, tile.y, tile.width, tile.height);
				}
			}
		}
		super.render(g, stage);
	}
	override public function update( g:Surface, stage:Stage ):Void {
		haxe.ds.ArraySort.sort(this.tiles, function ( x:Entity, y:Entity ):Int {
			return (x.z + y.z);
		});
		var sel = this.anchor;
		if ( sel != null ) {
			var player = sel;
			for ( tile in this.tiles ) {
				if ( tile != null ) {
					if (tile.updateMe) tile.update( g, stage );
					if (player.collidesWith(tile)) {
						tile.collide( player, stage );
					}
				}
			}
		}
		super.update( g, stage );
	}
	public function createSlots():Void {
		var x:Int = 0;
		var y:Int = 0;
		var width:Int = 20;
		var height:Int = 20;
		while ( x < this.width && y < this.height ) {
			if ( x + width > this.width ) {
				x = 0;
				y += height;
			}
			else {
				var tile = new Tile( x, y, width, height );
				this.tiles.push(tile);
				x += width;
			}
		}
	}
	public function setAt( x:Int, y:Int, what:Tile ):Void {
		for ( tile in this.tiles ) {
			if (Utils.isPointInRect({'x':x, 'y':y}, tile)) {
				var i:Int = Lambda.indexOf(this.tiles, tile);
				this.tiles.remove(tile);
				this.tiles.insert(i, what);
			}
		}
	}
}