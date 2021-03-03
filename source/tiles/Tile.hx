package tiles;

import flixel.FlxSprite;

using echo.FlxEcho;

class Tile extends FlxSprite {
	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y);

		makeGraphic(_width, _height, _color);
	}

	/**
	 * Killing this object will also remove its physics body.
	 */
	override function kill() {
		super.kill();

		if (this.get_body() != null) {
			this.get_body().remove_body();
		}
	}
}
