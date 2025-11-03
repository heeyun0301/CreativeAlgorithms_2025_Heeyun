int N_NORMAL_PARTICLES = 1500;
int N_CORE_PARTICLES = 100;

ArrayList<Particle> particles = new ArrayList<Particle>();

float fadeAlpha = 40;

void setup() {
  size(800, 800);
  background(0);
  
  for (int i = 0; i < N_NORMAL_PARTICLES; i++) {
    particles.add(new NormalParticle());
  }

  for (int i = 0; i < N_CORE_PARTICLES; i++) {
    particles.add(new CoreParticle());
  }
}

void draw() {
  noStroke();
  fill(0, fadeAlpha);
  rect(0, 0, width, height);

  PVector center = new PVector(width / 2, height / 2);
  float mouseFactor = map(mouseX, 0, width, 0.5, 2.0);

  for (Particle p : particles) {
    p.applyForces(center, mouseFactor);
    p.update(mouseFactor);
    p.display();
    if (p.isDead()) {
      p.reset();
    }
  }
}

abstract class Particle {
  PVector pos;
  PVector vel;
  PVector acc;

  float particleSize;
  color particleColor;
  float lifespan;

  Particle() {
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  abstract void applyForces(PVector target, float mouseFactor);
  abstract void reset();

  void update(float mouseFactor) {
    vel.add(acc);
    vel.limit(10);
    pos.add(vel);
    acc.mult(0);
    lifespan -= 2.0 * mouseFactor;
  }

  void display() {
    color c = particleColor;
    float alpha = map(lifespan, 0, 100, 0, 200);
    stroke(red(c), green(c), blue(c), alpha);
    strokeWeight(particleSize);
    point(pos.x, pos.y);
  }

  boolean isDead() {
    return lifespan < 0;
  }
}

class NormalParticle extends Particle {
  NormalParticle() {
    super();
    reset();
  }

  void reset() {
    float angle = random(TWO_PI);
    float radius = random(width * 0.1, width * 0.5);
    pos = new PVector(width/2 + cos(angle) * radius, height/2 + sin(angle) * radius);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    lifespan = random(200, 400);
    particleSize = random(1, 3);
    float r = random(150, 255);
    float g = random(100, 200);
    float b = 255;
    particleColor = color(r, g, b, 200);
  }

  void applyForces(PVector target, float mouseFactor) {
    PVector forceAttract = PVector.sub(target, pos);
    float dist = forceAttract.mag();
    dist = constrain(dist, 5.0, 1000.0);
    forceAttract.normalize();
    forceAttract.mult(0.5 * mouseFactor);
    PVector forceRotate = new PVector(-forceAttract.y, forceAttract.x);
    float rotationStrength = 60.0 / dist;
    forceRotate.mult(rotationStrength * mouseFactor);
    PVector friction = vel.copy();
    friction.mult(-0.01);
    acc.add(forceAttract);
    acc.add(forceRotate);
    acc.add(friction);
  }
}

class CoreParticle extends Particle {
  CoreParticle() {
    super();
    reset();
  }
  
  void reset() {
    float angle = random(TWO_PI);
    float radius = random(0, width * 0.1);
    pos = new PVector(width/2 + cos(angle) * radius, height/2 + sin(angle) * radius);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    lifespan = random(100, 200);
    particleSize = random(1, 3);
    float r = 255;
    float g = random(150, 255);
    float b = random(100, 200);
    particleColor = color(r, g, b, 255);
  }

  void applyForces(PVector target, float mouseFactor) {
    PVector forceAttract = PVector.sub(target, pos);
    float dist = forceAttract.mag();
    dist = constrain(dist, 1.0, 1000.0);
    forceAttract.normalize();
    forceAttract.mult(1.0 * mouseFactor);
    PVector forceRotate = new PVector(-forceAttract.y, forceAttract.x);
    float rotationStrength = 5.0 / dist;
    forceRotate.mult(rotationStrength * mouseFactor);
    PVector friction = vel.copy();
    friction.mult(-0.05);
    acc.add(forceAttract);
    acc.add(forceRotate);
    acc.add(friction);
  }
}
