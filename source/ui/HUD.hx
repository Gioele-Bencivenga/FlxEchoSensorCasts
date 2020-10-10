package ui;

import entities.*;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class HUD extends FlxTypedGroup<FlxSprite> {
	var background:FlxSprite;
	var backgroundHeight:Int;
	var backgroundColor:FlxColor;

	var dividerHeight:Int;
	var dividerColor:FlxColor;

	var txtHealth:FlxText;

	var healthBar:FlxBar;
	var barWidth:Int;

	var player:Player;
	var actors:FlxTypedGroup<Thruster>;

	var nOfInfected:Int;

	var refreshTimer:FlxTimer;

	public function new(_player:Player /*, _actors:FlxTypedGroup<Mover>*/) {
		super();

		player = _player;
		// actors = _actors;

		backgroundHeight = 40;
		backgroundColor = FlxColor.ORANGE;
		dividerHeight = 2;
		dividerColor = FlxColor.YELLOW;

		background = new FlxSprite(0, FlxG.height - backgroundHeight);
		background.makeGraphic(FlxG.width, backgroundHeight, backgroundColor);
		FlxSpriteUtil.drawRect(background, 0, 0, FlxG.width, dividerHeight, dividerColor);
		add(background);

		/*
			barWidth = 400;
			healthBar = new FlxBar((FlxG.width / 2) - (barWidth / 2), background.y + 6, LEFT_TO_RIGHT, barWidth, backgroundHeight - 10, player, 'health', 0,
				player.MAX_HEALTH, false);
			healthBar.createColoredEmptyBar(FlxColor.fromRGB(0, 0, 0, 140), true, dividerColor);
			healthBar.createColoredFilledBar(FlxColor.fromRGB(50, 175, 0, 170), true, dividerColor);
			add(healthBar);
		 */

		txtHealth = new FlxText((FlxG.width / 2), background.y + 5, 0, "HP: 30 / 30", 25);
		// for long text txtHealth = new FlxText(0, background.y + 5, 0, "HP: 30 / 30", 25);
		txtHealth.setPosition(txtHealth.x, txtHealth.y);
		txtHealth.setBorderStyle(SHADOW, FlxColor.BLACK, 1);
		add(txtHealth);

		/*
			txtInfChance = new FlxText(0, background.y + 5, 0, "", 25);
			txtInfChance.setBorderStyle(SHADOW, FlxColor.BLACK, 1);
			add(txtInfChance);

			txtDeaths = new FlxText(FlxG.width, background.y + 5, 0, "INFECTED: 70, DEATHS: 200", 25);
			txtDeaths.setPosition(txtDeaths.x - txtDeaths.width, txtDeaths.y);
			txtDeaths.setBorderStyle(SHADOW, FlxColor.BLACK, 1);
			add(txtDeaths);

			coinIcon = new FlxSprite(0, 0, AssetPaths.coin__png);
			coinIcon.scale.set(6, 6);
			coinIcon.updateHitbox();
			coinIcon.setPosition(FlxG.width / 2 - (coinIcon.width * 1.5), coinIcon.y);
			add(coinIcon);
			txtCoins = new FlxText(coinIcon.x + coinIcon.width, coinIcon.y, 0, " ", 40);
			txtCoins.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 3);
			add(txtCoins);
		 */

		// we call the function on each element, by setting scrollFactor to 0,0 the elements won't scroll based on camera movements
		forEach(function(el:FlxSprite) {
			el.scrollFactor.set(0, 0);
		});

		/// HUD REFRESH TIMER
		refreshTimer = new FlxTimer();
		refreshTimer.start(0.1, function(_) {
			updateHUD();
		}, 0);
	}

	public function updateHUD() {
		txtHealth.text = 'x: ${} y: ${}';

		// txtDeaths.text = 'INFECTED: ${nOfInfected}, DEATHS: ${PlayState.deadCount}';

		// txtCoins.text = 'x: ${player.coinAmount}';
	}
}
