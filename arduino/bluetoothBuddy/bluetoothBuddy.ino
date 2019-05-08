#include <timer.h>

//Bennett Schoonerman
//IGME470 Bluetooth Buddy

auto timer = timer_create_default();

char Incoming_value = "";
bool locked = true;
bool readyToLock = false; 

String codes[] = {"1234","2468","3100"};
String names[] = {"Bennett", "Nicole","Michelle"};

void setup() {
  Serial.begin(9600);//This is the rate the bluetooth module 'talks' at.
  pinMode(2, OUTPUT);
  timer.every(15000, checkOnUser);//timeout duration before auto locking
  delay(500);//offset these clocks so the serial strings dont get sent together
  timer.every(10000, shareStatus);
  shareStatus();
  //awake sound
  tone(A5, 523.25);
  delay(200);
  tone(A5, 659.25);
  delay(200);
  tone(A5, 783.99, 200);
}

void loop() {
  if(Serial.available() > 0)  
  {
    String inputCode = Serial.readString();
    if(inputCode == "lockpls"){
      locked = true;
      shareStatus();
      chimeOff();
      return;
    }
    if(inputCode == "active"){
      readyToLock = false;
      return;
    }
    for(int x=0; x<sizeof(codes); x++){
        if (codes[x] == inputCode){
          //Serial.println("Unlocked");
          locked = false;
          readyToLock = false;
          String msg = ("250:" + names[x]);
          Serial.print(msg);
          delay(50);
          shareStatus();
          chimeOn();
          return;
        }
      }
      chimeError();
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
    Serial.print("300:Ready to Lock");//code that says 'hey im gonna lock' up and client should respond with active or else lock up!
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
    chimeOff();
  }
}

void chimeOn(){
    tone(A5, 523.25);
    delay(200);
    tone(A5, 783.99, 200);
}

void chimeOff(){
    tone(A5, 783.99);
    delay(200);
    tone(A5, 523.25, 200);
}

void chimeError(){
  tone(A5, 659.25,100);
  delay(200);
  tone(A5, 659.25,100);
  delay(200);
  tone(A5, 659.25, 100);
}
