package entities;

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

	/**
	 * Whether the Entity can move or not.
	 */
	var canMove:Bool;

	/**
	 * Whether the Entity is moving or not.
	 */
	var isMoving:Bool;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y);
		makeGraphic(_width, _height, _color);
	}

	/**
	 * Killing this object will also remove its physics body.
	 */
	override function kill() {
		super.kill();
		this.get_body().remove_body();
	}
}
