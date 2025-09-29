interface ThicknessFunction {
  float get(int i);
}

int imageCount = 24;
PImage[] images = new PImage[imageCount];

float hop;
ArrayList<Spine> worm = new ArrayList<Spine>();
ArrayList<PVector> dir = new ArrayList<PVector>();
ArrayList<PVector> dest = new ArrayList<PVector>();
ArrayList<ThicknessFunction> thick = new ArrayList<ThicknessFunction>();
ArrayList<Integer> anchor = new ArrayList<Integer>();
color bkg;
float t;
int borderPhotoSize = 25; 




/////////////////////SETUP////////////////////////////
void setup() {
  size(1200, 800);
  
  // photo (1).jpg, ...
  for (int i=0; i < imageCount; i++){
    images[i] = loadImage("photo ("+(i+1)+").jpg");
  }
  
  generate();
}

void mouseClicked() {
  generate();
}

void generate() {
  // Reset state
  worm.clear();
  dir.clear();
  dest.clear();
  thick.clear();
  anchor.clear();
  
  hop = min(width, height) / 2.0;
  final float tapeWidth = min(width, height) / 60.0;
  ThicknessFunction thicknessFunc = (i) -> tapeWidth; 
  
  int n = 40;                               // segments per worm
  float separation = tapeWidth;
  float totalSize = n * separation;
  
  // One worm per image
  for (int i = 0; i < imageCount; i++) {
    PImage img = images[i];
    if (img == null) {
      println("Image " + (i+1) + " failed to load. Skipping.");
      continue;
    }
    img.loadPixels();
    
    color[] wormColors = new color[n];

    //Per-worm color: sampled along pixels
    float ratio = (float)img.pixels.length / n;
    for (int j = 0; j < n; j++) {
      int pixelIndex = floor(j * ratio);
      wormColors[j] = img.pixels[pixelIndex];
    }
    
    Spine newWorm = new Spine(n, separation, radians(random(10, 12)), wormColors);
    
    // start position/direction
    newWorm.translate(random(width * 0.25, width * 0.75 - totalSize), height / 2.0);
    worm.add(newWorm);

    anchor.add(floor(random(n)));
    dest.add(new PVector(random(width), random(height)));
    PVector newDir = new PVector(random(0.5, 1), 0);
    newDir.rotate(random(TWO_PI));
    dir.add(newDir);
    thick.add(thicknessFunc);
  }
  
  bkg = color(20);
  background(bkg);
}

void draw() {
  background(bkg);
  drawPhotoBorder();
  t = frameCount / 100.0;

  // Update & draw all worms
  for (int i = 0; i < worm.size(); i++) {
    Spine w = worm.get(i);
    
    w.draw(thick.get(i));

    // movement
    int currentAnchorIndex = anchor.get(i);
    PVector p = w.node.get(currentAnchorIndex);
    PVector currentDest = dest.get(i);

    float d = p.dist(currentDest);
    if (d < 4 || random(1) < 0.01) {
      int newAnchorIndex = floor(random(w.n));
      anchor.set(i, newAnchorIndex);
      p = w.node.get(newAnchorIndex);
      
      PVector delta = new PVector(hop, 0);
      delta.rotate(random(TWO_PI));
      
      float newx = constrain(p.x + delta.x, 0, width);
      float newy = constrain(p.y + delta.y, 0, height);
      dest.set(i, new PVector(newx, newy));
    }
    
    PVector currentDir = dir.get(i);
    PVector v = PVector.sub(dest.get(i), p);
    float ang = PVector.angleBetween(currentDir, v);
    
    currentDir.rotate(constrain(-ang, -PI / 90.0, PI / 90.0));
    
    PVector q = PVector.add(p, currentDir);
    w.setNode(currentAnchorIndex, q.x, q.y);
  }
}


class Spine {
  int n;
  float separation;
  float bendMax;
  ArrayList<PVector> node;
  color[] segmentColors;

  Spine(int _n, float _separation, float _bendMax, color[] _colors) {
    n = _n;
    separation = _separation;
    bendMax = _bendMax;
    segmentColors = _colors;
    
    node = new ArrayList<PVector>();
    for (int i = 0; i < n; i++) {
      node.add(new PVector(i * separation, 0));
    }
  }

