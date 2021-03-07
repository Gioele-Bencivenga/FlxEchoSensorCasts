package entities;

import flixel.FlxObject;
import tiles.Tile;
import flixel.FlxG;
import hxmath.math.MathUtil;
import flixel.util.helpers.FlxRange;
import hxmath.math.Vector2;
import flixel.util.FlxColor;
import utilities.DebugLine;
import flixel.util.FlxTimer;
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

	/**
	 * The time in seconds between each sensors check.
	 * 
	 * Each `tick`s we get what the sensors are hitting.
	 */
	var sensTick:Float;

	/**
	 * The timer that will `sense()` each `sensTick` seconds.
	 */
	var senserTimer:FlxTimer;

	/**
	 * The number of environment sensors that this entity will have.
	 */
	var sensorCount:Int;

	/**
	 * The array containing the entity's environment sensors.
	 */
	public var sensors(default, null):Array<Line>;

	/**
	 * Array containing the rotations of the sensors.
	 */
	var sensorsRotations:Array<Float>;

	/**
	 * The range of possible rotations that sensors of an entity can assume.
	 */
	var possibleRotations:FlxRange<Float>;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);

		possibleRotations = new FlxRange(-40., 40.);

		sensorCount = 5;
		sensorsRotations = [
			for (i in 0...sensorCount) {
				if (i == 0)
					possibleRotations.start;
				else if (i == 1)
					possibleRotations.start + (possibleRotations.end / 2);
				else if (i == 2)
					possibleRotations.start + possibleRotations.end;
				else if (i == 3)
					possibleRotations.end + (possibleRotations.start / 2);
				else if (i == 4)
					possibleRotations.end;
			}
		];

		sensors = [for (i in 0...sensorCount) null]; // fill the sensors array with nulls

		sensTick = 0.3;
		senserTimer = new FlxTimer();
		senserTimer.start(sensTick, (_) -> sense(), 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		seekTarget(FlxG.mouse.getPosition().x, FlxG.mouse.getPosition().y, 100);
	}

	/**
	 * Points the `desiredDirection` vector towards the `target` with a length of `maxSpeed` or less. 
	 * 
	 * The movement handling method in `Entity` will then move the entity in the `desiredDirection`.
	 * @param _targetX X coordinate of the target
	 * @param _targetY Y coordinate of the target
	 * @param _arriveDistance 0 by default, set it to the distance after which the entity must start slowing down (higher = further)
	 */
	function seekTarget(_targetX:Float, _targetY:Float, _arriveDistance = 0) {
		var targetPos = new Vector2(_targetX, _targetY);
		// subtracting the target position vector from the target's position vector gives us a vector pointing from us to the target
		desiredDirection = targetPos - this.get_body().get_position();

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
	function fleeTarget(_targetX:Float, _targetY:Float, _departDistance:Float = 0) {
		var targetPos = new Vector2(_targetX, _targetY);
		// subtracting the target position vector from the entity's position vector gives us a vector pointing from us to the target
		desiredDirection = targetPos - this.get_body().get_position();
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
		var castLength = 120; // linecast length
		// we need an array of bodies for the linecast
		var bodiesArray:Array<Body> = PlayState.collidableBodies.get_group_bodies();

		DebugLine.clearCanvas(); // clear previously drawn lines

		for (i in 0...sensors.length) {
			sensors[i] = Line.get();
			sensors[i].set_from_vector(this.get_body().get_position(), this.get_body().rotation + sensorsRotations[i], castLength);

			var res = sensors[i].linecast_all(bodiesArray);

			if (res.length > 1) { // hit something
				for (r in res) {
					if (r.body.get_object() != this) { // hit something other than ourselves
						if(/*object hit is resource*/){
							DebugLine.drawLine(sensors[i].start.x, sensors[i].start.y, sensors[i].end.x, sensors[i].end.y, FlxColor.YELLOW, 1.5);
						}
					}
				}
			} else {
				color = FlxColor.YELLOW;
				DebugLine.drawLine(sensors[i].start.x, sensors[i].start.y, sensors[i].end.x, sensors[i].end.y);
			}
			sensors[i].put();
		}
	}

	override function kill() {
		super.kill();
		if (senserTimer.active) {
			senserTimer.cancel();
			senserTimer.destroy();
		}
	}
}
