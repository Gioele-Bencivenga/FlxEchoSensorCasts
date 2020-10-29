package entities;

import lime.math.Vector2;
import supplies.Supply;
import haxe.Resource;

using utilities.FlxEcho;

/**
 * Autonomous Entity class representing an entity able to act autonomously by acquiring targets and moving towards them.
 */
class AutoEntity extends Entity {
	/**
	 * The current `supply` an entity wants to reach.
	 */
	var target:Supply;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	function seek(_target:Supply) {
		target = _target;

		desiredVel = target.get_body().get_position() - this.get_body().get_position();
		desiredVel.normalizeTo(maxSpeed); // we normalize the vector then multiply it by maxSpeed
	}
}
