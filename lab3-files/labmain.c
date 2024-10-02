#include <stdio.h>
#include <stdlib.h>

/* main.c

   This file written 2024 by Artur Podobas and Pedro Antunes

   For copyright and licensing, see file COPYING */


/* Below functions are external and found in other files. */
extern void print(const char*);
extern void print_dec(unsigned int);
extern void display_string(char*);
extern void time2string(char*,int);
extern void tick(int*);
extern void delay(int);
extern int nextprime( int );


int mytime = 0x0055;
char textstring[] = "text, more text, and even more text!";

int mytime_sec_sec = 0;
int mytime_sec = 0;
int mytime_min_min = 0;
int mytime_min = 0;
int mytime_tim_tim = 0;
int mytime_tim = 0;
int reset = 0x24 ;



/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause) 
{}

/* Add your code here for initializing interrupts. */
void labinit(void)
{}

void set_leds(int led_mask){
  int *pointer = 0x04000000;
  *pointer = led_mask;
}

void sleck_displays(){
  int *pointer_first = 0x04000050;

  while (pointer_first < 0x040000a1){
    *pointer_first = 0x3ff;
    pointer_first += 4;

  }
}



void set_displays(int display_number, int value){

int *pointer_first = 0x04000050;

int alla_char[10] = { 0xc0,
                       0xf9,
                       0xa4,
                       0xB0,
                       0x99,
                       0x92,
                       0x82,
                       0xf8,
                       0x80,
                       0x90};



pointer_first += 4 * (display_number-1);
*pointer_first = alla_char[value];
}


int get_sw(void){
  unsigned int *pekare = (unsigned int *)0x04000010;
  int and_mask = 0x3FF;

  return (*pekare & and_mask);
}


int get_btn(void){
  unsigned int *pekare = (unsigned int *)0x040000d0;
  int and_mask = 0x1;
  return (*pekare & and_mask);
}

int tim_hant(){
  if (mytime_tim == (reset >> 4)){
    if (mytime_tim_tim == (reset&0xF)){
      mytime_tim_tim = 0;
      mytime_tim = 0;
      return 0;
    }
  }
  if (mytime_tim_tim == 9){
    mytime_tim++;
    mytime_tim_tim = 0;
    return 0;
  }
  mytime_tim_tim++;
}











/* Your code goes into main as well as any needed functions. */
int main() {
  sleck_displays();
  

  // Call labinit()
  labinit();
  
  // Enter a forever loop
  int counter = 0x0;

  while (1) {


    time2string( textstring, mytime ); // Converts mytime to string

    mytime_sec_sec = mytime & 0xF;
    mytime_sec = (mytime & 0xF0)>>4;
    mytime_min_min = (mytime & 0xF00)>>8;
    mytime_min = (mytime & 0xF000)>>12;
    set_displays(1,mytime_sec_sec);
    set_displays(2,mytime_sec);
    set_displays(3,mytime_min_min);
    set_displays(4,mytime_min);
    set_displays(5,mytime_tim_tim);
    set_displays(6,mytime_tim);


    if (mytime == 0x5959){
      tim_hant();
    }


    display_string( textstring ); //Print out the string 'textstring'
    
    delay(500);          // Delays 1 sec (adjust this value) 950

    tick( &mytime );     // Ticks the clock once
    
    
    set_leds(counter);
    counter++;


    int temp_mytime = mytime;
    while (get_btn() == 1){
      int switct_värde = get_sw();

      if ((switct_värde>>8) == 1){
        switct_värde = get_sw() & 0x3F ;
        set_displays( 1, (switct_värde%10));
        set_displays( 2, (switct_värde-switct_värde%10)/10);

        if (switct_värde < 60){
          temp_mytime = temp_mytime >> 8;
          temp_mytime = (temp_mytime<<4) + (switct_värde-switct_värde%10)/10;
          temp_mytime = (temp_mytime<<4) + switct_värde%10;
        }
        if (switct_värde > 59){
          temp_mytime = temp_mytime>>8;
          temp_mytime = (temp_mytime<<8) + 0xff;
        }
        mytime = temp_mytime;
      }

      if ((switct_värde>>8) == 2){
        switct_värde = get_sw() & 0x3F ;
        set_displays( 3, (switct_värde%10));
        set_displays( 4, (switct_värde-switct_värde%10)/10);

        if (switct_värde < 60){
          temp_mytime = temp_mytime >> 16;
          temp_mytime = (temp_mytime<<4) + (switct_värde-switct_värde%10)/10;
          temp_mytime = (temp_mytime<<4) + switct_värde%10;
          temp_mytime = (temp_mytime<<8) + (mytime&0xff);
        }
        if (switct_värde > 59){
          temp_mytime = temp_mytime>>16;
          temp_mytime = (temp_mytime<<8) + 0x00;
          temp_mytime = (temp_mytime<<8) + (mytime&0xff);


        }
        mytime = temp_mytime;
      }

      if ((switct_värde>>8) == 3){
        switct_värde = get_sw() & 0x3F ;
        set_displays( 5, (switct_värde%10));
        set_displays( 6, (switct_värde-switct_värde%10)/10);
        if (switct_värde < 60){
          temp_mytime = temp_mytime >> 8;
          temp_mytime = (temp_mytime<<4) + (switct_värde-switct_värde%10)/10;
          temp_mytime = (temp_mytime<<4) + switct_värde%10;
        }
        if (switct_värde > 59){
          temp_mytime = temp_mytime>>8;
          temp_mytime = (temp_mytime<<8) + 0xff;
        }
      }
    }
    mytime = temp_mytime;










  }  
}


