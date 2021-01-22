package brains;

import utilities.JoFuncs;
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
		learningRate = _learningRate;
		
		// each weight is given a random value between -1 and 1
		weights = [for (i in 0..._numOfWeights) FlxG.random.float(-1, 1)];
	}

	/**
	 * This function takes in an array of Vector2 and calculates something.
	 * @param _inputs the array of input weights the Perceptron receives
	 * @return the summed vector
	 */
	public function feedForward(_input:Vector2):Vector2 {
		var sum = new Vector2(0, 0);
		
		for (i in 0...weights.length) {
			_input.multiplyWith(weights[i]);
			sum.addWith(_input);
		}
		return sum;
	}

	public function train(_input:Vector2, _error:Vector2) {
		// Adjust all the weights according to the error and learning rate
			weights[0] += learningRate * _error.x * _input.x;
			weights[0] += learningRate * _error.y * _input.y;
			weights[0] = JoFuncs.constrain(weights[0], 0, 1);
	}
}
