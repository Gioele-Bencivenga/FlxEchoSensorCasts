package states;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject.*;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using Math;
using utilities.FlxEcho;
using hxmath.math.Vector2;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	var player:Box;
	var level_data = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], [1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1], [1, 0, 0, 1, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	];

	override function create() {
		// First thing we want to do before creating any physics objects is init() our Echo world.
		FlxEcho.init({
			width: level_data[0].length * 16, // Make the size of your Echo world equal the size of your play field
			height: level_data.length * 16,
			gravity_y: 800
		});

		// Normal, every day FlxGroups!
		var terrain = new FlxGroup();
		add(terrain);

		var bouncers = new FlxGroup();
		add(bouncers);

		// We'll step through our level data and add objects that way
		for (j in 0...level_data.length)
			for (i in 0...level_data[j].length) {
				switch (level_data[j][i]) {
					case 1:
						// Just a regular old terrain block
						var bluebox = new Box(i * 16, j * 16, 16, 16, 0xFF0080FF);
						bluebox.add_body({mass: 0}); // We'll pass in body options with mass set to 0 so that it's static
						bluebox.add_to_group(terrain); // Instead of `group.add(object)` we use `object.add_to_group(group)`
					case 2:
						// Orange boxes will act like springs!
						var orangebox = new Box(i * 16, j * 16, 16, 16, 0xFFFF8000);
						orangebox.origin.set(8, 16); // We'll set the origin here so that we can animate our orange block later
						orangebox.add_body({mass: 0});
						orangebox.add_to_group(bouncers);
					case 3:
						player = new Box(i * 16, j * 16, 8, 12, 0xFFFF004D, true);
						player.add_body();
						add(player);
					default:
						continue;
				}
			}

		// lets add some ramps too! They'll belong to the same collision group as the blue boxes we made earlier.
		for (i in 0...8) {
			var ramp = new Ramp(16, 112 + i * 16, 16 + i * 16, 128 - i * 16, NW);
			ramp.add_to_group(terrain);
		}

		// Our first physics listener collides our player with the terrain group.
		player.listen(terrain);
		// Our second physics listener collides our player with the bouncers group.
		player.listen(bouncers, {
			// We'll add this listener option - every frame our player object is colliding with a bouncer in the bouncers group we'll run this function
			stay: (a, b,
				c) ->
			{ // where a is our first physics body (`player`), b is the physics body it's colliding with (`orangebox`), and c is an array of collision data.
					// for every instance of collision data
					for (col in c) {
						// This checks to see if the normal of our collision is pointing downward - you could use it for hop and bop games to see if a player has stomped on an enemy!
						if (col.normal.dot(Vector2.yAxis).round() == 1) {
							// set the player's velocity to go up!
							a.velocity.y = -400;
							// animate the orange box!
							var b_object:FlxSprite = cast b.get_object();
							b_object.scale.y = 1.5;
							FlxTween.tween(b_object.scale, {y: 1}, 0.5, {ease: FlxEase.elasticOut});
						}
					}
				}
		});
	}
}

class Box extends FlxSprite {
	var control:Bool;

	public function new(x:Float, y:Float, w:Int, h:Int, c:Int, control:Bool = false) {
		super(x, y);
		makeGraphic(w, h, c);
		this.control = control;
	}

	override function update(elapsed:Float) {
		if (control)
			controls();
		super.update(elapsed);
	}

	function controls() {
		var body = this.get_body();
		body.velocity.x = 0;
		if (FlxG.keys.pressed.LEFT)
			body.velocity.x -= 128;
		if (FlxG.keys.pressed.RIGHT)
			body.velocity.x += 128;
		if (FlxG.keys.justPressed.UP && isTouching(FLOOR))
			body.velocity.y -= 256;
	}
}

class Ramp extends FlxSprite {
	public function new(x:Float, y:Float, w:Int, h:Int, d:RampDirection) {
		trace('$x / $y / $w / $h');
		super(x, y);
		makeGraphic(w, h, 0x00FFFFFF);
		var verts = [[0, 0], [w, 0], [w, h], [0, h]];
		switch d {
			case NE:
				verts.splice(0, 1);
			case NW:
				verts.splice(1, 1);
			case SE:
				verts.splice(3, 1);
			case SW:
				verts.splice(2, 1);
		}
		this.drawPolygon([for (v in verts) FlxPoint.get(v[0], v[1])], 0xFFFF0080);
		this.add_body({
			mass: 0,
			shape: {
				type: POLYGON,
				vertices: [for (v in verts) new Vector2(v[0], v[1])],
			}
		});
	}
}

enum RampDirection {
	NE;
	NW;
	SE;
	SW;
}
