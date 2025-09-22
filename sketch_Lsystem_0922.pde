class Rule {
  char a;
  String b;

  Rule(char a_, String b_) {
    a = a_;
    b = b_; 
  }

  char getA() {
    return a;
  }

  String getB() {
    return b;
  }

}

class LSystem {

  String sentence;     // The sentence (a String)
  Rule[] ruleset;      // The ruleset (an array of Rule objects)
  int generation;      // Keeping track of the generation #

  // Construct an LSystem with a starting sentence and a ruleset
  LSystem(String axiom, Rule[] r) {
    sentence = axiom;
    ruleset = r;
    generation = 0;
  }

  // Generate the next generation
  void generate() {
    // An empty StringBuffer that we will fill
    StringBuffer nextgen = new StringBuffer();
    // For every character in the sentence
    for (int i = 0; i < sentence.length(); i++) {
      // What is the character
      char curr = sentence.charAt(i);
      // We will replace it with itself unless it matches one of our rules
      String replace = "" + curr;
      // Check every rule
      for (int j = 0; j < ruleset.length; j++) {
        char a = ruleset[j].getA();
        // if we match the Rule, get the replacement String out of the Rule
        if (a == curr) {
          replace = ruleset[j].getB();
          break; 
        }
      }
      // Append replacement String
      nextgen.append(replace);
    }
    // Replace sentence
    sentence = nextgen.toString();
    // Increment generation
    generation++;
  }

  String getSentence() {
    return sentence; 
  }

  int getGeneration() {
    return generation; 
  }


}

class Turtle {

  String todo;
  float len;
  float theta;

  Turtle(String s, float l, float t) {
    todo = s;
    len = l; 
    theta = t;
  } 

  void render() {
    stroke(0, 175);
    for (int i = 0; i < todo.length(); i++) {
      char c = todo.charAt(i);
      if (c == 'F') {
        line(0, 0, 0, len);
        translate(0, len);
      } else if (c=='E'){
        translate(0, len);
      } else if (c == 'R') {
        rotate(theta);
      } else if (c == '-') {
        rotate(-theta);
      } else if (c == '[') {
        pushMatrix();
      } else if (c == ']') {
        popMatrix();
      }
    }
  }

  void setLen(float l) {
    len = l;
  } 

  void changeLen(float percent) {
    len *= percent;
  }

  void setToDo(String s) {
    todo = s;
  }
}

import processing.sound.*;
class SoundTurtle {
  
  String todo;
  float len;
  SinOsc osc;
  float freq;
  float lastfreq;
  Env env;
  float amp = 0;
  int steps =1;
  
  SoundTurtle(String s, float l, SinOsc sin, Env e) {
    todo = s;
    len = l; 
    osc = sin;
    freq = 120;
    env = e;
  } 
  
  float midiToFreq(int note) {
    return (pow(2, ((note-69)/12.0))) * 440;
  }
  void playSound() {
    osc.stop();
    if (counter>2){
      steps = floor((float)todo.length()/30.0f);
    }
    print("counter is ", counter, "steps is ", steps, "\n");
    for (int i = 0; i < todo.length(); i+=steps) {
      char c = todo.charAt(i);
      if (c == 'F') {
        amp = 0.3;
      } else if (c=='E'){
        amp = 0.1;
      } else if (c == 'R') {
        freq = midiToFreq((int)random(60, 84));
      } else if (c == '[') {
        lastfreq = freq;
      } else if (c == ']') {
        freq = lastfreq;
      }
      
      if (c == 'F' || c == 'E' || c == 'R'){
        osc.freq(freq);
        osc.amp(amp);
        osc.play();
        delay(50);
      }
      
    }
    osc.stop();
  }

  void setLen(float l) {
    len = l;
  } 

  void changeLen(float percent) {
    len *= percent;
  }

  void setToDo(String s) {
    todo = s;
  }
}


LSystem lsys;
Turtle turtle;
SoundTurtle soundturtle;

void setup() {
  size(600, 600);
 
  Rule[] ruleset = new Rule[2];
  ruleset[0] = new Rule('F', "F[RFE]F");
  ruleset[1] = new Rule('E', "R[EF]EEE");
  lsys = new LSystem("F", ruleset);
  turtle = new Turtle(lsys.getSentence(), height, radians(90));
  soundturtle = new SoundTurtle(lsys.getSentence(), height, new SinOsc(this), new Env(this));
}

void draw() {
  background(200);  
  fill(0);
  //text("Click mouse to generate", 10, height-10);

  translate(width, height);
  rotate(+PI/2);
  turtle.render();

  soundturtle.playSound();
  noLoop();
}

int counter = 0;

void mousePressed() {
  if (counter < 11) {
    pushMatrix();
    lsys.generate();
    //println(lsys.getSentence());
    turtle.setToDo(lsys.getSentence());
    turtle.changeLen(0.5);
    popMatrix();
    redraw();
    soundturtle.setToDo(lsys.getSentence());
    counter++;
  }
}
