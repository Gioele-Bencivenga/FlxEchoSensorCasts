package utilities;

import utilities.EchoParticle;
import flixel.group.FlxGroup;

using utilities.FlxEcho;

/**
 * A particle emitter class.
 *
 * Modified to work with Echo physics following @austineast's directions.
 *
 * Re-implementation of zerolib's ParticleEmitter.hx for HaxeFlixel, without zerolib by @austineast
 * https://gist.github.com/AustinEast/97e23e8f157fc43e451a24107a886c65
 *
 * Originally written for zerolib by @01010111
 * https://github.com/01010111/zerolib-flixel/blob/master/zero/flixel/ec/ParticleEmitter.hx
 */
class EchoEmitter extends FlxTypedGroup<EchoParticle> {
	var new_particle:Void->EchoParticle;

	/**
	 * Creates a new particle emitter
	 * @param new_particle	a function that returns the desired Particle
	 */
	public function new(new_particle:Void->EchoParticle) {
		super();

		this.new_particle = new_particle;
	}

	/**
	 * Fires a particle with given options. If none are available, it will create a new particle using the function passed in new()
	 * @param options options relating to how the particles should look and behave
	 */
	public function fire(options:FireOptions) {
		for (i in 0...options.amount) {
			while (getFirstAvailable() == null) {
				new_particle().add_to_group(cast this);
			}

			getFirstAvailable().fire(options);
		}
	}
}
