package gryffin.physics;

import gryffin.Stage;
import gryffin.physics.PhysicsEntity;
import gryffin.physics.CollisionDetector;

class Engine {
	public var g_factor:Float;
	public var stage:Stage;
	
	public function new ( stage:Stage ) {
		this.stage = stage;
		this.g_factor = 0.9;
	}
	public function update():Void {
		var entList = this.stage.get("..PhysicsEntity");
		var entities:Array < PhysicsEntity > = [for ( x in entList ) cast(x, PhysicsEntity)];
		
		//Handle Collisions
		for ( ent1 in entities ) {
			for ( ent2 in entities ) {
				if ( ent1 != ent2 ) {
					if (ent1.collidesWith(ent2)) {
						CollisionDetector.resolveElastic( ent1, ent2 );
					}
				}
			}
		}
		//Handle gravity
		for ( ent in entities ) {
			switch ( ent.entityType ) {
				case PhysicsEntity.DYNAMIC:
					ent.vy += this.g_factor;
			}
		}
	}	
}