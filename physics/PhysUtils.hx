package gryffin.physics;

class PhysUtils {
	//converts vx/vy velocities to an angle/speed vector
	public static function getVector( vx:Float, vy:Float ):Array < Float > {
		var sx:Float = 0;
		var sy:Float = 0;
		var ex:Float = vx;
		var ey:Float = vy;
		var angle:Float = Math.atan2( vx, vy );
		var speed = Utils.distance( sx, sy, ex, ey );
		return [ angle, speed ];
	}
	public static function getVelocity( angle:Float, speed:Float ):Array < Float > {
		var vx:Float = Math.cos(angle) * speed;
		var vy:Float = Math.sin(angle) * speed;
		return [ vx, vy ];
	}
}