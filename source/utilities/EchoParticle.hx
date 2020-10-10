package utilities;

import flixel.util.helpers.FlxPointRangeBounds;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.util.helpers.FlxRange;
import flixel.util.FlxColor;
import hxmath.math.Vector2;
import flixel.FlxSprite;
import flixel.util.helpers.FlxRangeBounds;

using utilities.FlxEcho;

/**
 * Particle class inspired by FlxParticle and modified in order to have an easier
 * integration with austineast's Echo physics library
 */
class EchoParticle extends FlxSprite {
	/**
	 * The range of values for `color` over this particle's `lifespan`.
	 */
	public var colorRange(default, null):FlxRange<FlxColor>;

	/**
	 * The range of values for `alpha` over this particle's `lifespan`.
	 */
	public var alphaRange(default, null):FlxRange<Float>;

	/**
	 * The minimum possible angle at which this particle can be fired.
	 */
	public var minAngle(default, null):Int;

	/**
	 * The maximum possible angle at which this particle can be fired.
	 */
	public var maxAngle(default, null):Int;

	/**
	 * How long this particle lives before it disappears. Set to `0` to never `kill()` the particle automatically.
	 * NOTE: this is a maximum, not a minimum; the object could get recycled before its `lifespan` is up.
	 */
	public var lifespan(default, null):Float = 0;

	/**
	 * How long this particle has lived so far.
	 */
	public var age(default, null):Float = 0;

	/**
	 * What percentage progress this particle has made of its total life.
	 * Essentially just `(age / lifespan)` on a scale from `0` to `1`.
	 */
	public var lifePercent(default, null):Float = 0;

	/**
	 * The range of values for `scale` over this particle's `lifespan`.
	 */
	public var scaleRange(default, null):FlxRange<FlxPoint>;

	/**
	 * Keep the scale ratio of the particle. Uses the `x` values of `scale`.
	 */
	public var keepScaleRatio:Bool = false;

	/**
	 * The amount of change from the previous frame.
	 * I'd like to have a more detailed explanation for this but I don't quite get it myself.
	 */
	var delta:Float = 0;

	public function new() {
		super();
		exists = false;

		this.add_body({
			shape: {
				type: RECT,
				height: 0.6, // we want the body to be smaller than its graphics
				width: 0.6,
			},
			mass: 0.3,
			gravity_scale: 0,
		});

		makeGraphic(1, 1, FlxColor.WHITE);

		scaleRange = new FlxRange<FlxPoint>(FlxPoint.get(1, 1), FlxPoint.get(1, 1));
		colorRange = new FlxRange<FlxColor>(FlxColor.WHITE);
		alphaRange = new FlxRange<Float>(1, 1);
	}

