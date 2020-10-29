package entities;

import flixel.FlxG;

using utilities.FlxEcho;
class Player extends Entity {
	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		handleInput();
	}

	function handleInput() {
		direction.set(0, 0);
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
			direction.x = -1;
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
			direction.x = 1;
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
			direction.y = -1;
		if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
			direction.y = 1;
	}
}
