package states;

import flixel.FlxObject;
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
import tiles.Tile;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import echo.util.TileMap;
import flixel.input.mouse.FlxMouseEventManager;

using Math;
using echo.FlxEcho;
using hxmath.math.Vector2;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	/**
	 * Size of our tilemaps tiles.
	 */
	public static inline final TILE_SIZE:Int = 32;

	/**
	 * Camera follow speed that gets applied to the `lerp` argument in the `cam.follow()` function.
	 */
	public static inline final CAM_SPEED:Float = 0.2;

	/**
	 * Minimum zoom level reachable by the `simCam`.
	 */
	public static inline final CAM_MIN_ZOOM:Float = 0.3;

	/**
	 * Maximum zoom level reachable by the `simCam`.
	 */
	public static inline final CAM_MAX_ZOOM:Float = 1.5;

	/**
	 * Canvas is needed in order to `drawLine()` with `DebugLine`.
	 */
	public static var canvas:FlxSprite;

	/**
	 * Collision group containing the terrain tiles.
	 */
	public static var terrainCollGroup:FlxGroup;

	/**
	 * Collision group containing the entities.
	 */
	public static var entitiesCollGroup:FlxGroup;

	/**
	 * Group containing the entities, terrain and resources bodies.
	 * 
	 * This is used for ease of linecasting in the `agentsEntity.sense()` function.
	 */
	public static var collidableBodies:FlxGroup;

	/**
	 * Typed group of agents, mainly used by the camera right now.
	 */
	var agents:FlxTypedGroup<AutoEntity>;

	/**
	 * Simulation camera, the camera displaying the simulation.
	 */
	public static var simCam:FlxZoomCamera;

	/**
	 * UI camera, the camera displaying the interface indipendently from zoom.
	 */
	var uiCam:FlxCamera;

	/**
	 * Our UI using haxeui, this contains the list of components and all.
	 */
	var uiView:Component;

	/**
	 * Whether the simulation updates or not.
	 */
	var simUpdates(default, set):Bool = true;

	/**
	 * Automatically sets the value of `FlxEcho.updates`.
	 * @param newVal the new value `FlxEcho.updates` and `simUpdates`
	 */
	function set_simUpdates(newVal) {
		if (FlxEcho.instance != null)
			FlxEcho.updates = newVal;

		return simUpdates = newVal;
	}

	override function create() {
		setupCameras();

		setupUI();

		// create groups for collision handling and other stuff
		setupGroups();

		// generate world
		generateCaveTilemap();
	}

	function setupCameras() {
		/// SETUP
		var cam = FlxG.camera;
		simCam = new FlxZoomCamera(Std.int(cam.x), Std.int(cam.y), cam.width, cam.height, cam.zoom); // create the simulation camera
		FlxG.cameras.reset(simCam); // dump all current cameras and set the simulation camera as the main one

		uiCam = new FlxCamera(0, 0, FlxG.width, FlxG.height); // create the ui camera
		uiCam.bgColor = FlxColor.TRANSPARENT; // transparent bg so we see what's behind it
		FlxG.cameras.add(uiCam); // add it to the cameras list (simCam doesn't need because we set it as the main already)

		/// CUSTOMIZATION
		simCam.zoomSpeed = 4;
		simCam.targetZoom = 1.2;
		simCam.zoomMargin = 0.2;
		simCam.bgColor.setRGB(25, 21, 0);
	}

	/**
	 * Must call `setupCameras()` before this.
	 */
	function setupGroups() {
		/// ECHO COLLISION GROUPS
		terrainCollGroup = new FlxGroup();
		add(terrainCollGroup);
		terrainCollGroup.cameras = [simCam];
		entitiesCollGroup = new FlxGroup();
		add(entitiesCollGroup);
		entitiesCollGroup.cameras = [simCam];

		/// OTHER GROUPS
		collidableBodies = new FlxGroup();
		agents = new FlxTypedGroup<AutoEntity>(20);
	}

	/**
	 * Must call `setupCameras()` before this.
	 * 
	 * Generates the UI from the XML and associates functions to buttons.
	 */
	function setupUI() {
		Toolkit.init(); // needed before using any haxeui
		Toolkit.scale = 1; // temporary fix for scaling while ian fixes it
		Toolkit.theme = Theme.DARK;

		// build UI from XML
		uiView = ComponentMacros.buildComponent("assets/ui/main-view.xml");
		uiView.cameras = [uiCam]; // all of the ui components contained in uiView will be rendered by uiCam
		uiView.scrollFactor.set(0, 0); // and they won't scroll
		add(uiView);
		// wire functions to UI buttons
		uiView.findComponent("btn_gen_cave", MenuItem).onClick = btn_generateCave_onClick;
		uiView.findComponent("btn_clear_world", MenuItem).onClick = btn_clearWorld_onClick;
		uiView.findComponent("link_website", MenuItem).onClick = link_website_onClick;
		uiView.findComponent("link_github", MenuItem).onClick = link_github_onClick;
		uiView.findComponent("btn_play_pause", Button).onClick = btn_play_pause_onClick;
		uiView.findComponent("btn_zoom", Button).onClick = btn_zoom_onClick;
		uiView.findComponent("sld_zoom", Slider).onChange = sld_zoom_onChange;
		uiView.findComponent("lbl_version", Label).text = haxe.macro.Compiler.getDefine("PROJECT_VERSION");
	}

	function btn_generateCave_onClick(_) {
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
			simUpdates = false;
			item.text = "play";
			item.icon = "assets/icons/icon_play_light.png";
		} else {
			simUpdates = true;
			item.text = "pause";
			item.icon = "assets/icons/icon_pause_light.png";
		}
	}

	function btn_zoom_onClick(_) {
		var slider = uiView.findComponent("sld_zoom", Slider);
		
		if (slider.pos > 50)
			slider.pos = 30;
		else if (slider.pos <= 50) {
			slider.pos = 70;
		}
	}

	function sld_zoom_onChange(_) {
		var slider = uiView.findComponent("sld_zoom", Slider);
		simCam.targetZoom = HxFuncs.map(slider.pos, slider.min, slider.max, CAM_MIN_ZOOM, CAM_MAX_ZOOM);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0) {
			var slider = uiView.findComponent("sld_zoom", Slider);

			slider.pos += FlxMath.bound(FlxG.mouse.wheel, -7, 7);
		}
	}

	function generateCaveTilemap() {
		// reset the groups to fill them again
		emptyGroups([entitiesCollGroup, terrainCollGroup, collidableBodies], [agents]);

		var gen = new Generator(70, 110); // we instantiate a generator that will generate a matrix of cells
		var levelData:Array<Array<Int>> = gen.generateCave(2);

		// destroy previous world
		if (FlxEcho.instance != null)
			FlxEcho.clear();
		// create world before adding any physics objects
		FlxEcho.init({
			width: levelData[0].length * TILE_SIZE, // Make the size of your Echo world equal the size of your play field
			height: levelData.length * TILE_SIZE,
		});
		FlxEcho.reset_acceleration = true;
		FlxEcho.updates = simUpdates; // if the sim is paused pause the world too

		// generate physics bodies for our Tilemap from the levelData - making sure to ignore any tile with the index 2 or 3 so we can create objects out of them later
		var tiles = TileMap.generate(levelData.flatten2DArray(), TILE_SIZE, TILE_SIZE, levelData[0].length, levelData.length, 0, 0, 1, null, [2, 3]);
		for (tile in tiles) {
			var bounds = tile.bounds(); // Get the bounds of the generated physics body to create a Box sprite from it
			var wallTile = new Tile(bounds.min_x, bounds.min_y, bounds.width.floor(), bounds.height.floor(), FlxColor.fromRGB(230, 240, 245));
			bounds.put(); // put() the bounds so that they can be reused later. this can really help with memory management
			// wallTile.set_body(tile); // SHOULD attach the generated body to the FlxObject, doesn't see to work at the moment so using add_body instead
			wallTile.add_body().bodyType = 1; // sensors understand 1 = wall, 2 = entity, 3 = resource...
			wallTile.get_body().mass = 0; // tiles are immovable
			wallTile.add_to_group(terrainCollGroup); // Instead of `group.add(object)` we use `object.add_to_group(group)`
			wallTile.add_to_group(collidableBodies);
		}

		/// CANVAS
		if (canvas != null)
			canvas.kill(); // kill previous canvas
		canvas = new FlxSprite();
		// make new canvas as big as the world
		canvas.makeGraphic(Std.int(FlxEcho.instance.world.width), Std.int(FlxEcho.instance.world.height), FlxColor.TRANSPARENT, true);
		canvas.cameras = [simCam];
		add(canvas);

		/// ENTITIES
		for (j in 0...levelData.length) { // step through level data and add entities
			for (i in 0...levelData[j].length) {
				switch (levelData[j][i]) {
					case 2:
						var newAgent = new AutoEntity(i * TILE_SIZE, j * TILE_SIZE, Std.int(TILE_SIZE * 0.95), Std.int(TILE_SIZE * 0.7), FlxColor.YELLOW);
						agents.add(newAgent);
						newAgent.add_to_group(entitiesCollGroup);
						newAgent.add_to_group(collidableBodies);
						FlxMouseEventManager.add(newAgent, onAgentClick);
					case 3:
						var resource = new Supply(i * TILE_SIZE, j * TILE_SIZE, FlxG.random.int(1, 15), FlxColor.CYAN);
						resource.add_to_group(entitiesCollGroup);
						resource.add_to_group(collidableBodies);
					default:
						continue;
				}
			}
		}

		/// COLLISIONS
		entitiesCollGroup.listen(terrainCollGroup);
		entitiesCollGroup.listen(entitiesCollGroup);

		setCameraTargetAgent(agents.getFirstAlive());
	}

	/**
	 * Function that gets called when an agent is clicked.
	 * @param _agent the agent that was clicked (need to be `FlxSprite`)
	 */
	function onAgentClick(_agent:FlxSprite) {
		setCameraTargetAgent(_agent);
	}

	/**
	 * Updates the `simCam`'s target and flips the agent's flag.
	 * @param _target the new target we want the camera to follow
	 */
	function setCameraTargetAgent(_target:FlxObject) {
		if (simCam.target != null)
			cast(simCam.target, AutoEntity).isCamTarget = false;

		simCam.follow(_target, 0.2);
		cast(_target, AutoEntity).isCamTarget = true;
	}

	/**
	 * This function `kill()`s, `clear()`s, and then `revive()`s the groups passed in the array.
	 *
	 * It's mostly used when re generating the world.
	 *
	 * I think doing this resets the groups and it helped fix a bug with collision when regenerating the map.
	 * If you read this and you know that I could do this better please let me know!
	 *
	 * @param _groupsToEmpty an array containing the `FlxGroup`s that you want to reset.
	 * @param _typedGroups need to empty some `FlxTypedGroup<AutoEntity>` too?
	 */
	function emptyGroups(_groupsToEmpty:Array<FlxGroup>, ?_typedGroups:Array<FlxTypedGroup<AutoEntity>>) {
		for (group in _groupsToEmpty) {
			group.kill();
			group.clear();
			group.revive();
		}

		if (_typedGroups.length > 0) {
			for (group in _typedGroups) {
				group.kill();
				group.clear();
				group.revive();
			}
		}
	}
}
