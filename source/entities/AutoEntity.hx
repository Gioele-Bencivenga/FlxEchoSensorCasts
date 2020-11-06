package entities;

import hxmath.math.MathUtil;
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
			fleeTarget();
		}
	}

	public function assignTarget(_target:Supply) {
		target = _target;
	}

	/**
	 * Points the `desiredDirection` vector towards the `target` with a length of `maxSpeed`. The movement handling method in `Entity` will then move the entity in the `desiredDirection`.
	 * @param _diffTarget if you want you can specify a different target from `target` to follow
	 */
	function seekTarget(?_diffTarget:Supply) {
		var targetToSeek = target;
		if (_diffTarget != null)
			targetToSeek = _diffTarget;

		desiredDirection = targetToSeek.get_body().get_position() - this.get_body().get_position();
		desiredDirection.normalizeTo(maxSpeed);
	}

	/**
	 * Description
	 * @param _diffTarget if you want you can specify a different target from `target` to flee
	 */
	function fleeTarget(?_diffTarget:Supply) {
		var targetToFlee = target;
		if (_diffTarget != null)
			targetToFlee = _diffTarget;

		desiredDirection = targetToFlee.get_body().get_position() - this.get_body().get_position();
		desiredDirection.normalizeTo(maxSpeed);
		desiredDirection.multiplyWith(-1);
	}
}
