package supplies;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

using echo.FlxEcho;

/**
 * A Supply class that can be depleted via the `hurt()` function and that modifies its dimensions according to its quantity (represented by the `health` variable).
 */
class Supply extends FlxSprite {
	/**
	 * Whether `hurt()` can be called on the object or not.
	 *
	 * This gets flipped to `false` as soon as `hurt()` is called and gets flipped back to `true` once the damage feedback ends.
	 */
	var canBeHurt:Bool;

	public function new(_x:Float, _y:Float, _health:Float, _color:Int) {
		super(_x, _y);

		canBeHurt = true;
		health = _health;

		makeGraphic(Std.int(health * 3), Std.int(health * 3), _color);

		this.add_body({
			mass: 0.5,
			drag_length: 500,
			rotational_drag: 150
		}).bodyType = 3;
	}

	/**
	 * Depletes the supply's `health` by an amount, flips `canBeHurt` to `false` until the damage feedback ends.
	 * @param _damage the amount we want to deplete the supply by
	 */
	override function hurt(_damage:Float) {
		canBeHurt = false;
		super.hurt(_damage);
		updateSize();
	}

	/**
	 * Manages the object's reaction to the damage.
	 */
	function damageFeedback() {
		updateSize();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	/**
	 * Sets the `width` and `height` of the object according to its current `health`. Flips `canBeHurt` back to `true` when done.
	 */
	function updateSize() {
		var body = this.get_body();
		FlxTween.tween(body, {
			width: health * 3,
			height: health * 3
		}, 0.3, {
			ease: FlxEase.sineIn,
			onComplete: function(_) {
				canBeHurt = true;
			}
		});
	}

	/**
	 * Killing this object will also remove its physics body.
	 */
	override function kill() {
		super.kill();
		this.get_body().remove_body();
	}
}
