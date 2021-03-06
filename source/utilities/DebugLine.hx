package utilities;

import entities.AutoEntity;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;
using echo.FlxEcho;

class DebugLine extends FlxSprite {
	/**
	 * Draw a line from a startPosition to an endPosition.
	 * @param _startX X coordinate of the line's start position
	 * @param _startY Y coordinate of the line's start position
	 * @param _endX X coordinate of the line's end position
	 * @param _endY Y coordinate of the line's end position
	 * @param _color line's color
	 * @param _thickness line's thickness
	 * @param _smooth whether the line should be smoothed or not
	 * @return the sprite that was drawn on the `canvas`
	 */
	public static inline function drawLine(_startX:Float, _startY:Float, _endX:Float, _endY:Float, _color = FlxColor.RED, _thickness = 1.,
			_smooth = true):FlxSprite {
		var lineStyle:LineStyle = {color: _color, thickness: _thickness};
		var drawStyle:DrawStyle = {smoothing: true};

		var lineSprite = PlayState.canvas.drawLine(_startX, _startY, _endX, _endY, lineStyle, drawStyle);

		return lineSprite;
	}
}
