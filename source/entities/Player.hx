package entities;

import flixel.FlxG;

using utilities.FlxEcho;

class Player extends Entity {
	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
	}

	override function update(elapsed:Float) {
		handleInput();
		super.update(elapsed);
	}

	function handleInput() {
		desiredDirection.set(0, 0);
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
			desiredDirection.set(-1, 0);
		}
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
			desiredDirection.set(1, 0);
		}
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W) {
			desiredDirection.set(0, -1);
		}
		if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) {
			desiredDirection.set(0, 1);
		}
		desiredDirection.normalizeTo(maxSpeed);
	}
}
