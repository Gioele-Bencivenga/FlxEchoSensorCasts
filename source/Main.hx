package;

import flixel.util.FlxColor;
import flixel.FlxG;
import states.PlayState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(1366, 768, PlayState, 1, 60, 60, true)); // set to true to run in fullscreen
		addChild(new openfl.display.FPS(5, 300, FlxColor.GREEN));

		// we enable the system cursor instead of using the default since flixel's cursor is kind of laggy
		FlxG.mouse.useSystemCursor = true;
	}
}
