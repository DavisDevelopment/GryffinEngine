package gryffin.events;

class GryffinEvent {
	public var defaultAction(default, set):Null<Dynamic>;
	public var isDefaultPrevented:Dynamic;
	public var type:String;
	public var data:Dynamic;
	
	public function new(type:String) {
		this.type = type;
		this.defaultAction = null;
		this.isDefaultPrevented = false;
		this.data = {};
	}
	public function preventDefault():Void {
		this.isDefaultPrevented = true;
	}
	private function set_defaultAction( action:Null<Dynamic> ):Null<Dynamic> {
		if (action != null && this.defaultAction == null) {
			this.defaultAction = action;
		}
		return action;
	}
}