package utilities;

import echo.FlxEcho;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;

class DebugLine extends FlxSprite {
	public var canvas(default, null):FlxSprite;

	var lineStyle:LineStyle;
	var drawStyle:DrawStyle;

	public function new() {
		super();

		canvas = new FlxSprite();
		canvas.makeGraphic(Std.int(FlxEcho.instance.world.width), Std.int(FlxEcho.instance.world.height), FlxColor.TRANSPARENT, true);
		// add(canvas) in playstate!
	}

	public function drawLine(_startX:Float, _startY:Float, _endX:Float, _endY:Float, _color = FlxColor.RED, _thickness = 1., _smooth = true) {
		lineStyle = {
			color: _color,
			thickness: _thickness
		};
		drawStyle = {smoothing: true};

		canvas.drawLine(_startX, _startY, _endX, _endY, lineStyle, drawStyle);
	}
}
