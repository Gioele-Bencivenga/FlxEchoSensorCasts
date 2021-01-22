// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Simple Perceptron Example
// See: http://en.wikipedia.org/wiki/Perceptron

// Perceptron Class

class Perceptron {
  float[] weights;  // Array of weights for inputs
  float c;          // learning constant

  // Perceptron is created with n weights and learning constant
  Perceptron(int n, float c_) {
    weights = new float[n];
    c = c_;
    // Start with random weights
    for (int i = 0; i < weights.length; i++) {
      weights[i] = random(0, 1);
    }
  }

  // Function to train the Perceptron
  // Weights are adjusted based on vehicle's error
  void train(PVector force, PVector error) {
    weights[0] += c*error.x*force.x;
    weights[0] += c*error.y*force.y;
    weights[0] = constrain(weights[0], 0, 1);
  }

  // Give me a steering result
  PVector feedforward(PVector force) {
    // Sum all values
    PVector sum = new PVector();
    for (int i = 0; i < weights.length; i++) {
      force.mult(weights[i]);
      sum.add(force);
    }
    return sum;
  }
}
