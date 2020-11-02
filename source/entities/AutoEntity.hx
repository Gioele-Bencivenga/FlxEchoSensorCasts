package entities;

import flixel.FlxSprite;
import lime.math.Vector2;
import supplies.Supply;
import haxe.Resource;

using utilities.FlxEcho;

/**
 * Autonomous Entity class representing an entity able to act autonomously by acquiring targets and moving towards them.
 */
class AutoEntity extends Entity {
	/**
	 * The current `Supply` an entity wants to reach. Can be set using `assignTarget()`.
	 */
	var target(default, null):Supply;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (target != null) {
			seekTarget();
		}
	}

	function seekTarget() {
		var desired = target.get_body().get_position() - this.get_body().get_position();
		desired.normalizeTo(maxSpeed);

		// belonging in `Entity.handleMovement()`
		var steer = desired - this.get_body().velocity;
		steer.normalizeTo(maxSteerSpeed);

		this.get_body().push(steer.x, steer.y);
	}

	public function assignTarget(_target:Supply) {
		target = _target;
	}

	// backup method not used at the moment, please ignore
	function seek(_target:Supply) {
		desiredDirection = _target.get_body().get_position() - this.get_body().get_position();
		desiredDirection.normalizeTo(maxSpeed);

		// belonging in `Entity.handleMovement()`
		direction = desiredDirection - this.get_body().velocity;
		direction.clamp(0, maxSteerSpeed);
		this.get_body().push(direction.x, direction.y);
	}
}
