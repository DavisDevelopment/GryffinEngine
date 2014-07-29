package gryffin.shaders;

import openfl.Assets;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

import gryffin.Entity;
import gryffin.display.Sprite;
import gryffin.shaders.Texture;

class ShaderProgram {
	public var main:Dynamic;
	public var id:String;

	public function new(id:String) {
		this.id = id;
		this.main = ShaderList.get(id);
	}
	public function apply(target:Entity):Void {
		var textures:Array<Texture> = getAllTextures(target);
		if (Reflect.isFunction(this.main)) {
			trace("OMNOMNOM");
			trace('\n\n');
			trace(this.main);
			for (tex in textures) {
				var new_rows = this.main(tex, null, null, null, null);
				tex.putRows(new_rows);
			}
		} else {
			trace("Nottafunction");
		}
	}

//= Cache-Related Methods
	public function getAllTextures(ent:Entity):Array<Texture> {
		if (_entity_texture_relation.exists(ent)) {
			return _entity_texture_relation.get(ent);
		} else {
			return [];
		}
	}

//= Private Internal Properties
	public static var _entity_texture_relation:Map<Entity, Array<Texture>>;
	public static var _entity_sprite_relation:Map<Entity, Array<Sprite>>;

//= Class Initialization Functions
	public static function __init__():Void {
		_entity_texture_relation = new Map();
		_entity_sprite_relation = new Map();
	}
}