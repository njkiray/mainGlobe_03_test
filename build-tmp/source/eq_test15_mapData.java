import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import de.voidplus.leapmotion.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class eq_test15_mapData extends PApplet {




int sDetail = 30;  // *Sphere resolution
float r_mapY = 0; // globe - rotation Y 
float r_mapX = 0; // globe - rotation X
float globeR = 80; // globe size
float globeRadius;
float earthRadius = 6371.0f; // *The mean value of the distance from Earth's surface to its center.
int originalSize = 0;
long lastTime;
String monthURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
String hourURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
char month = 'M';
char hour = 'H';
boolean isHour = false;
PImage texMap;
PImage backdrop;
float zoom = 440;
char zoomGlobe = 'D';

boolean leap_trigger = false;
float r_yStart;
PVector finger_velocity;
boolean oneFinger = true;
boolean isZoom;
boolean isHands;


LeapMotion leap;
eqData eqData;
eqCords eqCords;
Earth earth;



//=========================================

public void setup() {

  size(1280,720,P3D);
  if (frame != null) {
    frame.setResizable(true);
  }
  lastTime = millis();
  
  texMap = loadImage("earthLights2.jpg");
  backdrop = loadImage("back.png");
  
  earth = new Earth();
  earth.initializeSphere(sDetail);
  
  eqCords = new eqCords();
  
  eqData = new eqData();
  
  //*Load the all_month data at the first time the program's running
  eqData.init(monthURL);
  eqData.update(month);
  originalSize = eqData.latList.size();

  println("count all: " + eqData.count);
  println("latList size: " + eqData.latList.size());
  // println("latList: " + eqData.latList);  

  smooth();
  
  leap = new LeapMotion(this);
  isZoom = false;
}


//===================================================

public void draw() {
  
  globeRadius = 1;
  background(0);
  back();
  
  pushMatrix();
    
    translate(640, 360, PApplet.parseInt(zoom)); 
    lights();
    
    pushMatrix();
      rotateX(radians(r_mapX));
      rotateY(radians(r_mapY));
      
      realTimeUpdate();  // *Update the data every one and half minute.
  
      pushMatrix();
        noFill();
        rotateX(radians(90));
        stroke(208,208,184, 175);
        ellipse(0,0,159,159);
      popMatrix();
      
      hint(DISABLE_DEPTH_TEST);
      renderGlobe(135, 62);

      addEqEvent();      // *draw event objects.
      
      hint(ENABLE_DEPTH_TEST);
      renderGlobe(206, 43);      
      
    popMatrix();
    
  popMatrix();



  //Leap Motion ==========
  isHands = leap.hasHands();
  // HANDS
  for(Hand hand : leap.getHands()){
    PVector hand_position    = hand.getStabilizedPosition();
    float   hand_roll        = hand.getRoll();
    float   hand_pitch       = hand.getPitch();
    float   hand_yaw         = hand.getYaw();
    float   hand_time        = hand.getTimeVisible();
    int     num_finger       = hand.countFingers();
          
       
    if(num_finger > 1) {
      oneFinger = false;
    }else{
      oneFinger = true;
    }
       
    // FINGERS
    for(Finger finger : hand.getFingers()){      
      finger_velocity   = finger.getVelocity();
    }
  
    //--HANDS controlling the globe
    
    if (hand_position.z >= 30) {
      // println("hand_position.y: "+hand_position.y);
      if (hand_position.x <= 1200.0f && hand_position.x >= 100.0f) {

        if(!oneFinger){               
            if (leap_trigger) {
               r_yStart = setRotationY(hand_position.x, r_mapY);
               leap_trigger = false;
            }
            
            //--Rotate the globe left-right 
            r_mapY = map(hand_position.x, 100.0f, 1200.0f, r_yStart, r_yStart+270);
          
            //--Rotate the globe up-down
            r_mapX = map(hand_roll, 38, -40, 35, -45);  
            
            //--Limit the rotationX range
            if (r_mapX < -45.0f) {
              r_mapX = -45.0f;
            }else if (r_mapX > 35) {
              r_mapX = 35;
            }
            
            //--Zoom in/out
            if (!isZoom) {
              if (hand_position.y > 600) {
                zoomGlobe = 'I';
                println("zoom in | " + hand_position.y);
                isZoom = true;
              }else if (hand_position.y < 90) {
                zoomGlobe = 'O';
                println("zoom out | " + hand_position.y);
                isZoom = true;
              }              
            }else if (hand_position.y < 600 && hand_position.y > 90) {
              isZoom = false;
              // zoomGlobe = 'D';
            } 
            
        }else{
            //--Use one finger to trigger the event  
            if (hand_position.y < 500 && hand_position.y > 120 && finger_velocity.y > 2000) {
              println("trigger | "+ finger_velocity.y);
            }
        }        
           
      }else {
        r_mapY += 0.05f;
      } 

    }else{
      leap_trigger = true;
      r_mapY += 0.05f;        
    }
    
    

  }

  switch (zoomGlobe) {
      case 'I' :
        zoom = lerp(zoom, 478, 0.07f);
        break; 

      case 'O' :
         zoom = lerp(zoom, 440, 0.07f);
        break; 

      default :
           
         break;     
  }

  if (!isHands){     
    r_mapY += 0.05f;
  }

}



//---------------------------------------------
//                  Functions
//---------------------------------------------

public void addEqEvent() {

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
      eqCords.update();
      eqCords.render('D');
  }
}

