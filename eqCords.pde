class eqCords {
    
  float lon;
  float lat;
  float rS = globeR;  // *r from the surface
  float rD;           // *r from the depth
  PVector drawPosS = new PVector(); // *position of the obj on surface
  PVector drawPosD = new PVector(); // *position of the obj inside the globe
  float centerLon;
  float centerLat;
  float r_mapY_b;
  int r_mapY_a;
  float destrRawLon;
  float destrRawLat;
  ArrayList<Float> drawSize = new ArrayList<Float>();
  ArrayList<Float> drawRawLon = new ArrayList<Float>();
  ArrayList<Float> drawRawLat = new ArrayList<Float>();
  int sizeIndex;
    
  public void update() {   
    rS = globeR;
    // *Generate the vector of the obj on the surface
    drawPosS = sphereToCart(lon, lat, rS);

    // *Generate the vector of the obj inside the globe
    drawPosD = sphereToCart(lon, lat, rD);
  }


  public void render(char dataFeeds) {
    pushMatrix();

      //--Convert Processing coordinate system to Geo coordinate system
      rotateZ(radians(-90));
      rotateY(radians(-90));

      pushMatrix();
        //--Move to the position of this item
        translate(drawPosS.x, drawPosS.y, drawPosS.z);
        rotateZ(radians(lon));
        rotateY(radians(lat));
        
        switch (dataFeeds) {

          case 'M' :           
          stroke(164,246,7, 0);
          fill(9,250,9,255);
          triangle(-1,0,1,0,0,1);
          break;

          case 'H' : 
          hint(ENABLE_DEPTH_TEST);
          pushMatrix();          
          rotateX(radians(180));
          rotateZ(radians(0));
          translate(0,0,-2);
          draw3D(0.5);
          popMatrix();
          break; 

          case 'D' :
          hint(ENABLE_DEPTH_TEST);
          pushMatrix();          
          rotateX(radians(180));
          rotateZ(radians(0));
          translate(0,0,-2);          
          
          r_mapY_b = (r_mapY+270)/360;
  
          if (r_mapY_b < 0) {
            r_mapY_a = -ceil(abs(r_mapY_b));
          }else{
            r_mapY_a = floor(abs(r_mapY_b));
          }
  
          centerLon = (-90 - r_mapY) + 360*r_mapY_a;
          centerLat = -r_mapX;
          
          if (destrRawLon > (centerLon-5) && destrRawLon < (centerLon+8) && destrRawLat > (centerLat-8) && destrRawLat < (centerLat+8)) {
            
            if (!drawRawLon.contains(destrRawLon)) {
              drawRawLon.add(destrRawLon);
              drawSize.add(1.5);
//              println(" RawLon: "+drawRawLon.get(drawRawLon.size()-1)+" | "+drawSize.size()+" objs");              
            }else if (destrRawLon > (centerLon-5) && destrRawLon < (centerLon+5)){
              sizeIndex = drawRawLon.indexOf(destrRawLon);
              drawSize.set(sizeIndex, lerp(drawSize.get(sizeIndex), 4.5, 1.4));         
              draw3D(drawSize.get(sizeIndex));                                         
            }else if (destrRawLon >= (centerLon+5)) {
              sizeIndex = drawRawLon.indexOf(destrRawLon);
              drawSize.set(sizeIndex, lerp(drawSize.get(sizeIndex), 1.5, 0.1));         
              draw3D(drawSize.get(sizeIndex));
            }
                        
          }else{

            if (drawRawLon.remove(destrRawLon)){            
              drawSize.remove(0);
            }
            draw3D(1.5);            

          }
          
          popMatrix();
          break; 
          
        }
    
      popMatrix();
      hint(DISABLE_DEPTH_TEST);
      stroke(253, 216, 41, 100);
      line(drawPosS.x, drawPosS.y, drawPosS.z, drawPosD.x, drawPosD.y, drawPosD.z);
      
    popMatrix();

  }
  
  
  //Spherical Coordinates
  PVector sphereToCart(float lon, float lat, float r) {
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
  
  void draw3D(float t) {
    stroke(255,119,255, 50);
    
    beginShape(TRIANGLES);
    
    fill(21,50,150,255);
    vertex(-t,-t,-t);
    vertex( t,-t,-t);
    vertex( 0, 0, t*2);
    
    fill(19,184,245,255);
    vertex( t,-t,-t);
    vertex( t, t,-t);
    vertex( 0, 0, t*2);
    
    fill(27,200,255,255);
    vertex( t, t,-t);
    vertex(-t, t,-t);
    vertex( 0, 0, t*2);
    
    fill(71,21,250,255);
    vertex(-t, t,-t);
    vertex(-t,-t,-t);
    vertex( 0, 0, t*2);
    
    endShape();
  }
}


