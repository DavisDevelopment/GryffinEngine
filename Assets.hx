package gryffin;

//- Standard Library Imports
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import gryffin.utils.PathTools;
import gryffin.utils.MapTools;

@:expose class Assets {

	public static macro function preload(epath:Expr):Expr {
		var relpath:String = ExprTools.getValue(epath);
		var path:String = PathTools.join([Sys.getCwd(), relpath]);
		path = PathTools.normalize(path);
		trace(path);

		var content:haxe.io.Bytes = sys.io.File.getBytes(path);
		_preloadedData.set(path, content);
		
		return Context.makeExpr('Yep', Context.currentPos());
	}

	public static var _preloadedData:Map<String, Dynamic>;
	public static function __init__():Void {
		_preloadedData = new Map();
	}
}