public void setParameter(int i){
    eqCords.lat = eqData.latList.get(i);
    eqCords.lon = eqData.lonList.get(i);
    eqCords.rD = eqData.depthList.get(i);
    eqCords.update();
}



public void realTimeUpdate() {
  //  *Update every one and half minute
  if ( millis() - lastTime >= 60000 ) {
    //  *Load all_hour data
    eqData.init(hourURL);
    eqData.update(hour);
    println( "all_hour data updated!" );
    isHour = true;
    lastTime = millis();
  }
}


public void renderGlobe(int tintScale, int tintAlpha) {
  stroke(255,0);
  //  tint(255,67);  // *Adjust transparency of the globe
  fill(255,255,255,0);
  textureMode(IMAGE);  
  //*calls the img.
  tint(tintScale, tintAlpha);
  earth.texturedSphere(globeRadius, texMap);
  
  //  tint(206,57);
  //  earth.texturedSphere(globeRadius, texMap);
}


public void back() {
  pushMatrix();
  translate(640,335,180);
  scale(0.8f);
  fill(255,252,252,255);
  tint(255,253);
  imageMode(CENTER);
  image(backdrop,0,0);
  popMatrix();
}

//======================= Leap Motion ========================

public float setRotationY(float hand_positionX, float r_mapY_start) {
  r_yStart = r_mapY_start - ((270.0f / (1200.0f-100.0f)) * (hand_positionX-100.0f));
  return r_yStart;
}


public void leapOnInit(){
  // println("Leap Motion Init");
}
public void leapOnConnect(){
  // println("Leap Motion Connect");
}
public void leapOnFrame(){
  // println("Leap Motion Frame");
}
public void leapOnDisconnect(){
  // println("Leap Motion Disconnect");
}
public void leapOnExit(){
  // println("Leap Motion Exit");
}
class Earth {
  
  float[] cx, cz, sphereX, sphereY, sphereZ;
  float sinLUT[];
  float cosLUT[];
  float SINCOS_PRECISION = 0.5f;
  int SINCOS_LENGTH = PApplet.parseInt(360.0f / SINCOS_PRECISION);

  public void initializeSphere(int res)
  {
    sinLUT = new float[SINCOS_LENGTH];
    cosLUT = new float[SINCOS_LENGTH];
  
    for (int i = 0; i < SINCOS_LENGTH; i++) {
      sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
      cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
    }
  
    float delta = (float)SINCOS_LENGTH/res;
    float[] cx = new float[res];
    float[] cz = new float[res];
  
    // Calc unit circle in XZ plane
    for (int i = 0; i < res; i++) {
      cx[i] = -cosLUT[(int) (i*delta) % SINCOS_LENGTH];
      cz[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
    }
  
    // Computing vertexlist vertexlist starts at south pole
    int vertCount = res * (res-1) + 2;
    int currVert = 0;
  
    // Re-init arrays to store vertices
    sphereX = new float[vertCount];
    sphereY = new float[vertCount];
    sphereZ = new float[vertCount];
    float angle_step = (SINCOS_LENGTH*0.5f)/res;
    float angle = angle_step;
  
    // Step along Y axis
    for (int i = 1; i < res; i++) {
      float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
      float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
      for (int j = 0; j < res; j++) {
        sphereX[currVert] = cx[j] * curradius;
        sphereY[currVert] = currY;
        sphereZ[currVert++] = cz[j] * curradius;
      }
      angle += angle_step;
    }
//    sDetail = res;
  }


    // Generic routine to draw textured sphere
  public void texturedSphere(float r, PImage t) {
    int v1, v11, v2;
    r = (r + 240 ) * 0.33f;
//    tint(255, 48);
    beginShape(TRIANGLE_STRIP);
    texture(t);
    float iu=(float)(t.width-1)/(sDetail);
    float iv=(float)(t.height-1)/(sDetail);
    float u=0, v=iv;
    for (int i = 0; i < sDetail; i++) {
      vertex(0, -r, 0, u, 0);
      vertex(sphereX[i]*r, sphereY[i]*r, sphereZ[i]*r, u, v);
      u+=iu;
    }
    vertex(0, -r, 0, u, 0);
    vertex(sphereX[0]*r, sphereY[0]*r, sphereZ[0]*r, u, v);
    endShape();   
  
    // Middle rings
    int voff = 0;
    for (int i = 2; i < sDetail; i++) {
      v1=v11=voff;
      voff += sDetail;
      v2=voff;
      u=0;
//      tint(255, 255);
      beginShape(TRIANGLE_STRIP);
      texture(t);
      for (int j = 0; j < sDetail; j++) {
        vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1++]*r, u, v);
        vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2++]*r, u, v+iv);
        u+=iu;
      }
  
      // Close each ring
      v1=v11;
      v2=voff;
      vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1]*r, u, v);
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v+iv);
      endShape();
      v+=iv;
    }
    u=0;
  
    // Add the northern cap
