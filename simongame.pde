/* Simon Says game by Robert Spann  2009           */
/* http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1235696263  */

/* Modified by Steve Hobley for MAKE:Projects 2012 */
/* www.stephenhobley.com */

#define SWITCHROOT 9 
#define SPEAKERPIN 6 
#define LEDROOT 16 

int turn = 0;

int input1 = LOW;
int input2 = LOW;
int input3 = LOW;
int input4 = LOW;

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
    digitalWrite(SWITCHROOT+ f, HIGH);       // turn on pullup resistors
    
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
  playTone(tonearray[value], 200); // Passes tone value and duration of the tone to the playTone function
  delay(200);
  digitalWrite(LEDROOT + value, LOW);
  delay(100);
 }

///////////////////////////////////////////////////////////////////////////
// function for generating the array to be matched by the player
void output() 
{ 
    
   for (int y=turn; y <= turn; y++)
   { 
      Serial.println(""); 
      Serial.print("Turn: ");
      Serial.println(y);

      randomArray[y] = random(1, 5); // Assigning a random number (1-4) to the randomArray[y], y being the turn count

      for (int x=0; x <= turn; x++)
      {
        Serial.print(randomArray[x]);
        ProcessSingleOutput(randomArray[x]);
      }
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
   
   for (int y=0; y<=5; y++)
   { 
     // Flashes light that should have been pressed
     digitalWrite(LEDROOT + correct, HIGH);
     playTone(tonearray[correct], 200);
     digitalWrite(LEDROOT + correct, LOW);
     delay(50);
  }
  
  delay(500);
  
  // Flashes lights for failure
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
  
  delay(500);
  
  turn = -1; // Resets turn value so the game starts over without need for a reset button
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
void loop() 
{ 
 for (int y=0; y<=1000; y++)
 { 
   output();
   input();
 }
}
  
