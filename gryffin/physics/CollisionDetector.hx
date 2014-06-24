package gryffin.physics;

class CollisionDetector {
	public static var STICKY_THRESHOLD:Float = 0.0004;
	public static function collideRect( collider:PhysicsEntity, collidee:PhysicsEntity ):Bool {
		var l1:Float = collider.getLeft();
		var t1:Float = collider.getTop();
		var r1:Float = collider.getRight();
		var b1:Float = collider.getBottom();
		
		var l2:Float = collidee.getLeft();
		var t2:Float = collidee.getTop();
		var r2:Float = collidee.getRight();
		var b2:Float = collidee.getBottom();
		
		if ( b1 < t2 || t1 > b2 || r1 < l2 || l1 > r2 ) {
			return false;
		}
		
		return true;
	}
	
	public static function resolveElastic( collider:PhysicsEntity, collidee:PhysicsEntity ):Void {
		if ( collider.entityType == PhysicsEntity.STATIC ) return;
		var abs = Math.abs;
		var int = Math.round;
		var pMidX:Float = collider.getMidX();
		var pMidY:Float = collider.getMidY();
		var aMidX:Float = collidee.getMidX();
		var aMidY:Float = collidee.getMidY();
		
		var dx:Float = ( aMidX - pMidX ) / collidee.halfWidth;
		var dy:Float = ( aMidY - pMidY ) / collidee.halfHeight;
		
		var absDX:Float = abs(dx);
		var absDY:Float = abs(dy);
		
		if ( abs(absDX - absDY) < 0.1 ) { // if 'collider' is colliding with 'collidee' from a corner
			//Adjust coordinates to resolve collision
			if ( dx < 0 ) {
				collider.x = int((collidee.getRight() + collidee.coordMatrix.tx) + collider.coordMatrix.tx);
			} else {
				collider.x = int((collidee.getLeft() + collidee.coordMatrix.tx - collider.width) + collider.coordMatrix.tx);
			}
			
			if ( dy < 0 ) {
				collider.y = int((collidee.getBottom() + collidee.coordMatrix.ty) + collider.coordMatrix.ty);
			} else {
				collider.y = int((collidee.getTop() - collider.height + collidee.coordMatrix.ty) + collider.coordMatrix.ty);
			}
			
			//Randomly select an x/y direction to reflect velocity on
			if ( Math.random() < 0.5 ) {
				collider.vx = 0 - collider.vx * collidee.restitution;
				if ( collider.vx < STICKY_THRESHOLD ) {
					collider.vx = 0;
				}
			} else {
				collider.vy = 0 - collider.vy * collidee.restitution;
				if ( collider.vy < STICKY_THRESHOLD ) {
					collider.vy = 0;
				}
			}
		} else if ( absDX > absDY ) { // colliding from left or right
			if ( dx < 0 ) {
				collider.x = int((collidee.getRight() + collidee.coordMatrix.tx) + collider.coordMatrix.tx);
			} else {
				collider.x = int((collidee.getLeft() + collidee.coordMatrix.tx - collider.width) + collider.coordMatrix.tx);
			}
			collider.vx = 0 - collider.vx * collidee.restitution;
			if ( collider.vx < STICKY_THRESHOLD ) {
				collider.vx = 0;
			}
		} else { //colliding from top or bottom
			if ( dy < 0 ) {
				collider.y = int((collidee.getBottom() + collidee.coordMatrix.ty) + collider.coordMatrix.ty);
			} else {
				collider.y = int((collidee.getTop() + collidee.coordMatrix.ty - collider.height) + collider.coordMatrix.ty);
			}
			collider.vy = 0 - collider.vy * collidee.restitution;
			if ( collider.vy < STICKY_THRESHOLD ) {
				collider.vy = 0;
			}
		}
	}
}