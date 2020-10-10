package;

import flixel.util.FlxColor;
import flixel.FlxG;
import states.PlayState;
import flixel.FlxGame;
import openfl.display.Sprite;

// ads
// import extension.admob.AdMob;
// import extension.admob.GravityMode;
class Main extends Sprite {
	public function new() {
		// first of all, decide if you want to display testing ads by calling enableTestingAds() method
		// note that if you decide to call enableTestingAds(), you must do that before calling INIT methods
		// AdMob.enableTestingAds();

		// if your app is for children and you want to enable the COPPA policy,
		// you need to call tagForChildDirectedTreatment(), before calling INIT.
		// AdMob.tagForChildDirectedTreatment();

		// If you want to get instertitial events (LOADING, LOADED, CLOSED, DISPLAYING, ETC), provide
		// some callback function for this.
		// AdMob.onInterstitialEvent = onInterstitialEvent;

		// then call init with Android and iOS banner IDs in the main method.
		// parameters are (bannerId:String, interstitialId:String, gravityMode:GravityMode).
		// if you don't have the bannerId and interstitialId, go to www.google.com/ads/admob to create them.
		// AdMob.initAndroid("ca-app-pub-7066316700255256/7405673228", "ca-app-pub-XXXXX123457", GravityMode.BOTTOM); // may also be GravityMode.TOP
		// AdMob.initIOS("ca-app-pub-XXXXX123458", "ca-app-pub-XXXXX123459", GravityMode.BOTTOM); // may also be GravityMode.TOP

		// NOTE: If your game allows screen rotation, you should call AdMob.onResize(); when rotation happens.

		// AdMob.showBanner();

		// ADMOB EXTENSION SEEMS TO BE DEAD FOR NOW, ASK COCOCORE HOW HE INCLUDED BANNER

		super();
		addChild(new FlxGame(1366, 768, PlayState, 1, 60, 60, false)); // set false to true to run in fullscreen
		addChild(new openfl.display.FPS(5, 5, FlxColor.WHITE));

		// we enable the system cursor instead of using the default since flixel's cursor is kind of laggy
		FlxG.mouse.useSystemCursor = true;
	}
}
