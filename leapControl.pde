class leapControl {

  boolean oneFinger = true;
  boolean leap_trigger = false;
  float r_yStart;
  boolean isZoom;
  char zoomGlobe = 'D';
  int triGlitch_osc;
  float zoom = 370;

  void isOneFinger() {

    if (num_finger > 1) {
      oneFinger = false;
    }
    else {
      oneFinger = true;
    }
  }


  void handControl() {

    //--HANDS controlling the globe    
    if (hand_position.z >= 30) {
      // println("hand_position.y: "+hand_position.y);
      if (hand_position.x <= 1200.0 && hand_position.x >= 100.0) {

        if (!oneFinger) {               
          if (leap_trigger) {
            r_yStart = setRotationY(hand_position.x, r_mapY);
            leap_trigger = false;
          }

          //--Rotate the globe left-right 
          r_mapY = map(hand_position.x, 100.0, 1200.0, r_yStart, r_yStart+270);

          //--Rotate the globe up-down
          r_mapX = map(hand_roll, 38, -37, 40, -50);  

          //--Limit the rotationX range
          if (r_mapX < -50.0) {
            r_mapX = -50.0;
          }
          else if (r_mapX > 40.0) {
            r_mapX = 40.0;
          }

          //--Zoom in/out
          if (!isZoom) {
            if (hand_position.y > 600) {
              zoomGlobe = 'I';
              println("zoom in | " + hand_position.y);
              isZoom = true;
            }
            else if (hand_position.y < 90) {
              zoomGlobe = 'O';
              println("zoom out | " + hand_position.y);
              isZoom = true;
            }
          }
          else if (hand_position.y < 600 && hand_position.y > 90) {
            isZoom = false;
            // zoomGlobe = 'D';
          }
        }
        else {
          //--Use one finger to trigger the event  
          if (hand_position.y < 500 && hand_position.y > 120 && finger_velocity.y > 2500) {

            //--randomly trigger an event within the area.
            if (eqCords.drawRawLon.size()!= 0) {
              int index = int(random(eqCords.drawRawLon.size()));
              float triggerEvent = eqCords.drawRawLon.get(index);
              triGlitch_osc = eqData.destrRawLonList.indexOf(triggerEvent);
              println("trigger: "+finger_velocity.y+" | Lon: "+triggerEvent+" | Index: "+triGlitch_osc);
              osc.send();
            }
          }
        }
      }
      else {
        r_mapY += 0.05;
      }
    }
    else {
      leap_trigger = true;
      r_mapY += 0.05;
    }
  }	


  void zoomGlobe() {

    switch (zoomGlobe) {
    case 'I' :
      zoom = lerp(zoom, 470, 0.07);
      break; 

    case 'O' :
      zoom = lerp(zoom, 370, 0.07);
      break; 

    default :	          
      break;
    }
  }


  float setRotationY(float hand_positionX, float r_mapY_start) {
    r_yStart = r_mapY_start - ((270.0 / (1200.0-100.0)) * (hand_positionX-100.0));
    return r_yStart;
  }
}

