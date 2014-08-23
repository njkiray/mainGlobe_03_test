import java.util.*;

class Set0 {
  long time;
  float mag;
  float depth;
  long previousTime;
  String monthURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson";
  char set0 = 'S';
  int j=0;
  long interval = 0;
  long difference;
  long prevTime;

  float resolution = 260; // how many points in the circle
  float rad = 150;
  float nswX = 1;
  float nswY = 1;

  float nswT = 0; // time passed
  float tChange = .03; // how quick time flies

  float nVal; // noise value
  float nInt = .05; // noise intensity
  float nAmp = .05; // noise amplitude
  float nAmpH;
  float magMax;
  float depthMax;

  void init() {
    //===8/4/2014===//
    noiseDetail(8);

    //    eqData = new eqData();
    //    eqData.init(monthURL);
    eqData.update(set0);
    //    e= eqData.magList.size();
    //    println(Collections.max(eqData.magList));

    //    smooth();
    previousTime = millis();
  }


  //============ Pulls the Quakes =============//
  void getQuakes() {
    //magnitude pulling

    if (millis() - previousTime >= interval ) {
      //resets j to 0 when it reaches end of array
      if (j >= eqData.magList.size()-1) {
        j = 0;
      }

      mag = eqData.magList.get(j);
      depth = eqData.depth0List.get(j);           
      time = eqData.timeList.get(j);
      if (j==0) {
        prevTime = eqData.timeList.get(j);
      }
      else {
        prevTime = eqData.timeList.get(j-1);
      }
      previousTime = millis();
      difference = prevTime-time; //backwards b/c of access in arrayList<>
      interval = difference/1000; //interval is time between quakes.
      //      println(j+" |interval: "+interval+" |depth: "+depth+" |mag: "+mag);
      j++;
    }
  }


  //============ Waveline Maker=================//
  void waveLine() {
    magMax = Collections.max(eqData.magList);
    depthMax = Collections.max(eqData.depthList);
    float adjMag = map(mag, 0, magMax, 0, 600);
    float adjDepth = map(depth, 0, depthMax, 600, 0);
    //    println(magMax + ", "+ depthMax);
    nInt = map(adjMag, 0, 600, 0.1, 50); // map magnitude to noise intensity
    nAmp = map(adjMag, 600, 0, 0.6, 1.0); // map depth to noise amplitude
    resolution = map(adjMag, 0, 600, 100, 500);

    beginShape();
    for (float a=0; a<=TWO_PI; a+=TWO_PI/resolution) {
      rad = map(adjDepth, 0, 600, 110, 210);
      nAmpH = map(adjDepth, 0, 600, 2.8, 1.0);
      // map noise value to match the amplitude
      nVal = map(noise( cos(a)*nInt+1, sin(a)*nInt+1, nswT ), 0.0, 1.0, nAmp, nAmpH); 

      nswX = cos(a)*rad *nVal;
      nswY = sin(a)*rad *nVal;

      vertex(nswX, nswY);
    }
    endShape(CLOSE);

    nswT += tChange;
  }

  //============ Display Info =============//
  void displayInfo() {
    fill(255);
    text("Location: " + eqData.placeList.get(j), width/2-70, height/2);
    text("Magnitude: " + eqData.magList.get(j), width/2-70, height/2+50);
  }

  //============ Change Wave Color =============//
  void changeWaveColor() {
    //change wave color
    noFill();
    strokeWeight(1.0);
    /* Old mag control of the wave color 
     if (mag <= 2) {
     stroke(75, 255, 60, 12*mag);
     }
     else if (mag > 2 && mag <= 4) {
     //stroke(map(mag, 0, 8, 0, 255), map(depth, 0, 4, 0, 255), 0, 80);
     stroke(255, 255, 0,30);
     }
     else if (mag > 4 && mag <=6) {
     stroke(255, 175, 35,35);
     } 
     else if (mag > 6 && mag <= 8) {
     stroke(255, 0, 50,128);
     }
     }
     */

    //new control of mag color
    //more purple / red = more earthquake magnitude
    stroke(map(mag,0,6,0,255), 0, 255, 77);
  }
}