//    tint(255, 131);
    beginShape(TRIANGLE_STRIP);
    texture(t);
    for (int i = 0; i < sDetail; i++) {
      v2 = voff + i;
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v);
      vertex(0, r, 0, u, v+iv);    
      u+=iu;
    }
    vertex(sphereX[voff]*r, sphereY[voff]*r, sphereZ[voff]*r, u, v);
    endShape();
  }

}
class eqCords {
  
  //Spherical Coordinates
//  float theta;
//  float phi;
  float lon;
  float lat;
  float rS = globeR;  // *r from the surface
  float rD;           // *r from the depth
  PVector drawPosS = new PVector(); // *position of the obj on surface
  PVector drawPosD = new PVector(); // *position of the obj inside the globe

  
  public void update() {   
    rS = globeR;
    // *Generate the vector of the obj on the surface
    drawPosS = sphereToCart(lon, lat, rS);
    // *Generate the vector of the obj inside the globe
    drawPosD = sphereToCart(lon, lat, rD);
  }


  public void render(char dataFeeds) {
    pushMatrix();

  //  *Convert Processing coordinate system to Geo coordinate system
      rotateZ(radians(-90));
      rotateY(radians(-90));

      pushMatrix();
    //  *Move to the position of this item
        translate(drawPosS.x, drawPosS.y, drawPosS.z);
        rotateZ(radians(lon));
        rotateY(radians(lat));
        
        switch (dataFeeds) {

          case 'M' : 
//          hint(ENABLE_DEPTH_TEST);          
          stroke(164,246,7, 0);
          fill(9,250,9,255);
          triangle(-1,0,0,-1,0,1);
          break;

          case 'H' : 
          hint(ENABLE_DEPTH_TEST);
          pushMatrix();          
          rotateX(radians(180));
          rotateZ(radians(0));
          translate(0,0,-2);
          draw3D(0.5f);
          popMatrix();
          break; 

          case 'D' :
          hint(ENABLE_DEPTH_TEST);
          pushMatrix();          
          rotateX(radians(180));
          rotateZ(radians(0));
          translate(0,0,-2);
          draw3D(1.5f);
          popMatrix();
          break; 
          
        }
    
      popMatrix();
      hint(DISABLE_DEPTH_TEST);
      stroke(253, 216, 41, 123);
      line(drawPosS.x, drawPosS.y, drawPosS.z, drawPosD.x, drawPosD.y, drawPosD.z);
      
    popMatrix();
//    hint(DISABLE_DEPTH_TEST);
  }
  
  
  
  public PVector sphereToCart(float lon, float lat, float r) {
    PVector v = new PVector();
    //  *Degrees to radians
    float theta = ((lat)/180) * PI ;
    float phi = ((lon)/180) * PI ;
 
    //  *Convert spherical coordinates into Cartesian coordinates
    v.x = cos(phi) * sin(theta) * r;
    v.y = sin(phi) * sin(theta) * r;
    v.z = cos(theta) * r;
    
    return(v);
  }
  
  
  
  public void draw3D(float t) {
    stroke(88,88,88, 0);
    
    beginShape(TRIANGLES);
    
    fill(194,50,21,252);
    vertex(-t,-t,-t);
    vertex( t,-t,-t);
    vertex( 0, 0, t*2);
    
    fill(245,88,19,255);
    vertex( t,-t,-t);
    vertex( t, t,-t);
    vertex( 0, 0, t*2);
    
    fill(241,107,17,254);
    vertex( t, t,-t);
    vertex(-t, t,-t);
    vertex( 0, 0, t*2);
    
    fill(234,21,21,251);
    vertex(-t, t,-t);
    vertex(-t,-t,-t);
    vertex( 0, 0, t*2);
    
    endShape();
  }
}


