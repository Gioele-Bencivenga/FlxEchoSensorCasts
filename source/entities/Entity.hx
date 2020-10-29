package entities;

import flixel.math.FlxVector;
import hxmath.math.Vector2;
import flixel.FlxSprite;

using utilities.FlxEcho;

class Entity extends FlxSprite {
	/**
	 * Maximum velocity that this `Entity`'s physics body can reach.
	 */
	public static inline final MAX_VELOCITY = 1000;

	/**
	 * Maximum rotational velocity that this `Entity`'s physics body can reach.
	 */
	public static inline final MAX_ROTATIONAL_VELOCITY = 1000;

	/**
	 * The desired velocity vector this `Entity` has regarding the target it wants to reach.
	 */
	var desiredVel:Vector2;

	/**
	 * The actual direction of the `Entity`, calculated from subtracting the desired and actual velocity of this entity.
	 */
	var direction:Vector2;

	/**
	 * Whether the `Entity` can move or not.
	 */
	var canMove:Bool;

	/**
	 * Whether the `Entity` is moving or not.
	 */
	var isMoving:Bool;

	/**
	 * Maximum speed an `Entity` can move at.
	 */
	var maxSpeed:Float;

	/**
	 * Maximum speed at which the `Entity` is able to steer it course.
	 */
	var maxSteerSpeed:Float;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y);
		makeGraphic(_width, _height, _color);

		canMove = true;

		desiredVel = new Vector2(0, 0);
		direction = new Vector2(0, 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (canMove)
			handleMovement();
	}

	function handleMovement() {
		direction = desiredVel - this.get_body().velocity;

		this.get_body().push(direction.x, direction.y);
	}

	/**
	 * Killing this object will also remove its physics body.
	 */
	override function kill() {
		super.kill();
		this.get_body().remove_body();
	}
}
