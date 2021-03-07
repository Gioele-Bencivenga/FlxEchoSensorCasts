package states;

import echo.Body;
import haxe.ui.themes.Theme;
import utilities.HxFuncs;
import entities.AutoEntity;
import supplies.Supply;
import flixel.math.FlxMath;
import flixel.addons.display.FlxZoomCamera;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.components.*;
import haxe.ui.Toolkit;
import flixel.FlxCamera;
import generators.Generator;
import entities.Entity;
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
using echo.FlxEcho;
using hxmath.math.Vector2;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	/// CONSTANTS
	public static inline final TILE_SIZE = 32;

	var gen:Generator;

	var auto:AutoEntity;

	var levelData:Array<Array<Int>>;

	public static var resource:Supply;

	/**
	 * Canvas is needed in order to drawLine().
	 */
	public static var canvas:FlxSprite;

	/**
	 * Collision group containing the terrain tiles.
	 */
	public static var terrainGroup:FlxGroup;

	/**
	 * Collision group containing the entities.
	 */
	public static var entitiesGroup:FlxGroup;

	/**
	 * Group containing the entities, terrain and resources bodies.
	 * 
	 * This is used for ease of linecasting in the `AutoEntity.sense()` function.
	 */
	public static var collidableBodies:FlxGroup;

	/**
	 * Simulation camera, the camera displaying the simulation.
	 */
	var simCam:FlxZoomCamera;

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
		Toolkit.theme = Theme.DARK;

		setupCameras();

		terrainGroup = new FlxGroup();
		add(terrainGroup);
		terrainGroup.cameras = [simCam];
		entitiesGroup = new FlxGroup();
		add(entitiesGroup);
		entitiesGroup.cameras = [simCam];

		collidableBodies = new FlxGroup();

		uiView = ComponentMacros.buildComponent("assets/ui/main-view.xml");
		uiView.cameras = [uiCam]; // all of the ui components contained in uiView will be rendered by uiCam
		uiView.scrollFactor.set(0, 0); // and they won't scroll
		add(uiView);
		// xml events are for scripting with hscript, so we need to get the generated component from code and assign it to the function
		uiView.findComponent("btn_gen_cave", MenuItem).onClick = btn_generateCave_onClick;
		uiView.findComponent("btn_clear_world", MenuItem).onClick = btn_clearWorld_onClick;
		uiView.findComponent("link_website", MenuItem).onClick = link_website_onClick;
		uiView.findComponent("link_github", MenuItem).onClick = link_github_onClick;
		uiView.findComponent("btn_play_pause", Button).onClick = btn_play_pause_onClick;
		uiView.findComponent("btn_zoom", Button).onClick = btn_zoom_onClick;
		uiView.findComponent("btn_zoom_+", Button).onClick = btn_zoomPlus_onClick;
		uiView.findComponent("btn_zoom_-", Button).onClick = btn_zoomMinus_onClick;
		uiView.findComponent("lbl_version", Label).text = haxe.macro.Compiler.getDefine("GAME_VERSION");

		/// WORLD
		generateCaveTilemap();

		/// DRAWING CANVAS
		canvas = new FlxSprite();
		canvas.makeGraphic(Std.int(FlxEcho.instance.world.width), Std.int(FlxEcho.instance.world.height), FlxColor.TRANSPARENT, true);
		canvas.cameras = [simCam];
		add(canvas);

		/// COLLISIONS
		entitiesGroup.listen(terrainGroup);

		/// CAMERA
		simCam.targetZoom = 1.2;
		simCam.zoomMargin = 0.2;
		simCam.bgColor.setRGB(25, 21, 0);
	}

	function btn_generateCave_onClick(_) {
		var item = uiView.findComponent("btn_gen_cave", MenuItem); // need to specify component type if you want field completion after
		generateCaveTilemap();
	}

	function btn_clearWorld_onClick(_) {
		FlxEcho.clear();
	}

	function btn_placePlayer_onClick(_) {
		var item = uiView.findComponent("btn_place_player", MenuItem); // need to specify component type if you want field completion after
	}

	function link_website_onClick(_) {
		FlxG.openURL("https://gioele-bencivenga.github.io", "_blank");
	}

	function link_github_onClick(_) {
		FlxG.openURL("https://github.com/Gioele-Bencivenga/TilemapGen", "_blank");
	}

	function btn_play_pause_onClick(_) {
		var item = uiView.findComponent("btn_play_pause", Button);

		if (item.selected == true) {
			FlxEcho.updates = false;
			item.text = "play";
			item.icon = "assets/icons/icon_play_light.png";
		} else {
			FlxEcho.updates = true;
			item.text = "pause";
			item.icon = "assets/icons/icon_pause_light.png";
		}
	}

	function btn_zoom_onClick(_) {
		if (simCam.zoom >= 1)
			simCam.targetZoom = 0.5;
		else if (simCam.zoom <= 1) {
			simCam.targetZoom = 1.2;
		}
	}

	function btn_zoomPlus_onClick(_) {
		simCam.targetZoom += 0.15;
	}

	function btn_zoomMinus_onClick(_) {
		simCam.targetZoom -= 0.15;
	}

	function setupCameras() {
		simCam = new FlxZoomCamera(0, 0, FlxG.width, FlxG.height); // create the simulation camera
		simCam.zoomSpeed = 4;
		simCam.bgColor = FlxColor.BLACK; // empty space will be rendered as black

		FlxG.cameras.reset(simCam); // dump all current cameras and set the simulation camera as the main one
		// FlxCamera.defaultCameras = [simCam]; // strange stuff seems to happen with this

		uiCam = new FlxCamera(0, 0, FlxG.width, FlxG.height); // create the ui camera
		uiCam.bgColor = FlxColor.TRANSPARENT; // transparent so we see what's behind it
		FlxG.cameras.add(uiCam); // add it to the cameras list (simCam doesn't need because we set it as the main already)
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var zoomBtn = uiView.findComponent("btn_zoom", Button);
		zoomBtn.text = 'Zoom: ${Std.string(Std.int(HxFuncs.map(simCam.targetZoom, 0, 2, 0, 100)))}';

		if (FlxG.mouse.wheel != 0) {
			simCam.targetZoom += FlxMath.bound(FlxG.mouse.wheel, -0.04, 0.04);
		}
	}

	function generateCaveTilemap() {
		// reset the groups to fill them again
		emptyGroups([entitiesGroup, terrainGroup, collidableBodies]);

		gen = new Generator(50, 80); // we instantiate a generator that will generate a matrix of cells
		levelData = gen.generateCave();

		// First thing we want to do before creating any physics objects is init() our Echo world.
		FlxEcho.init({
			width: levelData[0].length * TILE_SIZE, // Make the size of your Echo world equal the size of your play field
			height: levelData.length * TILE_SIZE,
		});

		FlxEcho.reset_acceleration = true;

		// use Echo's TileMap utility to generate physics bodies for our Tilemap - making sure to ignore any tile with the index 2 or 3 so we can create objects out of them later
		var tiles = TileMap.generate(levelData.flatten2DArray(), TILE_SIZE, TILE_SIZE, levelData[0].length, levelData.length, 0, 0, 1, null, [2, 3]);
		for (tile in tiles) {
			var bounds = tile.bounds(); // Get the bounds of the generated physics body to create a Box sprite from it
			var wallTile = new Tile(bounds.min_x, bounds.min_y, bounds.width.floor(), bounds.height.floor(), FlxColor.fromRGB(230, 240, 245));
			bounds.put(); // Make sure to "put()" the bounds so that they can be reused later. This can really help with memory management!
			// wallTile.set_body(tile); // collisions don't work but feel like they should // attach the generated body to the FlxObject
			wallTile.add_body();
			wallTile.get_body().mass = 0; // tiles are immovable
			wallTile.add_to_group(terrainGroup); // Instead of `group.add(object)` we use `object.add_to_group(group)`
			wallTile.add_to_group(collidableBodies);
		}

		// step through level data and add entities
		for (j in 0...levelData.length) {
			for (i in 0...levelData[j].length) {
				switch (levelData[j][i]) {
					case 2:
						auto = new AutoEntity(i * TILE_SIZE, j * TILE_SIZE, Std.int(TILE_SIZE * 1.1), Std.int(TILE_SIZE * 0.7), FlxColor.YELLOW);
						auto.add_to_group(entitiesGroup);
						auto.add_to_group(collidableBodies);
					case 3:
						resource = new Supply(i * TILE_SIZE, j * TILE_SIZE, FlxG.random.int(1, 15), FlxColor.CYAN);
						resource.add_to_group(entitiesGroup);
						resource.add_to_group(collidableBodies);
					default:
						continue;
				}
			}
		}

		simCam.follow(auto, 0.2);
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
