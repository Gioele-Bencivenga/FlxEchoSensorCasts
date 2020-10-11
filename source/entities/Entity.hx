package entities;

import flixel.math.FlxVector;
import hxmath.math.Vector2;
import flixel.FlxSprite;

using utilities.FlxEcho;

class Entity extends FlxSprite {
	/**
	 * Maximum velocity that this entity's physics body can reach.
	 */
	public static inline final MAX_VELOCITY = 1000;

	/**
	 * Maximum rotational velocity that this entity's physics body can reach.
	 */
	public static inline final MAX_ROTATIONAL_VELOCITY = 1000;

	var direction:Vector2;

	/**
	 * Whether the Entity can move or not.
	 */
	var canMove:Bool;

	/**
	 * Whether the `Entity` is moving or not.
	 */
	var isMoving:Bool;

	/**
	 * Speed at which an `Entity` can move.
	 */
	var speed:Int;

	/**
	 * Minimum velocity that when reached allows the Entity to move again.
	 */
	var minVel:Float;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y);
		makeGraphic(_width, _height, _color);

		direction = new Vector2(0, 0);

		speed = 50;
		minVel = 110;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (canMove)
			handleMovement();
	}

	function handleMovement() {
		if (this.get_body().velocity.length < minVel) {
			direction.multiplyWith(speed);
			this.get_body().velocity.addWith(direction);
		}
	}

	/**
	 * Killing this object will also remove its physics body.
	 */
	override function kill() {
		super.kill();
		this.get_body().remove_body();
	}
}