  void draw(ThicknessFunction thickness) {
    ArrayList<PVector> left = new ArrayList<PVector>();
    ArrayList<PVector> right = new ArrayList<PVector>();
    
    for (int i = 0; i < n; i++) {
      PVector p = (i > 0) ? node.get(i - 1) : node.get(i);
      PVector q = node.get(i);
      PVector r = (i < n - 1) ? node.get(i + 1) : node.get(i);
      PVector v = PVector.sub(r, p);
      v.setMag(thickness.get(i));
      v.rotate(PI / 2.0);
      left.add(PVector.add(q, v));
      right.add(PVector.sub(q, v));
    }
    
    //outline
    stroke(0);
    strokeWeight(2);
    noFill();
    for (int i = 0; i < n - 1; i++) {
      beginShape(QUAD);
      vertex(left.get(i).x, left.get(i).y);
      vertex(right.get(i).x, right.get(i).y);
      vertex(right.get(i+1).x, right.get(i+1).y);
      vertex(left.get(i+1).x, left.get(i+1).y);
      endShape();
    }
    
    // fill
    noStroke();
    for (int i = 0; i < n - 1; i++) {
      fill(segmentColors[i]);
      beginShape(QUAD);
      vertex(left.get(i).x, left.get(i).y);
      vertex(right.get(i).x, right.get(i).y);
      vertex(right.get(i+1).x, right.get(i+1).y);
      vertex(left.get(i+1).x, left.get(i+1).y);
      endShape();
    }
  }

  void translate(float dx, float dy) {
    PVector v = new PVector(dx, dy);
    for (PVector p : node) {
      p.add(v);
    }
  }

  void relaxRight(int i, PVector u) {
    if (i + 1 < this.n) {
      PVector v = PVector.sub(this.node.get(i + 1), this.node.get(i));
      float ang = PVector.angleBetween(u, v);

      if (ang < -this.bendMax) v.rotate(-ang - this.bendMax);
      else if (ang > this.bendMax) v.rotate(-ang + this.bendMax);

      v.setMag(this.separation);
      this.node.set(i + 1, PVector.add(this.node.get(i), v));
      this.relaxRight(i + 1, v);
    }
  }

  void relaxLeft(int i, PVector u) {
    if (i > 0) {
      PVector v = PVector.sub(this.node.get(i - 1), this.node.get(i));
      float ang = PVector.angleBetween(u, v);
      
      if (ang < -this.bendMax) v.rotate(-ang - this.bendMax);
      else if (ang > this.bendMax) v.rotate(-ang + this.bendMax);

      v.setMag(this.separation);
      this.node.set(i - 1, PVector.add(this.node.get(i), v));
      this.relaxLeft(i - 1, v);
    }
  }
  
  void setNode(int i, float x, float y) {
    PVector u;
    if (i > 0) {
      if (i + 1 < n) {
        u = PVector.sub(node.get(i + 1), node.get(i - 1));
      } else {
        u = PVector.sub(node.get(i), node.get(i - 1));
      }
    } else {
      u = PVector.sub(node.get(i + 1), node.get(i));
    }
    this.node.set(i, new PVector(x, y));
    this.relaxRight(i, new PVector(u.x, u.y));
    this.relaxLeft(i, new PVector(-u.x, -u.y));
  }
}
void drawPhotoBorder() {
  if (imageCount == 0) return; 

  int imageIndex = 0; 

  // Top
  for (int x = 0; x < width; x += borderPhotoSize) {
    PImage img = images[imageIndex % imageCount];
    image(img, x, 0, borderPhotoSize, borderPhotoSize);
    imageIndex++;
  }

  // Bottom
  for (int x = 0; x < width; x += borderPhotoSize) {
    PImage img = images[imageIndex % imageCount];
    image(img, x, height - borderPhotoSize, borderPhotoSize, borderPhotoSize);
    imageIndex++;
  }

  // Left (corner x)
  for (int y = borderPhotoSize; y < height - borderPhotoSize; y += borderPhotoSize) {
    PImage img = images[imageIndex % imageCount];
    image(img, 0, y, borderPhotoSize, borderPhotoSize);
    imageIndex++;
  }

  // Right (corner x)
  for (int y = borderPhotoSize; y < height - borderPhotoSize; y += borderPhotoSize) {
    PImage img = images[imageIndex % imageCount];
    image(img, width - borderPhotoSize, y, borderPhotoSize, borderPhotoSize);
    imageIndex++;
  }
}
