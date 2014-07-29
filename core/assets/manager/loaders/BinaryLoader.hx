package gryffin.core.assets.manager.loaders;

import flash.net.URLLoaderDataFormat;
import gryffin.core.assets.manager.misc.FileType;

class BinaryLoader extends BaseLoader
{
	public function new(id:String) {
		super(id, FileType.BINARY);
		loader.dataFormat = URLLoaderDataFormat.BINARY;
    }
}
