/* Original game by Robert Spann 2009 */
/* http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1235696263 */

/* Modified by Steve Hobley for MAKE:Projects 2012 */
/* www.stephenhobley.com */

#define SWITCHROOT 9
#define SPEAKERPIN 6
#define LEDROOT 16

#define WINSTATE 32   // number of steps to complete to win - this should be divisible by four
#define RESPONSETIME 3000 // Time in ms we give the player to respond before calling fail()

int band = WINSTATE / 4;
int turn = 0;
int input1 = LOW;
int input2 = LOW;
int input3 = LOW;
int input4 = LOW;
int counter = 0;

int beepdelay = 200;
int pausedelay = 100;

int randomArray[100]; //Intentionally long to store up to 100 inputs (doubtful anyone will get this far)
int tonearray[4];

///////////////////////////////////////////////////////////////////////////
void setup() {

  Serial.begin(9600);
  
  pinMode(SPEAKERPIN, OUTPUT);

  tonearray[0] = 1915;
  tonearray[1] = 1519;
  tonearray[2] = 1275;
  tonearray[3] = 956;

  for (int f = 0; f < 4; f++)
  {
    pinMode(LEDROOT + f, OUTPUT);
    pinMode(SWITCHROOT+ f, INPUT);
    digitalWrite(SWITCHROOT+ f, HIGH); // turn on pullup resistors
    
    ProcessSingleOutput(f+1);
  }
    
  randomSeed(analogRead(0)); // Added to generate "more randomness" with the randomArray for the output function
 
  delay(1000);
  
 }
  
///////////////////////////////////////////////////////////////////////////
void ProcessSingleOutput(int value)
{
  value--;
  
  digitalWrite(LEDROOT + value, HIGH);
  playTone(tonearray[value], beepdelay); // Passes tone value and duration of the tone to the playTone function
  delay(beepdelay);
  digitalWrite(LEDROOT + value, LOW);
  delay(pausedelay);
 }

///////////////////////////////////////////////////////////////////////////
// function for generating the array to be matched by the player
void output()
{
    
      Serial.println("");
      Serial.print("Turn: ");
      Serial.println(turn);

      randomArray[turn] = random(1, 5); // Assigning a random number (1-4) to the randomArray[y], y being the turn count

      for (int x=0; x <= turn; x++)
      {
        Serial.print(randomArray[x]);
        ProcessSingleOutput(randomArray[x]);
      }
}
  
///////////////////////////////////////////////////////////////////////////
void ProcessSingleInput(int value, int x)
{
  digitalWrite(LEDROOT + value, HIGH);
  playTone(tonearray[value], 200); // Passes tone value and duration of the tone to the playTone function
  delay(200);
  digitalWrite(LEDROOT + value, LOW);
  delay(50);
  Serial.print(" ");
  Serial.print(value+1);
  if ((value+1) != randomArray[x])
  {
    fail(randomArray[x]);
  }

}
  
///////////////////////////////////////////////////////////////////////////
// Function for allowing user input and checking input against the generated array
void input()
{
  for (int x=0; x <= turn;)
  {
    input1 = digitalRead(SWITCHROOT);
    input2 = digitalRead(SWITCHROOT+1);
    input3 = digitalRead(SWITCHROOT+2);
    input4 = digitalRead(SWITCHROOT+3);

    counter++;
      
    if (counter > RESPONSETIME)
    {
      Serial.println("TIMEOUT!");
      fail(randomArray[x]);
      counter = 0;
      x++;
    }
    
    delay(1);

    if (input1 == LOW)
    {
      ProcessSingleInput(0, x);
      x++;
    }

    if (input2 == LOW)
    {
      ProcessSingleInput(1, x);
      x++;
    }

    if (input3 == LOW)
    {
      ProcessSingleInput(2, x);
      x++;
    }

    if (input4 == LOW)
    {
      ProcessSingleInput(3, x);
      x++;
    }

   }
  
  delay(500);
  
  turn++; // Increments the turn count, also the last action before starting the output function over again
}

