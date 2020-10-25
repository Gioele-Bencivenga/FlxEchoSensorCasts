package states;

import haxe.ui.containers.menus.MenuItem;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.components.*;
import haxe.ui.Toolkit;
import flixel.FlxCamera;
import generators.Generator;
import entities.Entity;
import entities.Player;
import tiles.Tile;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject.*;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import echo.util.TileMap;

using Math;
using utilities.FlxEcho;
using hxmath.math.Vector2;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	/// CONSTANTS
	public static inline final TILE_SIZE = 32;

	var gen:Generator;

	var player:Player;

	var levelData:Array<Array<Int>>;

	var terrain:FlxGroup;
	var bouncers:FlxGroup;

	/**
	 * Simulation camera, the camera displaying the simulation.
	 */
	var simCam:FlxCamera;

	/**
	 * UI camera, the camera displaying the interface indipendently from zoom.
	 */
	var uiCam:FlxCamera;

	/**
	 * Our UI using haxeui, this contains the list of components and all.
	 */
	var uiView:Component;

	override function create() {
		/// UI STUFF
		Toolkit.init();
		Toolkit.scale = 1; // temporary fix for scaling while ian fixes it

		terrain = new FlxGroup();
		add(terrain);
		bouncers = new FlxGroup();
		add(bouncers);

		uiView = ComponentMacros.buildComponent("assets/ui/main-view.xml");
		add(uiView);
		// xml events are for scripting with hscript, you need to do this if you want to call Haxe methods
		uiView.findComponent("btn_gen_cave", MenuItem).onClick = btn_generateCave_onClick;

		setupCameras();

		/* Other collisions
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
									a.velocity.y = -10000;
									// animate the orange box!
									var b_object:FlxSprite = cast b.get_object();
									b_object.scale.y = 1.5;
									FlxTween.tween(b_object.scale, { y: 1 }, 0.5, { ease: FlxEase.elasticOut });
								}
						}
					}
			});
		 */
	}

	function btn_generateCave_onClick(_) {
		var item = uiView.findComponent("btn_gen_cave", MenuItem); // need to specify component type if you want field completion after
		generateCaveTilemap();
	}

	function btn_placePlayer_onClick(_) {
		var item = uiView.findComponent("btn_place_player", MenuItem); // need to specify component type if you want field completion after
		placePlayer();
	}

	function btn_playPause_onClick(_) {
		var item = uiView.findComponent("btn_play_pause" /*, Type*/);

		if (FlxEcho.updates)
			FlxEcho.updates = false;
		else
			FlxEcho.updates = true;
	}

	function generateCaveTilemap() {
		// reset the groups to fill them again
		emptyGroups([terrain, bouncers]);

		gen = new Generator(100, 100); // we instantiate a generator that will generate a matrix of cells
		levelData = gen.generateCave();

		// First thing we want to do before creating any physics objects is init() our Echo world.
		FlxEcho.init({
			width: levelData[0].length * TILE_SIZE, // Make the size of your Echo world equal the size of your play field
			height: levelData.length * TILE_SIZE,
		});

		// We'll use Echo's TileMap utility to generate physics bodies for our Tilemap - making sure to ignore any tile with the index 2 or 3 so we can create objects out of them later
		var tiles = TileMap.generate(levelData.flatten2DArray(), TILE_SIZE, TILE_SIZE, levelData[0].length, levelData.length, 0, 0, 1, null, [2, 3]);
		for (tile in tiles) {
			var bounds = tile.bounds(); // Get the bounds of the generated physics body to create a Box sprite from it
			var wallTile = new Tile(bounds.min_x, bounds.min_y, bounds.width.floor(), bounds.height.floor(), FlxColor.WHITE);
			bounds.put(); // Make sure to "put()" the bounds so that they can be reused later. This can really help with memory management!
			wallTile.set_body(tile); // Attach the Generated physics body to the Box sprite
			wallTile.get_body().mass = 0; // tiles are immovable
			wallTile.add_to_group(terrain); // Instead of `group.add(object)` we use `object.add_to_group(group)`
		}

		// We'll step through our level data and add objects that way
		for (j in 0...levelData.length) {
			for (i in 0...levelData[j].length) {
				switch (levelData[j][i]) {
					case 2:
						// Orange boxes will act like springs!
						var orangebox = new Tile(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0xFFFF8000);
						// We'll set the origin and offset here so that we can animate our orange block later
						orangebox.origin.y = TILE_SIZE;
						orangebox.offset.y = -TILE_SIZE / 2;
						orangebox.add_body({mass: 0}); // Create a new physics body for the Box sprite. We'll pass in body options with mass set to 0 so that it's static
						orangebox.add_to_group(bouncers);
					case 3:
						player = new Player(i * TILE_SIZE, j * TILE_SIZE, Std.int(TILE_SIZE / 2.5), Std.int(TILE_SIZE / 2.5), FlxColor.MAGENTA);
						player.add_body({
							mass: 1,
							drag_length: 500,
							rotational_drag: 150,
							max_velocity_length: Entity.MAX_VELOCITY,
							max_rotational_velocity: Entity.MAX_ROTATIONAL_VELOCITY,
						});
						add(player);
					default:
						continue;
				}
			}
		}

		player.listen(terrain);

		setupCameras();
		simCam.setScrollBoundsRect(0, 0, levelData[0].length * TILE_SIZE, levelData.length * TILE_SIZE);
	}

	function placePlayer() {}

	function setupCameras() {
		if (simCam != null)
			simCam = null;
		if (uiCam != null)
			uiCam = null;
		simCam = new FlxCamera(0, 0, FlxG.width, FlxG.height); // create the simulation camera
		simCam.bgColor = FlxColor.BLACK; // empty space will be rendered as black
		simCam.zoom = 0.6; // zoom back a bit
		simCam.follow(player); // follow the player
		simCam.followLead.set(50, 50);
		simCam.followLerp = 0.01;

		FlxG.cameras.reset(simCam); // dump all current cameras and set the simulation camera as the main one
		FlxCamera.defaultCameras = [simCam]; // set the simulation camera as the default one

		uiCam = new FlxCamera(0, 0, FlxG.width, FlxG.height); // create the ui camera
		uiCam.bgColor = FlxColor.TRANSPARENT; // transparent so we see what's behind it
		FlxG.cameras.add(uiCam); // add it to the cameras list (simCam doesn't need because we set it as the main already)

		uiView.cameras = [uiCam]; // all of the ui components contained in uiView will be rendered by uiCam
		uiView.scrollFactor.set(0, 0); // and they won't scroll
	}

	/**
	 * This function `kill()`s, `clear()`s and `revive()`s the passed groups.
	 *
	 * It's mostly used when re generating the world.
	 *
	 * I think doing this resets the groups and it helped fix a bug with collision when regenerating the map.
	 * If you read this and you know that I could do this better please let me know!
	 *
	 * @param groupsToEmpty an array containing the `FlxGroup`s that you want to reset.
	 */
	function emptyGroups(groupsToEmpty:Array<FlxGroup>) {
		for (group in groupsToEmpty) {
			group.kill();
			group.clear();
			group.revive();
		}
	}
}
