package entities;

import flixel.FlxG;

using utilities.FlxEcho;

class Player extends Entity {
	var maxSpeed:Float;

	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
		canMove = true;

		maxSpeed = 150;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (canMove) {
			handleMovement();
		}
	}

	function handleMovement() {
		if (this.get_body().velocity.length <= maxSpeed) {
			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
				this.get_body().velocity.x -= maxSpeed;
			if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
				this.get_body().velocity.x += maxSpeed;
			if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
				this.get_body().velocity.y -= maxSpeed;
			if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
				this.get_body().velocity.y += maxSpeed;
		}
	}
}
