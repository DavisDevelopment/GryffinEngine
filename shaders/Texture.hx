package gryffin.shaders;

import openfl.Assets;
import flash.display.BitmapData;

import gryffin.Entity;
import gryffin.display.Sprite;

import gryffin.shaders.ShaderProgram;

class Texture {
	public var owner:Null<Entity>;
	public var data:Null<BitmapData>;
	public var sprite:Sprite;

	public function new() {
		this.owner = null;
		this.data = null;
		this.sprite = new Sprite('');
	}
	public function getRows(x:Int = 0, y:Int = 0, ?width:Int, ?height:Int):Array<Array<Int>> {
		if (this.sprite != null) {
			if (width == null) width = i(this.sprite.imageWidth);
			if (height == null) height = i(this.sprite.imageHeight);
			return this.sprite.getFragmentRows(0, 0, width, height);
		} else {
			return new Array();
		}
	}
	public function putRows(newrows:Array<Array<Int>>, sx:Int = 0, sy:Int = 0, ?width:Int, ?height:Int):Void {
		var dat:BitmapData = this.sprite.data;
		if (width == null) width = i(sprite.imageWidth);
		if (height == null) height = i(sprite.imageHeight);

		for (y in (0...(newrows.length - 1))) {
			var nrow:Array<Int> = newrows[y];
			for (x in (0...(nrow.length - 1))) {
				var color:Int = nrow[x];
				this.sprite.data.setPixel(x, y, color);
			}
		}
	}
	public function drawTo(s:Surface, x:Int, y:Int, width:Int, height:Int):Void {
		this.sprite.drawFragment(s, 0, 0, this.sprite.imageWidth, this.sprite.imageHeight, x, y, width, height);
	}
	public static function loadAsset(id:String):Texture {
		var tex:Texture = new Texture();
		tex.sprite = new Sprite(id);
		tex.data = tex.sprite.data;
		return tex;
	}
	public static function attach(owner:Entity, sprite:Sprite):Texture {
		var tex:Texture = new Texture();
		tex.owner = owner;
		tex.sprite = sprite;
		tex.data = sprite.data;

		var texList:Array<Texture> = [];

		if (ShaderProgram._entity_texture_relation.exists(owner)) {
			texList = ShaderProgram._entity_texture_relation.get(owner);
		} else {
			ShaderProgram._entity_texture_relation.set(owner, texList);
		}
		texList.push(tex);

		return tex;
	}

	private static inline function i(x:Float):Int
		return Math.floor(x);
}