	public function fire(options:FireOptions) {
		reset(options.position.x, options.position.y);
		this.get_body().active = true;

		if (options.position != null) {
			if (options.posDriftX != null) {
				options.position.x += FlxG.random.float(options.posDriftX.start, options.posDriftX.end);
			}
			if (options.posDriftY != null) {
				options.position.y += FlxG.random.float(options.posDriftY.start, options.posDriftY.end);
			}
			this.get_body().set_position(options.position.x, options.position.y);
		}

		if (options.velocity != null) {
			if (options.velocityDrift != null) {
				options.velocity.x += FlxG.random.float(options.velocityDrift.start, options.velocityDrift.end);
				options.velocity.y += FlxG.random.float(options.velocityDrift.start, options.velocityDrift.end);
			}

			this.get_body().velocity.set(options.velocity.x, options.velocity.y);
		}

		if (options.rotational_velocity != null) {
			this.get_body().rotational_velocity = FlxG.random.float(options.rotational_velocity.start, options.rotational_velocity.end);
		}

		if (options.acceleration != null)
			this.get_body().acceleration.set(options.acceleration.x, options.acceleration.y);

		if (options.bodyDrag != null) {
			if (options.dragDrift != null) {
				options.bodyDrag += FlxG.random.float(-options.dragDrift, options.dragDrift);
			}

			this.get_body().drag_length = options.bodyDrag;
		}

		if (options.lifespan != null) {
			if (options.lifespanDrift != null) {
				options.lifespan += FlxG.random.float(-options.lifespanDrift, options.lifespanDrift);
			}

			lifespan = options.lifespan;
		}

		if (options.animation != null)
			animation.play(options.animation, true);

		/// SCALE STUFF
		if (options.scale != null) {
			scaleRange.start.x = FlxG.random.float(options.scale.start.min.x, options.scale.start.max.x);
			scaleRange.start.y = keepScaleRatio ? scaleRange.start.x : FlxG.random.float(options.scale.start.min.y, options.scale.start.max.y);
			scaleRange.end.x = FlxG.random.float(options.scale.end.min.x, options.scale.end.max.x);
			scaleRange.end.y = keepScaleRatio ? scaleRange.end.x : FlxG.random.float(options.scale.end.min.y, options.scale.end.max.y);
			scaleRange.active = lifespan > 0 && !scaleRange.start.equals(scaleRange.end);
			scale.x = scaleRange.start.x;
			scale.y = scaleRange.start.y;
			this.get_body().scale_x = scale.x;
			this.get_body().scale_y = scale.y;
		} else {
			scaleRange.active = false;
		}

		/// COLOR STUFF
		if (options.color != null) {
			colorRange.start = FlxG.random.color(options.color.start.min, options.color.start.max);
			colorRange.end = FlxG.random.color(options.color.end.min, options.color.end.max);
			colorRange.active = lifespan > 0 && colorRange.start != colorRange.end;
			color = colorRange.start;
		} else {
			colorRange.active = false;
		}

		if (options.alpha != null) {
			alphaRange.start = FlxG.random.float(options.alpha.start.min, options.alpha.start.max);
			alphaRange.end = FlxG.random.float(options.alpha.end.min, options.alpha.end.max);
			alphaRange.active = lifespan > 0 && alphaRange.start != alphaRange.end;
			alpha = alphaRange.start;
		} else {
			alphaRange.active = false;
		}
	}

	override function update(elapsed:Float) {
		if (age < lifespan)
			age += elapsed;

		if (age >= lifespan && lifespan != 0) {
			this.get_body().active = false; // kill() doesn't deactivate bodies so we do it. we deactivate them instead of destroying because they get recycled
			kill();
		} else {
			delta = elapsed / lifespan;
			lifePercent = age / lifespan;

			if (scaleRange.active) {
				scale.x += (scaleRange.end.x - scaleRange.start.x) * delta;
				scale.y += (scaleRange.end.y - scaleRange.start.y) * delta;

				this.get_body().scale_x = scale.x;
				this.get_body().scale_y = scale.y;
			}

			if (colorRange.active) {
				color = FlxColor.interpolate(colorRange.start, colorRange.end, lifePercent);
			}

			if (alphaRange.active) {
				alpha += (alphaRange.end - alphaRange.start) * delta;
			}
		}

		super.update(elapsed);
	}

	override function reset(X:Float, Y:Float) {
		super.reset(X, Y);
		age = 0;

		// visible = true; // will I need this? maybe, so it's here just in case
	}

	override function destroy() {
		if (scaleRange != null) {
			scaleRange.start = FlxDestroyUtil.put(scaleRange.start);
			scaleRange.end = FlxDestroyUtil.put(scaleRange.end);
			scaleRange = null;
		}

		if (colorRange != null) {
			colorRange = null;
		}

		if (alphaRange != null) {
			alphaRange = null;
		}

		super.destroy();
	}
}

typedef FireOptions = {
	position:Vector2,
	?posDriftX:FlxRange<Float>,
	?posDriftY:FlxRange<Float>,

	?velocity:Vector2,
	?velocityDrift:FlxRange<Float>,
	?rotational_velocity:FlxRange<Float>,
	?acceleration:Vector2,
	?bodyDrag:Float,
	?minAngle:Int,
	?maxAngle:Int,
	?dragDrift:Float,
	?color:FlxRangeBounds<FlxColor>,
	?alpha:FlxRangeBounds<Float>,
	?animation:String,
	?lifespan:Float,
	?lifespanDrift:Float,
	?scale:FlxPointRangeBounds,
	?amount:Int,
}
