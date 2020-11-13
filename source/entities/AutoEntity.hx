package entities;

import utilities.JoFuncs;
import brains.Perceptron;
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
	 * The entity's "brain", represented by a Perceptron class.
	 */
	var brain(default, null):Perceptron;

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
			seekTarget(300);
		}
	}

	public function assignTarget(_target:Supply) {
		target = _target;
	}

	/**
	 * Points the `desiredDirection` vector towards the `target` with a length of `maxSpeed`. The movement handling method in `Entity` will then move the entity in the `desiredDirection`.
	 * @param _diffTarget if you want you can specify a different target from `target` to follow
	 * @param _arriveDistance 0 by default, set it to the distance after which the entity must start slowing down
	 */
	function seekTarget(?_diffTarget:Supply, _arriveDistance = 0) {
		var targetToSeek = target;
		if (_diffTarget != null)
			targetToSeek = _diffTarget;

		// subtracting the target position vector from the entity's position vector gives us a vector pointing from us to the target
		desiredDirection = targetToSeek.get_body().get_position() - this.get_body().get_position();

		var distance = desiredDirection.length; // we use the vector's length to measure the distance
		// if _arriveDistance was set higher than 0 and the measured distance is less than it
		if (distance < _arriveDistance) {
			// we create a new speed variable that diminishes in value with how close we are
			var slowerSpeed = JoFuncs.map(distance, 0, _arriveDistance, 0, maxSpeed);
			desiredDirection.normalizeTo(slowerSpeed); // and proceed at the lower speed
		} else {
			desiredDirection.normalizeTo(maxSpeed); // otherwise we proceed at maxSpeed
		}
	}

	/**
	 * Points the `desiredDirection` vector opposite to the `target` with a length of `maxSpeed`. This is exactly the opposite of `seekTarget()`.
	 * @param _diffTarget if you want you can specify a different target from `target` to flee from
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
