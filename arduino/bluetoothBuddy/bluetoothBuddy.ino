#include <timer.h>

//Bennett Schoonerman
//IGME470 Bluetooth Buddy

auto timer = timer_create_default();

char Incoming_value = "";                //Variable for storing Incoming_value
bool locked = false;
bool readyToLock = false; 

String codes[] = {"1234","2468","3100"};
String names[] = {"Bennett", "Nicole","Michelle"};

void setup() {
  Serial.begin(9600);//This is the rate the bluetooth module 'talks' at.
  pinMode(2, OUTPUT);
  timer.every(30000, checkOnUser);
  timer.every(10000, shareStatus);
  shareStatus();
}

void loop() {
  if(Serial.available() > 0)  
  {
    String inputCode = Serial.readString();
    for(int x=0; x<sizeof(codes); x++){
        if (codes[x] == inputCode){
          //Serial.println("Unlocked");
          locked = false;
          readyToLock = false;
          String msg = ("250:" + names[x]);
          Serial.print(msg);
          delay(50);
          shareStatus();
          return;
        }
      }
  }

  if(locked){
    digitalWrite(13, HIGH);  //If value is 1 then LED turns ON
    digitalWrite(2, LOW);       
  }
  else{
    digitalWrite(2,HIGH);
    digitalWrite(13, LOW);
  }
                             
  timer.tick();
}

void checkOnUser(){
  //Serial.println("checking on user");
  if(!locked){
    readyToLock = true;
    //Serial.println("Ready to lock");
    timer.in(5000,shouldLock);
  }
}

void shareStatus(){
  String msg = locked ? "200:Locked" : "200:Unlocked";
  Serial.print(msg);
}

//if the client didnt check in and set readyToLock to false then lock the app
void shouldLock(){
  //Serial.println("Atempting to lock");
  if(readyToLock){
    //Serial.println("Locked");
    locked = true;
    shareStatus();
  }
}
