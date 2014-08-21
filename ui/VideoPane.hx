package gryffin.ui;

import flash.display.BitmapData;

import gryffin.Entity;
import gryffin.Surface;
import gryffin.Stage;

#if html5
	import js.html.CanvasElement;
	import js.Browser;

	class VideoPane extends Entity {
		public var bm:BitmapData;
		public var _canvas:CanvasElement;
		public var _context:Dynamic;
		public var _video:Dynamic;

		public function new( video:Dynamic ):Void {
			super();

			this._video = video;
			this._canvas = cast Browser.document.createElement('canvas');
			this.width = this._canvas.width = this._video.videoWidth;
			this.height = this._canvas.height = this._videoHeight;
			this._context = this._canvas.getContext('2d');

			this.bm = new BitmapData(this.width, this.height);
		}
		override public function render(g:Surface, stage:Stage):Void {
			g.drawImage(this.bm, this.x, this.y, this.width, this.height);
		}
	}
#end