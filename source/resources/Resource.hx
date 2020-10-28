package resources;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

using utilities.FlxEcho;

/**
 * A resource class that can be depleted via the `hurt()` function and that modifies its dimensions according to its quantity (represented by the `health` variable).
 */
class Resource extends FlxSprite {
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
		updateSize();

		makeGraphic(Std.int(width), Std.int(height), _color);
	}

	/**
	 * Depletes the resource (`health`) by the specified amount, flips `canBeHurt` to `false` until the damage feedback ends.
	 * @param _damage the amount we want to deplete the resource by
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

	/**
	 * Sets the `width` and `height` of the object according to its current `health`. Flips `canBeHurt` back to `true` when done.
	 */
	function updateSize() {
		FlxTween.tween(this, {
			width: health * 5,
			height: health * 5
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
