package brains;

import hxmath.math.Vector2;
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

	/**
	 * Creates a new `Perceptron` instance with the specified weights initialized to random values between -1 and 1 inclusive.
	 * @param _numOfWeights the number of weights that the `Perceptron` should have
	 * @param learningRate 0.001 by default, it's the `Perceptron`'s learning rate
	 */
	public function new(_numOfWeights:Int, _learningRate = 0.001) {
		// each weight is given a random value between -1 and 1
		weights = [for (i in 0..._numOfWeights) FlxG.random.float(-1, 1)];

		learningRate = _learningRate;
	}

	/**
	 * This function takes in an array of Vector2 and calculates something.
	 * @param _inputs the array of input weights the Perceptron receives
	 * @return the summed vector
	 */
	public function feedForward(_inputs:Array<Vector2>):Vector2 {
		var sum = new Vector2(0, 0);

		for (i in 0...weights.length-1) {

			_inputs[i].multiplyWith(weights[i]);
			sum.addWith(_inputs[i]);
		}

		return sum;
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

	public function train(_inputs:Array<Vector2>, _error:Vector2) {
		// Adjust all the weights according to the error and learning rate
		for (i in 0...weights.length) {
			weights[i] += learningRate * _error.x * _inputs[i].x;
			weights[i] += learningRate * _error.y * _inputs[i].y;
		}
	}
}
