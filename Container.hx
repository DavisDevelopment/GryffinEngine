package gryffin;

import flash.display.BitmapData;
import gryffin.loaders.Parent;

class Container extends Entity implements Parent<Entity> {
	public var _cascading:Bool;
	public var childNodes:Array < Entity >;
	public var textures:NativeMap<String, BitmapData>;
	public var scrollX:Int;
	
	public function new( stage:Stage ) {
		super();
		
		this.stage = stage;
		this.childNodes = new Array();
		this._cascading = false;
		this.textures = stage.textures;
		this.width = stage.boundX;
		this.height = stage.boundY;
		this.shaded = true;
	}
	public function add( item:Entity ):Void {
		this.childNodes.push( item );
	}
	override public function render( g:Surface, stage:Stage ):Void {
		for ( child in this.childNodes ) {
			if ( !child._hidden ) child.render( g, stage );
		}
	}
	override public function update( g:Surface, stage:Stage ):Void {
		this.childNodes = this.childNodes.filter(function( ent ) {
			return !ent.remove;
		});
		haxe.ds.ArraySort.sort(this.childNodes, function ( x:Entity, y:Entity ):Int {
			return (x.z - y.z);
		});
		for ( child in this.childNodes ) {
			if ( !child._cache ) child.update( g, stage );
		}
	}
	override public function shade( g:Surface, stage:Stage ):Void {
		for ( ent in this.childNodes ) {
			if ( ent.shaded ) ent.shade( g, stage );
		}
	}
}