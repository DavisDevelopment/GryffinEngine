package gryffin.display;



import motion.Actuate;
import gryffin.EventDispatcher;

#if cpp
	import cpp.vm.Thread;
#elseif neko
	import neko.vm.Thread;
#elseif html5
	typedef JSWorker = js.html.Worker;
#end

class Worker extends EventDispatcher {
	#if (neko||cpp)
	public var thread:Thread;
	public var dead:Bool;
	#end
	public function new(func : Dynamic) {
		super();
		this.thread = Thread.create(createThreadMain(func));
		this.dead = false;
		this.thread.sendMessage(Thread.current());
		this.thread.sendMessage(this);

		this.startCheckCycle();
	}
	public function sendMessage(msg:Dynamic):Null<Dynamic> {
		this.thread.sendMessage(msg);
		//var response:Null<Dynamic> = Thread.readMessage(false);
		//return response;
		return null;
	}
	public function kill():Void {
		this.dead = true;
	}
	private function startCheckCycle():Void {
		var me = this;
		var message:Dynamic = null;
		function checkForMessage() {
			message = Thread.readMessage(false);
			if (message != null)
				me.emit('message', message);
			if (!me.dead)
				Actuate.timer(0.002).onComplete(checkForMessage, null);
		}
		checkForMessage();
	}
	private function createThreadMain(f : Dynamic):Void->Void {
		if (!Reflect.isFunction(f)) return (function() return);
		return function():Void {
			var main:Thread = Thread.readMessage(true);
			var self:Worker = Thread.readMessage(true);

			var postMessage = main.sendMessage;
			var message:Dynamic = null;
			function checkForMessage() {
				if (!self.dead) {
					message = Thread.readMessage(true);
					if (message != null) {
						f(postMessage, message);
						if (!self.dead) checkForMessage();
					}
				}
			}
			checkForMessage();
		};
	}
}