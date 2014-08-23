
import oscP5.*;
import netP5.*;

class OSC {  
    
  OscP5 oscP5;
  NetAddress glitchLocation;
  NetAddress soundMaxLocation;
  OscMessage destrIndex;
    

  void init() {  
    /* start oscP5, listening for incoming messages at port 12000 */
    //===INCOMING===//
    oscP5 = new OscP5(this,12000);
     
     //===OUTGOING===//
    glitchLocation = new NetAddress("192.168.1.102",12001);
    soundMaxLocation = new NetAddress("192.168.1.102",12002);
  }
  
  
  void send() {

    destrIndex = new OscMessage("/index");
    
    destrIndex.add(leapC.triGlitch_osc);
    /* send the message */
    oscP5.send(destrIndex, glitchLocation);
    oscP5.send(destrIndex, soundMaxLocation); 
  }
  
  
  /* incoming osc message are forwarded to the oscEvent method. */
  void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    print("# index: ");
    print(theOscMessage.get(0).intValue());
    
  }
}
