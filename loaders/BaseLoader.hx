package gryffin.loaders;

//- Standard Library Imports
import haxe.io.Bytes;

//- Flash/OpenFL Imports
import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.media.Sound;

//- Gryffin Imports
import gryffin.EventDispatcher;
import gryffin.Stack;
import gryffin.display.Sprite;
import gryffin.utils.MapTools;
import gryffin.utils.PathTools;
import gryffin.core.assets.manager.FileLoader;
import gryffin.core.assets.manager.misc.FileType;
import gryffin.core.assets.manager.misc.FileInfo;

class BaseLoader {
	//- Load file into memory, in "Bytes" form
	public static function loadBytes( id:String, ?callback:Null<Bytes> -> Void ):Void {
		if (callback == null) {
			callback = (function(x:Null<Bytes>) return);
		}
		var proc_bytelist:ByteArray->Bytes = function(bitlist:ByteArray):Bytes {
			var res:Bytes = toBytesFromByteArray(bitlist);
			cache(id, res);
			return res;
		};
		//- [id] is a URL to a file
		if (isURL(id) == true) {
			var loader:FileLoader = new FileLoader();
			var complete:FileInfo->Void = function(info:FileInfo):Void {
				var bitlist:Null<ByteArray> = info.data;
				var output:Null<Bytes> = null;
				if (bitlist != null) {
					output = proc_bytelist(bitlist);
				}
				callback(output);
			};
			loader.onFilesLoaded.add(function(files:Array<FileInfo>):Void {
				complete(files[0]);
			});
			loader.queueFile(id, FileType.BINARY);
			loader.loadQueuedFiles();
		}
		//- [id] is a path to a local file
		else {
			if (NAssets.exists(id)) {
				NAssets.loadBytes(id, function(ba:ByteArray):Void {
					var byteform:Bytes = proc_bytelist(ba);
					callback(byteform);
				});
			} else {
				callback(null);
			}
		}
	}
//= Load Queue Functions
	public static function queueAssetLoad(id:String, type:String):Void {
		_queue.push({
			'id' : id,
			'type': type
		});
		trace('Queuing "$id" for load..');
	}
	public static function queueAsset(asso:Dynamic):Void {
		_queue.push(asso);
	}
//= Event System Functions
	public static function on(type:String, handler:Dynamic, ?once:Bool) event_system.on(type, handler, once);
	public static function once(type:String, handler:Dynamic) event_system.once(type, handler);
	public static function emit(type:String, data:Dynamic) event_system.emit(type, data);
	public static function off(type:String, ?handler:Dynamic) event_system.ignore(type, handler);

//= Utility Functions
	public static function isURL(id:String):Bool {
		var isHTTP:Bool = (id.indexOf('http://') == 0 || id.indexOf('https://') == 0);
		#if html5
			var orig:String = (js.Browser.location.origin + '');
			return (id.indexOf(orig) == 0 && isHTTP);
		#else
			return isHTTP;
		#end
	}
	public static function cache(id:String, data:Bytes):Void {
		_filecache.set(id, data);
	}
	public static function uncache(id:String):Void {
		_filecache.remove(id);
	}
	public static function compileAlias(descriptor:Null<String>):String -> String {
		if (descriptor != null) {
			return function(file:String):String {
				var nfile:String = (file + '');
				var base:String = PathTools.basename(nfile);

				nfile = StringTools.replace(nfile, '*', base);

				return nfile;
			};
		} else {
			return function(file:String):String {
				return file;
			};
		}
	}
//= Data Format Conversion Functions
	public static function toBytesFromByteArray(ba:ByteArray):Bytes {
		return cast(ba, Bytes);
	}
	public static function toArrayFromBytes(bitlist:Bytes):Array<Int> {
		var output:Array<Int> = new Array();
		for (i in (0...(bitlist.length - 1))) {
			try {
				var bit:Int = bitlist.get(i);
				output.push(bit);
			} catch (error : String) {
				trace(error);
				break;
			}
		}
		return output;
	}
//= Internal Variables
	public static var progress:Float;
	private static var event_system:EventDispatcher;
	private static var _filecache:Map<String, Bytes>;
	private static var _queue:Array<Dynamic>;
	private static var _assetModels:Array<AssetModel>;

//= Class Initialization Methods
	private static function __init__():Void {
		event_system = new EventDispatcher();
		_filecache = new Map();
		_queue = new Array();
		_assetModels = new Array();
		progress = 0;
		var assetCount:Int = _queue.length;
		var i:Int = 0;

		var loaded:Array<Dynamic> = new Array();
		for (item in _queue) {
			(function(item, index) {
				loadBytes(item.id, function(result:Null<Bytes>):Void {
					if (result != null) {
						loaded.push({
							'id' : item.id,
							'type': item.type,
							'content': result
						});
					}
					var prog:Float = (assetCount / index);
					progress = prog;
					//- Still Loading
					if (prog < 1) {
						emit('initial:load-progress', {
							'amount' : prog,
							'of' : assetCount
						});
					}
					//- Just Finished
					else {
						emit('initial:load-complete', loaded);
					}
				});
			}(item, i));
			i++;
		}
	}
}


//- Private typedefs
private typedef NAssets = openfl.Assets;
private typedef AssetModel = Dynamic;