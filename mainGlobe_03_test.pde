import de.voidplus.leapmotion.*;
import java.text.*;

int sDetail = 30;  // *Sphere resolution
float r_mapY = 0; // globe - rotation Y 
float r_mapX = 0; // globe - rotation X
float globeR = 80; // globe size
float globeRadius;
float earthRadius = 6371.0; // *The mean value of the distance from Earth's surface to its center.
int originalSize = 0;
long lastTime;
String monthURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson";
String hourURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
char month = 'M';
char hour = 'H';
boolean isHour = false;

PImage texMap;
PImage trees;
PImage cracks;
PImage back;
PImage glow;
PVector finger_velocity;
int num_finger;
float hand_roll;
PVector hand_position;
boolean isHands;
float rotateSet0;
long handsLastTime;

PFont font;
boolean isNew=false;
int maxCount=1;

LeapMotion leap;
leapControl leapC;
eqData eqData;
eqCords eqCords;
Earth earth;
Set0 set0;
OSC osc;

uiText uiText;

//=========================================

void setup() {

  size(1280, 720, P3D);
  if (frame != null) {
    frame.setResizable(true);
  }
  lastTime = millis();

  texMap = loadImage("kirayWorldMap2.png");
  trees = loadImage("trees.jpg");
  cracks = loadImage("kiray_earth.jpg");
  back = loadImage("back2.png");
  glow = loadImage("glow.png");
  earth = new Earth();
  earth.initializeSphere(sDetail);    

  eqData = new eqData();
  eqCords = new eqCords();

  //*Load the all_month data at the first time the program's running
  eqData.init(monthURL);
  eqData.update(month);
  originalSize = eqData.latList.size();

  set0 = new Set0();
  set0.init();

  println("count all: " + eqData.count);
  println("latList size: " + eqData.latList.size());

  leap = new LeapMotion(this);
  leapC = new leapControl();
  leapC.isZoom = false;

  osc = new OSC();
  osc.init();

  uiText=new uiText();
  font = createFont("HelveticaNeue-Medium-48.vlw", 16, true);
  textFont(font);
  textAlign(CENTER);

  background(0);
  smooth();
}


//===================================================

void draw() {
  //background circle clears only

  imageMode(CENTER);
  image(back, width/2, height/2, 440, 440);

  if (isNew==true) {
    //   dataFortext();
  }

  realTimeUpdate();  // *Update the data every one and half minute.

  globeRadius = 1;

  fill(0, 25);
  rect(-1, -1, width+1, height+1);


  hint(DISABLE_DEPTH_TEST);

  //--set 0 
  pushMatrix();
  set0.getQuakes();
  translate(639, 357, 50);
  //parameters: x,y,z
  rotate(rotateSet0, 0, 0, 500);
  rotateSet0+=0.4;
  scale(1.2);
  set0.changeWaveColor();
  //display a waveline according to the interval
  set0.waveLine(); 
  popMatrix();

  //main "front" of globe?

  pushMatrix();

  translate(640, 360, int(leapC.zoom));
  lights();

  pushMatrix();

  rotateX(radians(r_mapX));
  rotateY(radians(r_mapY));


  //-----------------------------//
  //create background sphere (trees)
  pushMatrix();

  scale(0.93);
  rotateY(radians(r_mapY*noise(1)));
  rotateX(radians(r_mapX*noise(1)));
 // renderGlobe(29, 255, 232, 255, cracks);
  hint(DISABLE_DEPTH_TEST);


  popMatrix();

  //--------------Main Globe----------------//
  pushMatrix();
  renderGlobe(255, 255, 255, 255, texMap);
  addEqEvent();      // *draw event objects.
  //Depth test globe
  hint(ENABLE_DEPTH_TEST);
  renderGlobe(150, 200, 255, 220, texMap);      



  popMatrix();
  popMatrix();
  popMatrix();


  //Leap Motion ==========
  isHands = leap.hasHands();
  // HANDS
  for (Hand hand : leap.getHands()) {
    hand_position    = hand.getStabilizedPosition();
    hand_roll        = hand.getRoll();
    num_finger       = hand.countFingers();

    leapC.isOneFinger();

    // FINGERS
    for (Finger finger : hand.getFingers()) {      
      finger_velocity   = finger.getVelocity();
    }

    //--HANDS controlling the globe    
    leapC.handControl();
    handsLastTime = millis();
  }

  leapC.zoomGlobe();

  if (!isHands) {     
    r_mapY += 0.2;
    if ( millis() - handsLastTime >= 5000 ) {
      leapC.zoomGlobe = 'O';
      leapC.zoomGlobe();
      handsLastTime = millis();
    }
  }
}



//---------------------------------------------
//                  Functions
//---------------------------------------------

void addEqEvent() {

  for (int i = eqData.countHour; i < eqData.latList.size(); i++) {
    setParameter(i);
    eqCords.render(month);
  }

  for (int i = 0; i < eqData.latList.size() - originalSize; i++) {
    setParameter(i);
    eqCords.render(hour);
  }

  for (int i = 0; i < 71; i++) {
    eqCords.lat = eqData.destrLatList.get(i);
    eqCords.lon = eqData.destrLonList.get(i);
    eqCords.rD = eqData.destrDepthList.get(i);
    eqCords.destrRawLon = eqData.destrRawLonList.get(i);
    eqCords.destrRawLat = eqData.destrRawLatList.get(i);
    eqCords.update();
    eqCords.render('D');
  }
}

void setParameter(int i) {
  eqCords.lat = eqData.latList.get(i);
  eqCords.lon = eqData.lonList.get(i);
  eqCords.rD = eqData.depthList.get(i);
  eqCords.update();
}



void realTimeUpdate() {
  //  *Update every one and half minute
  if ( millis() - lastTime >= 60000 ) {
    //  *Load all_hour data
    eqData.init(hourURL);
    eqData.update(hour);
    println( "all_hour data updated!" );

    pushMatrix();
    tint(255, 160);
    image(glow, width/2, height/2, 550, 550);

    popMatrix();

    isHour = true;

    lastTime = millis();
    isNew = true;
  }
}


void renderGlobe(int tintR, int tintG, int tintB, int tintAlpha, PImage image) {
  stroke(255, 0);
  //  tint(255,67);  // *Adjust transparency of the globe
  fill(0, 13, 5, 0);
  textureMode(IMAGE);  
  //*calls the img.
  //  tint(206,57);
  tint(tintR, tintG, tintB, tintAlpha);
  earth.texturedSphere(globeRadius, image);
}

void dataFortext() {

  int j;
  int count=eqData.countHour;
  if (count>4) {
    count=4;
  }
  if (eqData.countHour != 0) {
    for (j=0;j<count;j++) {
      //  uiText.time=eqData.timeList.get(j);
      //some unknow problem here
      uiText.title=eqData.placeList.get(j);
      uiText.update(eqData.magList.get(j), j );

      maxCount=count;
    }
  } 
  else {
    for (j=0;j<maxCount;j++) {
      //uiText.time=eqData.timeList.get(j);
      uiText.title=eqData.placeList.get(j);
      uiText.update(eqData.magList.get(j), j );
    }
  }
}


//======================= Leap Motion ========================

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
  // println("Leap Motion Exit");
}

