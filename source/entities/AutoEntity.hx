package entities;

import haxe.Resource;
using utilities.FlxEcho;

/**
 * Autonomous Entity class representing an entity able to act autonomously by acquiring targets and moving towards them.
 */
class AutoEntity extends Entity {
    var target:
	public function new(_x:Float, _y:Float, _width:Int, _height:Int, _color:Int) {
		super(_x, _y, _width, _height, _color);
	}
}