///////////////////////////////////////////////////////////////////////////
// Function used if the player fails to match the sequence
 void fail(int correct)
{
   digitalWrite(LEDROOT, HIGH);
   digitalWrite(LEDROOT+1, HIGH);
   digitalWrite(LEDROOT+2, HIGH);
   digitalWrite(LEDROOT+3, HIGH);
   playTone(6000,1000); // Rather Rude Rasp
   digitalWrite(LEDROOT, LOW);
   digitalWrite(LEDROOT+1, LOW);
   digitalWrite(LEDROOT+2, LOW);
   digitalWrite(LEDROOT+3, LOW);

   correct--;
   
   for (int y=0; y<=3; y++)
   {
     // Flashes light that should have been pressed
     digitalWrite(LEDROOT + correct, HIGH);
     //playTone(tonearray[correct], 200);
     delay(200);
     digitalWrite(LEDROOT + correct, LOW);
     delay(50);
  }
  Serial.println("");
  Serial.print("OOPS! Should have pressed ");
  Serial.println(correct+1);

  delay(500);
  
  // Now Score
  // 1 - Beginner
  // 2 - Amateur
  // 3 - Expert
  // 4 - Champ
 
  int scoreband = turn / band;
 
  for (int y=0; y<=5; y++)
   {
     // Flashes score light
     digitalWrite(LEDROOT + scoreband, HIGH);
     playTone(tonearray[scoreband], 200);
     digitalWrite(LEDROOT + scoreband, LOW);
     delay(50);
  }
  
  Serial.print("You Score ");
  Serial.println(scoreband+1);
  
  delay(500);
  
  FlashAll();
  
  delay(500);
  
  turn = -1; // Resets turn value so the game starts over without need for a reset button
  beepdelay = 200;
  pausedelay = 100;
}

///////////////////////////////////////////////////////////////////////////
void win()
{
  Serial.println("WIN!");
  
  for (int y=0; y < 4; y++)
   {
      for (int f = 0; f < 4; f++)
      {
    
         digitalWrite(LEDROOT + f, HIGH);
         playTone(tonearray[f], 100);
         digitalWrite(LEDROOT + f, LOW);
         delay(25);
      }
  }
  
  FlashAll();
  
  turn = -1; // Resets turn value so the game starts over without need for a reset button
  beepdelay = 200;
  pausedelay = 100;
  
  delay(1000);
}

void FlashAll()
{
  ///////////////////////////////////////////////////////////////////////////
  // Flashes all lights
  for (int y=0; y<=5; y++)
  {
   digitalWrite(LEDROOT, HIGH);
   digitalWrite(LEDROOT+1, HIGH);
   digitalWrite(LEDROOT+2, HIGH);
   digitalWrite(LEDROOT+3, HIGH);
   delay(200);
   digitalWrite(LEDROOT, LOW);
   digitalWrite(LEDROOT+1, LOW);
   digitalWrite(LEDROOT+2, LOW);
   digitalWrite(LEDROOT+3, LOW);
   delay(200);
  }
}
///////////////////////////////////////////////////////////////////////////
// Low C = 1915
// D = 1700
// E = 1519
// F = 1432
// G = 1275
// A = 1136
// B = 1014
// High C = 956
void playTone(int tone, int duration)
{
  for (long i = 0; i < duration * 1000L; i += tone * 2)
  {
    digitalWrite(SPEAKERPIN, HIGH);
    delayMicroseconds(tone);
    digitalWrite(SPEAKERPIN, LOW);
    delayMicroseconds(tone);
  }
}

///////////////////////////////////////////////////////////////////////////
// Slowly cranks up the pressure
void increaseSpeed()
{
  if (turn == band)
  {
    beepdelay = 170;
    pausedelay = 80;
    return;
  }
  if (turn == band * 2)
  {
    beepdelay = 150;
    pausedelay = 60;
    return;
  }

  if (turn == band*3)
  {
    beepdelay = 120;
    pausedelay = 40;
  }
}

///////////////////////////////////////////////////////////////////////////
void loop()
{
 for (int y = 0; y < WINSTATE; y++)
 {
   output();
   input();
   increaseSpeed();
 }
 
 win();
 
}