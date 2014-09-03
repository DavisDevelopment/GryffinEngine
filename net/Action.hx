package gryffin.net;

class Action {
	public var target:Entity;
	public var parameters:Dynamic;
	public var numParams:Int;
	public var subActions:Stack;
	public var complete:Dynamic;
	
	public function new( target:Entity, params:Int ) {
		this.target = target;
		this.subActions = new Stack();
		this.numParams = params;
		this.parameters = [];
		this.complete = function( x ) {
			'stuff';
		};
	}
	
	public function setProperty( name:String, value:Dynamic ):Action {
		var self = this;
		var realValue:Dynamic = value;
		if (Types.typename(value) == "String") {
			var val = cast( value, String );
			if ( val.substring(0,1) == "@" ) {
				realValue = Reflect.getProperty(self.parameters, val.substring(1));
			}
		}
		this.subActions.push(function( cb ) {
			Reflect.setProperty( self.target, name, realValue );
			cb();
		});
		return this;
	}
	public function callMethod( name:String, ?args:Array<Dynamic> ):Action {
		var self = this;
		var realArgs:Array<Dynamic> = [];
		if ( args == null ) {
			realArgs = null;
		} else {
			for ( item in args ) {
				if (Types.typename(item) == "String") {
					item = cast( item, String );
					if ( item.substring(0,1) == "@" ) {
						var realItem = Reflect.getProperty(self.parameters, item.substring(1));
						realArgs.push(realItem);
					}
				} else {
					realArgs.push(item);
				}
			}
		}
		this.subActions.push(function( cb ) {
			try {
				Reflect.callMethod( self.target, name, realArgs );
			} catch ( error : String ) {
				trace( error );
			}
		});
		return this;
	}
	public function apply( f:Dynamic ):Action {
		var self = this;
		this.subActions.push(function( cb ) {
			if (Reflect.isFunction(f)) {
				var args:Array<Dynamic> = [cb, self.parameters];
				Reflect.callMethod(self.target, f, args);
			} else {
				cb();
			}
		});
		return this;
	}
	public function onComplete( f:Dynamic ):Action {
		this.complete = f;
		return this;
	}
	public function perform( params:Dynamic ):Void {
		this.parameters = params;
		this.subActions.call(this.complete);
	}
}