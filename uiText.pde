class uiText {
  // float lon;
  // float lat;
  // float mag;
  // float rD;   
  //long time;
  String title;
  // String place;
  String finalText;
  float r=300;
  int direct;
  String finalText1;
  Table table;
  float killed, injured, homeless, destroyed, damaged, allPeople, allBuilding, levelNumber;
  String eventName, country, date, time1, level;
  int eventNumber=0;
  int switchNum=0;
  void update(float mag, int range) {

    pushMatrix();
    translate(width/2, height/2, 50);
    fill(255);
    if (switchNum==1) {

      for (int i=0;i<4;i++) {
        /*     int direct1;
         if (i >0 && (i+1) %2 == 0) {
         direct1=-1;
         } else {
         direct1=1;
         }
         */
        rotateZ(TWO_PI/360*frameCount/10+TWO_PI/360*i*45/2);
        textFortable(i);
      }
    } 
    else {
      if (range >0 && (range+1) %2 == 0) {
        direct=-1;
      } 
      else {
        direct=1;
      }
      rotateZ(TWO_PI/360*frameCount/(5-mag)*direct+TWO_PI/360*range*45);
      putIncircle(range);
    }
    popMatrix();
  }

  void putIncircle(int ran) {
    dealText();
    String message=finalText;
    r=300+(ran-1)*20;
    // We must keep track of our position along the curve
    float arclength = 0;
    // For every box

    for (int i = 0; i < message.length(); i ++ ) {
      // The character and its width
      char currentChar = message.charAt(message.length()-i-1);
      // Instead of a constant width, we check the width of each character.
      float w = textWidth(currentChar); 
      // Each box is centered so we move half the width
      arclength += w/2;
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = PI + arclength / r;
      pushMatrix();
      // Polar to Cartesian conversion allows us to find the point along the curve. See Chapter 13 for a review of this concept.
      translate(r*cos(theta), r*sin(theta), 0); 
      // Rotate the box (rotation is offset by 90 degrees)
      rotate(theta + PI/2); 
      // Display the character
      pushMatrix();

      rotateY(PI);
      rotateX(PI);
      text(currentChar, 0, 0);
      popMatrix();
      popMatrix();

      // Move halfway again
      arclength += w/2;
    }
  }

  void dealText() {
    //dealwithtime
    //something wrong here!!!
    //Long time1= Long.parseLong(Long.toOctalString(time));
    //date = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new java.util.Date (time*1000L));
    //String finalTime= "Time: "+date;
    //dealwithplace
    //   String[] placeList=split(place, ",");
    //   String finalPlace= "Place: "+placeList[1];
    //dealwithtitle
    String[] titleList=split(title, "-");
    String[] titleList1=split(titleList[1], ",");
    String finalTitle=  titleList[0]+" / "+titleList1[0]+"  / "+titleList1[1];
    //dealwithothers
    //   String finalLon="Longitude: "+lon;
    //   String finalLat="Latitude: "+lat;
    //   String finalDepth="Depth: "+rD;
    //  String finalMag="Magnitude :"+mag;
    finalText=finalTitle;
  }

  void textFortable(int ran) {
    dealTable(ran);
    String message=finalText1;
    r=300+(ran-1)*20;

    float arclength = 0;
    for (int i = 0; i < message.length(); i ++ ) {
      // The character and its width
      char currentChar = message.charAt(message.length()-i-1);
      // Instead of a constant width, we check the width of each character.
      float w = textWidth(currentChar); 
      // Each box is centered so we move half the width
      arclength += w/2;
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = PI + arclength / r;
      pushMatrix();
      // Polar to Cartesian conversion allows us to find the point along the curve. See Chapter 13 for a review of this concept.
      translate(r*cos(theta), r*sin(theta), 0); 
      // Rotate the box (rotation is offset by 90 degrees)
      rotate(theta + PI/2); 
      // Display the character
      pushMatrix();

      rotateY(PI);
      rotateX(PI);
      text(currentChar, 0, 0);
      popMatrix();
      popMatrix();

      // Move halfway again
      arclength += w/2;
    }
  }
  void dealTable(int i) {
    killed=table.getFloat(eventNumber, "People killed");
    injured=table.getFloat(eventNumber, "People injured");
    homeless=table.getFloat(eventNumber, "People homeless");
    destroyed=table.getFloat(eventNumber, "Buildings destroyed")+table.getFloat(eventNumber, "Dwellings Destroyed");
    damaged=table.getFloat(eventNumber, "Buildings damaged")+table.getFloat(eventNumber, "Dwellings damaged");
    eventName=table.getString(eventNumber, "Event Name");
    country=table.getString(eventNumber, "Country"); 
    date=table.getString(eventNumber, "Date (UTC)");
    time1=table.getString(eventNumber, "Time (UTC)");
    level=table.getString(eventNumber, "Magnitude");
    levelNumber=table.getFloat(eventNumber, "Magnitude");
    String year=table.getString(eventNumber, "Year");
    String lonT=table.getString(eventNumber, "Longitude");
    String latT=table.getString(eventNumber, "Latitude");
    String depthT=table.getString(eventNumber, "Focal depth (km)");
    allPeople=killed+injured+homeless;
    allBuilding=destroyed+damaged;

    String event=year+" "+eventName+" "+date+" "+ time1;
    String location=country+" "+lonT+"/"+latT+" "+"Magnitude:"+level+" "+"Depth(km):"+depthT;
    String peopleT=killed+" people dead, "+injured+" people injured, and "+homeless+" homeless people "+"in this event";
    String buildingT=destroyed+" building destroyed, and "+damaged+" building damaged in this event";

    StringList finalText;
    finalText=new StringList();
    finalText.append(event);
    finalText.append(location);
    finalText.append(peopleT);
    finalText.append(buildingT);
    finalText1=finalText.get(i);
  }
}

