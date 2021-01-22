// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// A Vehicle controlled by a Perceptron

Vehicle v;

PVector target;

void settings(){
size(1280, 720);
}
void setup() {
  // Create a list of targets
  updateTarget();
  
  // Create the Vehicle (it has to know about the number of targets
  // in order to configure its brain)
  v = new Vehicle(random(width), random(height));
}

// Make a random ArrayList of targets to steer towards
void updateTarget() {
  target = new PVector(mouseX, mouseY);
}

void draw() {
  background(255);
  
  // update the target
  updateTarget();

  // Draw the target
    noFill();
    stroke(0);
    strokeWeight(2);
    ellipse(target.x, target.y, 16, 16);
    line(target.x,target.y-16,target.x,target.y+16);
    line(target.x-16,target.y,target.x+16,target.y);
  
  // Update the Vehicle
  v.steer(target);
  v.update();
  v.display();
}
