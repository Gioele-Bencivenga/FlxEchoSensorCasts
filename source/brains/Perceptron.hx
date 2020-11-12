package brains;

import flixel.FlxG;
import flixel.math.FlxRandom;

class Perceptron {
	/**
	 * The Perceptron's input weights.
	 *
	 * Cannot be set directly.
	 *
	 * Specify the number of weights when creating a new instance, actual weights value is initialized as random.
	 */
    public var weights(default, null):Array<Float>;
    
    /**
     * The rate at which the Perceptron learns.
     */
    public var learningRate(default, null):Float;

	public function new(_numOfWeights:Int) {
		// each weight is given a random value between -1 and 1
		weights = [for (i in 0..._numOfWeights) FlxG.random.float(-1, 1)];
	}

	/**
	 * This function enables the Perceptron to receive inputs and generate an output as an integer.
	 * @param _inputs the array of input weights the Perceptron receives
	 * @return 1 if the activation is positive, -1 if negative 
	 */
	public function feedForward(_inputs:Array<Float>):Int {
		var sum:Float = 0;

		for (i in 0...weights.length) {
			sum += _inputs[i] * weights[i];
		}

		return activate(sum);
	}

	/**
	 * The activation function.
	 * @param sum the value we want to check the function on
	 * @return 1 if positive, -1 if negative
	 */
	function activate(sum:Float):Int {
		if (sum > 0)
			return 1;
		else
			return -1;
	}
}
