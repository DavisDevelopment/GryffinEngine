package gryffin.shaders;

import gryffin.Colors;
import gryffin.Stage;
import gryffin.Surface;
import gryffin.Entity;
import gryffin.Types;
import gryffin.Utils;
import gryffin.utils.MapTools;
import gryffin.display.Sprite;
import gryffin.shaders.Texture;

import hscript.Parser;
import hscript.Interp;

import openfl.Assets;


class ShaderList {
	public static function get(name:String):Null<Dynamic> {
		return _shaders.get(name);
	}
	public static function create(name:String, func:Dynamic):Dynamic {
		//- First, check that [name] does not already exist
		var canDeclare:Bool = !(_shaders.exists(name));
		var shaderFunc:Dynamic = null;
		if (canDeclare) {
			var workinWith:String = Types.basictype(func);
			switch (workinWith) {
				case "Function":
					shaderFunc = prepareShaderFunction(func);

				case "String":
					if (Assets.exists(func + '')) {
						var code:String = Assets.getText(Std.string(func));
						var rawFunc:Dynamic = compileShaderFunction(code);
						shaderFunc = prepareShaderFunction(rawFunc);
					} else {
						throw 'ShaderCompilationError: File "$func" not found';
					}

				default:
					throw 'ShaderCompilationError: Cannot create Shader from $workinWith Object';
			}
			_shaders.set(name, shaderFunc);
		}
		return shaderFunc;
	}
	public static function prepareShaderFunction(func:Dynamic):Dynamic {
		var shaderFunc:Dynamic = function(textur:Texture, ?x:Int = 0, ?y:Int = 0, ?width:Int, ?height:Int):Array<Array<Int>> {
			var ent:Entity = textur.owner;
			var w:Int = width == null ? i(textur.sprite.imageWidth) : width;
			var h:Int = height == null ? i(textur.sprite.imageHeight) : height;
			var rows:Array<Array<Int>> = textur.getRows(x, y, width, height);

			var nrows:Array<Array<Int>> = new Array();
			for (y in (0...(rows.length - 1))) {
				var row:Array<Int> = rows[y];
				var nrow:Array<Int> = new Array();
				for (x in (0...(row.length - 1))) {
					var icolor:Int = row[x];
					var color:Array<Int> = torgb(icolor);
					var args:Array<Dynamic> = [ent, x, y];
					args = args.concat(color);

					var new_color:Array<Int> = Reflect.callMethod(null, func, args);
					//trace(new_color);

					nrow.push(fromrgb(new_color));
				}
				nrows.push(nrow);
			}

			return nrows;
		};
		shaderFunc = Utils.memoize(shaderFunc);
		return shaderFunc;
	}
	public static dynamic function compileShaderFunction(code:String):Dynamic {
		var parser = new Parser();
		parser.allowJSON = true;
		var program = parser.parseString(code);
		var interp = new Interp();
		bindBuiltins(interp);
		interp.variables.set('message', "FUCK YOU!!");
		interp.execute(program);

		var main:Null<Dynamic> = interp.variables.get('main');
		if (main != null && Types.basictype(main) == "Function") {
			return main;
		} else {
			throw 'ShaderCompilationError: GryffinSL Shaders MUST have a [main] function';
		}
	}
	public static function bindBuiltins(interp:Interp):Void {
		var expose:String->Dynamic->Void = function(x:String, y:Dynamic):Void interp.variables.set(x,y);
		var toExpose:Array<Array<Dynamic>> = MapTools.toPairs(shader_builtins);
		for (pair in toExpose) {
			expose(pair[0], pair[1]);
		}
	}
	public static dynamic function torgb(color:Int):Array<Int> {
		trace('I');
		var red:Int = (color >> 16 & 0xFF);
		var green:Int = (color >> 8 & 0xFF);
		var blue:Int = (color & 0xFF);
		return [red, green, blue];
	}
	public static dynamic function fromrgb(color:Array<Int>):Int {
		var red:Int = color[0];
		var green:Int = color[1];
		var blue:Int = color[2];
		return ((Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue));
	}

	private static function __init__():Void {
		i = (Math.floor.bind(_));
		torgb = Utils.memoize(torgb);
		fromrgb = Utils.memoize(fromrgb);
		compileShaderFunction = Utils.memoize(compileShaderFunction);



		shader_builtins = new Map();
		shader_builtins['to_rgb'] = torgb;
		shader_builtins['from_rgb'] = fromrgb;

		_shaders = new Map();
	}
	public static var shader_builtins:Map<String, Dynamic>;
	private static var _shaders:Map<String, Dynamic>;

	private static var i:Float->Int;
}