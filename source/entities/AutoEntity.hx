package entities;

import echo.Body;
import echo.Line;
import states.PlayState;
import utilities.HxFuncs;
import supplies.Supply;

using echo.FlxEcho;

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

		seekTarget(PlayState.resource, 100);
		sense();
	}

	public function assignTarget(_target:Supply) {
		target = _target;
	}

	/**
	 * Points the `desiredDirection` vector towards the `target` with a length of `maxSpeed` or less. The movement handling method in `Entity` will then move the entity in the `desiredDirection`.
	 * @param _target if you want you can specify a different target from `target` to follow, otherwise this will get set = to `target` if left as `null`
	 * @param _arriveDistance 0 by default, set it to the distance after which the entity must start slowing down (higher = further)
	 */
	function seekTarget(_target:Supply = null, _arriveDistance = 0) {
		// if no _target has been provided we use the default target
		if (_target == null)
			_target = target;

		// subtracting the target position vector from the entity's position vector gives us a vector pointing from us to the target
		desiredDirection = _target.get_body().get_position() - this.get_body().get_position();

		var distance = desiredDirection.length; // we use the vector's length to measure the distance
		// if _arriveDistance was set higher than 0 and the measured distance is less than it
		if (distance < _arriveDistance) {
			// we create a new speed variable that diminishes in value with how close we are
			var newSpeed = HxFuncs.map(distance, 0, _arriveDistance, 0, maxSpeed);
			desiredDirection.normalizeTo(newSpeed); // and proceed at the lower speed
		} else {
			desiredDirection.normalizeTo(maxSpeed); // otherwise we proceed at maxSpeed
		}

		return desiredDirection;
	}

	/**
	 * Points the `desiredDirection` vector opposite to the `target` with a length of `maxSpeed` or less. The movement handling method in `Entity` will then move the entity in the `desiredDirection`.
	 *
	 * This is exactly the opposite of `seekTarget()`.
	 * @param _target if you want you can specify a different target from `target` to flee from, otherwise this will get set = to `target` if left as `null`
	 * @param _departDistance 0 by default, set it to the distance after which the entity must start fleeing the target (higher = further)
	 */
	function fleeTarget(_target:Supply = null, _departDistance:Float = 0) {
		// if no _target has been provided we use the default target
		if (_target == null)
			_target = target;

		// subtracting the target position vector from the entity's position vector gives us a vector pointing from us to the target
		desiredDirection = _target.get_body().get_position() - this.get_body().get_position();
		// we invert the vector so it points opposite
		desiredDirection.multiplyWith(-1);

		var distance = desiredDirection.length; // we use the vector's length to measure the distance
		// if _departDistance was set higher than 0 and the measured distance is less than it
		if (distance < _departDistance) {
			// we create a new speed variable that increases in value with how close we are
			var newSpeed = HxFuncs.map(distance, 0, _departDistance, maxSpeed, 0);
			desiredDirection.normalizeTo(newSpeed); // and proceed at the lower speed
		} else {
			desiredDirection.normalizeTo(0); // otherwise we stay put
		}
	}

	/**
	 * Get information about the environment from the sensors.
	 */
	function sense() {
		var castCount = 3;
		var castLength = 50;
		var bodiesArray:Array<Body> = PlayState.collidableBodies.get_group_bodies();
		for (i in 0...bodiesArray.length) {
			if (bodiesArray[i] == this.get_body()) {
				bodiesArray[i] == null;
			}
		}
		var ray = Line.get();

		for (i in 0...castCount) {
			ray.set_from_vector(this.get_body().get_position(), 100 * (i / castCount), castLength);
			var res = ray.linecast(bodiesArray);

			if (res != null) {
				trace("Hit something!");
			}
		}
	}
}
