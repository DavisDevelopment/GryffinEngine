package gryffin.physics;

import gryffin.geom.Matrix;

class PhysicsEntity extends Entity {
	//Class Properties
	public static var DYNAMIC:String = 'dynamic';
	public static var KINEMATIC:String = 'kinematic';
	public static var DISPLACE:String = 'displace';
	public static var ELASTIC:String = 'elastic';
	public static var STATIC:String = 'static';
	//Instance Properties
	
	//Properties used internally by the physics engine
	public var collisionType:String;
	public var entityType:String;
	public var active:Bool;
	public var coordMatrix:Matrix;
	//Physical properties
	public var restitution:Float; // 'bounciness'
	public var friction:Float;
	public var ax:Float; // Acceleration on the x-axis
	public var ay:Float; // Acceleration on the y-axis
	public var halfWidth:Float;
	public var halfHeight:Float;
	public var mass:Float;
	
	public function new( ?collision:String, ?type:String ) {
		super();
		this.active = true;
		this.collisionType = ((collision == null) ? PhysicsEntity.ELASTIC : collision);
		this.entityType = ((type == null) ? PhysicsEntity.DYNAMIC : type);
		this.coordMatrix = new Matrix();
		this.restitution = 0.2;
		this.friction = 0.5;
		this.ax = 0;
		this.ay = 0;
		this.halfWidth = this.width * 0.5;
		this.halfHeight = this.height * 0.5;
		this.mass = 1;
	}
	public function updateBounds():Void {
		this.halfWidth = this.width * 0.5;
		this.halfHeight = this.height * 0.5;
	}
	public function getMidX():Float {
		return this.halfWidth + this.x;
	}
	public function getMidY():Float {
		return this.halfHeight + this.y;
	}
	public function getTop():Float {
		return this.y;
	}
	public function getBottom():Float {
		return this.y + this.height;
	}
	public function getLeft():Float {
		return this.x;
	}
	public function getRight():Float {
		return this.x + this.width;
	}
}