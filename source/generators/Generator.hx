package generators;

import flixel.FlxG;

/**
 * Generator containing some methods for generating `matrix`es of `Int`s.
 *
 * Check method descriptions for a more comprehensive explanation.
 */
class Generator {
	/**
	 * The number of tiles in width that the generated level will have.
	 */
	var levelWidth:Int;

	/**
	 * The number of tiles in height that the generated level will have.
	 */
	var levelHeight:Int;

	/**
	 * Instantiate a new generator, specifying the default width and height of the levels it will generate.
	 *
	 * Both can be overridden when generating a level thanks to optional arguments.
	 * @param _levelWidth the number of tiles/cells in width that the generated level will have.
	 * @param _levelHeight the number of tiles/cells in height that the generated level will have.
	 */
	public function new(_levelWidth:Int, _levelHeight:Int) {
		levelWidth = _levelWidth;
		levelHeight = _levelHeight;
	}

	/**
	 * Generates a random tilemap according to `emptyChance`.
	 * @param emptyChance the chance that a cell will be empty.
	 * @return a tilemap of type `Array<Array<Int>>` where each cell can assume values 0 to 3.
	 */
	public function generateRandom(emptyChance:Float, ?_levelWidth:Int, ?_levelHeight:Int):Array<Array<Int>> {
		if (_levelWidth != null)
			levelWidth = _levelWidth;
		if (_levelHeight != null)
			levelHeight = _levelHeight;

		// we fill the matrix with 1s according to the width and height
		var levelData:Array<Array<Int>> = [for (x in 0...levelWidth) [for (y in 0...levelHeight) 1]];

		for (x in 0...levelWidth) {
			for (y in 0...levelHeight) {
				if (FlxG.random.float(0, 1) < emptyChance) {
					levelData[x][y] = 0;
				}
			}
		}

		levelData = placePlayer(levelData);

		return levelData;
	}

	/**
	 * Places the player in one of the empty tiles of the level that's passed in.
	 * @param _levelData the level we want to place the player in.
	 * @return returns the modified `_levelData` that was passed in.
	 */
	function placePlayer(_levelData:Array<Array<Int>>):Array<Array<Int>> {
		var playerPlaced = false;

		for (x in 0...levelWidth) {
			for (y in 0...levelHeight) {
				if (!playerPlaced) {
					if (_levelData[x][y] == 0) {
						_levelData[x][y] = 3;
						playerPlaced = true;
					}
				}
			}
		}

		return _levelData;
	}

	function generateIsland(?_levelWidth:Int, ?_levelHeight:Int):Array<Array<Int>> {
		if (_levelWidth != null)
			levelWidth = _levelWidth;
		if (_levelHeight != null)
			levelHeight = _levelHeight;

		// we fill the matrix with 0s according to the width and height
		var levelData:Array<Array<Int>> = [for (x in 0...levelWidth) [for (y in 0...levelHeight) 0]];

		return levelData;
	}

	function generateCave(?_levelWidth:Int, ?_levelHeight:Int):Array<Array<Int>> {
		if (_levelWidth != null)
			levelWidth = _levelWidth;
		if (_levelHeight != null)
			levelHeight = _levelHeight;

		// we fill the matrix with 0s according to the width and height
		var levelData:Array<Array<Int>> = [for (x in 0...levelWidth) [for (y in 0...levelHeight) 0]];

		return levelData;
	}
}