class eqData {

  JSONObject eqEvents;
  JSONObject metadata;
  JSONArray features;
  JSONObject objFeatures;
  JSONObject properties;
  JSONObject geometry;
  JSONArray coordinates;

  int count;
  int countFilter;
  int countHour;
  int newEvent;
  float mag;
  float longitude;
  float latitude;
  float depth;
  long time;
  String place;
  
  float mapLong;
  float mapLat;
  float mapDepth;
  
  Table destrTable;
  TableRow destrRow;
  float destrLon;
  float destrLat;
  float destrDepth;

  ArrayList<Float> latList = new ArrayList<Float>();
  ArrayList<Float> lonList = new ArrayList<Float>();
  ArrayList<Float> depthList = new ArrayList<Float>();
  ArrayList<Float> magList = new ArrayList<Float>();
  ArrayList<Long> timeList = new ArrayList<Long>();
  
  ArrayList<Float> destrLonList = new ArrayList<Float>();
  ArrayList<Float> destrLatList = new ArrayList<Float>();
  ArrayList<Float> destrDepthList = new ArrayList<Float>();
  
  public void init(String URL) {
    eqEvents = loadJSONObject(URL);
    metadata = eqEvents.getJSONObject("metadata");
    count = metadata.getInt("count");
    features = eqEvents.getJSONArray("features");
    
    destrTable = loadTable("destruction_data.csv", "header");
    destrData();
//    println(destrLonList);
//    println(destrLatList);
//    println(destrDepthList);
  }

  public void update(char dataFeeds) {

      countFilter = 0;
      countHour = 0;

      for (int i=0; i<count; i++) {
        objFeatures = features.getJSONObject(i);
        properties = objFeatures.getJSONObject("properties");
          if(properties.isNull("mag")==true){
            properties.setInt("mag",0);
          }
          mag = properties.getFloat("mag");          
          place = properties.getString("place");
        geometry = objFeatures.getJSONObject("geometry");
          coordinates = geometry.getJSONArray("coordinates");
            longitude = coordinates.getFloat(0);
            latitude = coordinates.getFloat(1);
            depth = coordinates.getFloat(2);
            
        // *Adjust the offset between the actual coordinates and the world map image.
        mapLong = map(longitude, -180.0f, 180.0f, -90.0f, 270.0f);
        mapLat = map(latitude,-90.0f,90.0f,0.0f,180.0f);
        mapDepth = globeR - (globeR*depth/earthRadius);
          
          switch(dataFeeds) {
            
            // *For all_month data (only read once)
            case 'M':
              // *filter out the events with mag <= 2.5               
              if (mag >= 2.5f) {
                latList.add(countFilter,mapLat);
                lonList.add(countFilter,mapLong);
                depthList.add(countFilter,mapDepth);
                countFilter++;  
                // println(countFilter);            
              }
              break;
              
            // *For all_hour data (checking every other minute)
            case 'H':                          
              // *Only add new data. Skip repeated events.              
              
              if (!latList.contains(mapLat)) {
                // newEvent = latList.size();
                latList.add(0,mapLat);
                lonList.add(0,mapLong);
                depthList.add(0,mapDepth);
                countHour++;
              }
              println("List Size: " + latList.size() + "  |  Count: " + countHour + "  |  Original Size: " + originalSize);
              // println(latList);
              break;
          }
          
        //println(mag + "," + place + "," + "(" + longitude+ ","+latitude+ ","+depth + ")");
        
      }
  }
  
  
  public void destrData() {
  
    float mapLong;
    float mapLat;
    float mapDepth;
    
    for (int i=0; i<71; i++) {
      destrRow = destrTable.getRow(i);
      destrLon = PApplet.parseFloat(destrRow.getString("Longitude"));
      destrLat = PApplet.parseFloat(destrRow.getString("Latitude"));
      destrDepth = PApplet.parseFloat(destrRow.getString("Depth"));
      mapLong = map(destrLon, -180.0f, 180.0f, -90.0f, 270.0f);
      mapLat = map(destrLat,-90.0f,90.0f,0.0f,180.0f);
      mapDepth = globeR - (globeR*destrDepth/earthRadius);
      
      destrLonList.add(0,mapLong);
      destrLatList.add(0,mapLat);
      destrDepthList.add(0,mapDepth);
    }

  }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "eq_test15_mapData" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
