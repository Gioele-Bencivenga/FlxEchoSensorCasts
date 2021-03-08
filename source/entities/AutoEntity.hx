package entities;

import hxmath.math.MathUtil;
import flixel.FlxG;
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
	 * Number of environment sensors that agents have.
	 */
	public static inline final SENSORS_COUNT = 6;

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

	/**
	 * Array containing the lengths of the sensors.
	 */
	var sensorsLengths:Array<Float>;

	/**
	 * Whether this entity is the camera's target or not.
	 * 
	 * Updated in the PlayState's `onAgentClick()` function.
	 */
	public var isCamTarget:Bool;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);

		isCamTarget = false;

		possibleRotations = new FlxRange(-65., 65.);

		sensorsRotations = [
			for (i in 0...SENSORS_COUNT) {
				switch (i) {
					case 0:
						possibleRotations.start;
					case 1:
						possibleRotations.start + (possibleRotations.end / 2);
					case 2:
						possibleRotations.start + (possibleRotations.end - (possibleRotations.end / 10));
					case 3:
						possibleRotations.end + (possibleRotations.start + (possibleRotations.end / 10));
					case 4:
						possibleRotations.end + (possibleRotations.start / 2);
					case 5:
						possibleRotations.end;
					default:
						0;
				}
			}
		];

		sensorsLengths = [
			for (i in 0...SENSORS_COUNT) {
				switch (i) {
					case 0:
						120;
					case 1:
						135;
					case 2:
						160;
					case 3:
						160;
					case 4:
						135;
					case 5:
						120;
					default:
						100;
				}
			}
		];

		sensors = [for (i in 0...SENSORS_COUNT) null]; // fill the sensors array with nulls

		sensTick = 0.15;
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
		// we need an array of bodies for the linecast
		var bodiesArray:Array<Body> = PlayState.collidableBodies.get_group_bodies();

		if (isCamTarget)
			DebugLine.clearCanvas(); // clear previously drawn lines

		for (i in 0...sensors.length) { // do this for each sensor
			sensors[i] = Line.get(); // init the sensor
			// create a vector to subtract from the body's position in order to to gain a relative offset
			var relOffset = Vector2.fromPolar(MathUtil.degToRad(this.get_body().rotation + sensorsRotations[i]),
				(this.get_body().shape.bounds().height / 2) + 10); // radius is distance from body
			var sensorPos = this.get_body()
				.get_position()
				.addWith(relOffset); // this body's pos added with the offset will give us a sensor starting position out of the body
			// set the actual sensors position
			sensors[i].set_from_vector(sensorPos, this.get_body().rotation + sensorsRotations[i], sensorsLengths[i]);
			// cast the line, returning all intersections
			var hit = sensors[i].linecast(bodiesArray);
			if (hit != null) { // if we hit something
				var lineColor = FlxColor.RED;
				switch (hit.body.bodyType) {
					case 1: // hit a Tile (wall)
						lineColor = FlxColor.YELLOW;
					case 2: // hit an Entity
						lineColor = FlxColor.MAGENTA;
					case 3: // hit a Supply
						lineColor = FlxColor.CYAN;
					default: // hit unknown
						lineColor = FlxColor.BROWN;
				}
				if (isCamTarget)
					DebugLine.drawLine(sensors[i].start.x, sensors[i].start.y, sensors[i].end.x, sensors[i].end.y, lineColor, 1.5);
			} else { // if we didn't hit anything
				if (isCamTarget)
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
