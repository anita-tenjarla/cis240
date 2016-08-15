/*
 * CubeRunner.c : Joe Klinger and Hemanth Chittela
 */

#include "lc4libc.h"

/*
 * #############  DATA STRUCTURES THAT STORE THE GAME STATE ######################
 */

#define RUNNER_X_START    60
#define RUNNER_Y_START    114

// Maximum vertical velocity of the player
#define MAX_VY            2

// Size of each cube in pixels
#define CUBE_WIDTH        8
 
//number of cubes in each row
 #define NUM_CUBES        4
 
//number of rows on the screen
 #define NUM_ROWS         4

 // how much to move runner to the left/right when the user presses 'a' or 'd'. Update runner_vx with this value when appropriate.
 #define RUNNER_VX_INCREMENT  2

// speed for getc_timer
int speed = 500;


// These values include the position and velocity of the runner on the screen.
// Note that the y position does not change.
// runner_x and runner_y denote the position of the upper left corner of the runner
int runner_x = RUNNER_X_START;
int runner_y = RUNNER_Y_START;

// runner_vx indicates how much the position should change on the current iteration.
// runner_vy indicates how much the cubes should move down on the current iteration.
int runner_vx = 0;
int runner_vy = 3;

typedef struct {
  int xpos;
  int exists;
} cube_struct;

typedef struct {
  int ypos;
  cube_struct cubes[NUM_CUBES];
} cube_row_struct;

// Array containing all of the information on the pipes
cube_row_struct cube_rows[NUM_ROWS];

// Score contains the number of rows that you have successfully traversed
int score = 0;

/*
 * #############  UTILITY ROUTINES ######################
 */

//Don't alter these!

//
// routine for printing out 2C 16 bit numbers on the ASCII display - useful for testing.
//
void printnum (int n) {
  int abs_n;
  char str[10], *ptr;

  // Corner case (n == 0)
  if (n == 0) {
    lc4_puts ((lc4uint*)"0");
    return;
  }
 
  abs_n = (n < 0) ? -n : n;

  // Corner case (n == -32768) no corresponding +ve value
  if (abs_n < 0) {
    lc4_puts ((lc4uint*)"-32768");
    return;
  }

  ptr = str + 10; // beyond last character in string

  *(--ptr) = 0; // null termination

  while (abs_n) {
    *(--ptr) = (abs_n % 10) + 48; // generate ascii code for digit
    abs_n /= 10;
  }

  // Handle -ve numbers by adding - sign
  if (n < 0) *(--ptr) = '-';

  lc4_puts((lc4uint*)ptr);
}

void endl () {
  lc4_puts((lc4uint*)"\n");
}

// rand16 returns a pseudo-random between 0 and 128 by simulating the action of a 16 bit Linear Feedback Shift Register.
int rand16 ()
{
  int lfsr;
  // Advance the lfsr seven times
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();
  lfsr = lc4_lfsr();

  // return the last 7 bits
  return (lfsr & 0x7F);
}

/*
 * #############  CODE THAT DRAWS THE SCENE ######################
 */

//Sprite
lc4uint runner [] = {
  0x81,
  0xC3,
  0xDB,
  0xFF,
  0xFF,
  0xDB,
  0xC3,
  0x81
};

void draw_cubes ()
{
  /**
     draw_cubes should draw all of the cube elements based on their current position using the lc4_draw_rect function.
     You should use this function to draw the borders (outlines) of the cubes as opposed to drawing
     filled in cubes. This is more efficient since less pixels need to be filled in.
     The constant CUBE_WIDTH specifies width and height of a cube.
   **/

    int i; 
    int j; 
    for (j=0; j<NUM_ROWS; j++) {
      for (i=0; i<NUM_CUBES; i++) { 
        lc4_draw_rect(cube_rows[j].cubes[i].xpos, cube_rows[j].ypos, CUBE_WIDTH, 1, 0x3300U);
        lc4_draw_rect(cube_rows[j].cubes[i].xpos, cube_rows[j].ypos, 1, CUBE_WIDTH, 0x3300U);
        lc4_draw_rect(cube_rows[j].cubes[i].xpos+CUBE_WIDTH, cube_rows[j].ypos, 1, CUBE_WIDTH+1, 0x3300U);
        lc4_draw_rect(cube_rows[j].cubes[i].xpos, cube_rows[j].ypos+CUBE_WIDTH, CUBE_WIDTH, 1, 0x3300U);
      }
    }
}

void draw_runner ()
{
  /**
    draw_runner should draw the runner based on the current runner position using lc4_draw_rect.
    The variables runner_x and runner_y specify the sprite's upper left corner.
  **/

  lc4_draw_sprite(runner_x, runner_y, 0x7C00U, runner);   
}

void redraw ()
{
  // This function assumes that PennSim is being run in double buffered mode
  // In this mode we first clear the video memory buffer with lc4_reset_vmem,
  // then draw the scene, then call lc4_blt_vmem to swap the buffer to the screen
  // NOTE that this requires running PennSim with the following command:
  // java -jar PennSim.jar -d

  lc4_reset_vmem();

  draw_cubes ();
  draw_runner ();
            
  lc4_blt_vmem();
}



/*
 * #############  CODE THAT HANDLES GAME PLAY ######################
 */

void reset_game_state ()
{
  /**
     This function needs to do a few things.

     0) reset the score to 0     
     1) Reset the position of the runner
     2) Reset the positions of all the cubes. You can use the rand16 function to select a value for the horizontal location of each cube. Note that the number of cubes per row is equivalent to NUM_CUBES.
  **/
    
  int a; 
  int b;

  score = 0;  //reset score to zero
  runner_x = RUNNER_X_START; //reset runner start positions
  runner_y = RUNNER_Y_START; 
  
  //reset spaced out y values and random x values of each cube
  for (a=0; a<NUM_ROWS; a++) {
    cube_rows[a].ypos = a*32; 
      for (b=0; b<NUM_CUBES; b++) {
        cube_rows[a].cubes[b].xpos = rand16();   
      }
  }
}

void update_cubes ()
{
  /**
     On every iteration of the game update_cubes is called to update the state of all of the cubes. We model movement of the runner by moving all the cubes down on every iteration while runner_y stays fixed.

     Once a row of cubes moves off the bottom of the screen, it will be reinitialized to appear at the top of the screen with new set of random locations for the cubes.

     This routine is also where score keeping occurs. When the whole runner has completely passed a row of cubes, the score is incremented by one.
  **/
     int j; 
     for (j=0; j<NUM_CUBES; j++) {
        cube_rows[j].ypos += runner_vy; 
        if(cube_rows[j].ypos>=116) {
          cube_rows[j].ypos=0; 
          score++; 
        }
     }
}

void update_runner ()
{
  /**
    update_runner is called on every iteration to update the position of the runner and its velocity. Update runner_x position by adding runner_vx.
  **/
    
    int x = lc4_getc_timer(speed); 

    //if key is a, change direction to left
    if (x == 97) { 
      runner_vx = -1*RUNNER_VX_INCREMENT;
    }

    //if key is d, change direction to right
    if (x == 100) {
      runner_vx = RUNNER_VX_INCREMENT; 
    }
    //update runner's x position
    runner_x = runner_x + runner_vx; 

    //bound runner to screen 
    if (runner_x >= 120){
      runner_x=120;
    }
    if (runner_x <= 0){
      runner_x=0; 
    }
}

int dead_runner()
{
  /**
    dead_runner is used to check if the runner has collided with any cubes. This is done by checking if there is any overlap with any part of any cube.

    If either the runner collides with a cube, return a non-zero value, or zero otherwise.
  **/
    
  int i; 
  int j; 

  //first check against runner y value, then against left and right bounds
  for(i=0; i<NUM_ROWS; i++){
    for (j=0; j<NUM_CUBES; j++){
      if (runner_y < cube_rows[i].ypos+CUBE_WIDTH) {
        if (((runner_x > cube_rows[i].cubes[j].xpos) && (runner_x < (cube_rows[i].cubes[j].xpos+CUBE_WIDTH))) 
          || ((runner_x+CUBE_WIDTH > cube_rows[i].cubes[j].xpos) && (runner_x+CUBE_WIDTH < (cube_rows[i].cubes[j].xpos+CUBE_WIDTH)))){
          return -1; 
        }
      }
    }
  }

  return 0;
}



/*
 * #############  MAIN PROGRAM ######################
 */

int main ()
{ 
  lc4_puts ((lc4uint*)"Welcome to CubeRunner!\n");

  // Init game state
  reset_game_state();
  redraw();
  while (1) {
    lc4_puts ((lc4uint*)"\nPress r to reset\n");

    // Sit and wait for a r
    while(lc4_getc_timer(speed) != 'r');

    reset_game_state();
    redraw();

    lc4_puts ((lc4uint*)"Press a and d to move the runner\n");
    // Main loop

    while (1) {
      update_runner(); 
      update_cubes(); 
      //if runner is dead, print score and prompt restart of game
      if(dead_runner()!=0) {
        lc4_puts((lc4uint*)"Score:");
        printnum(score); 
        break;
      }
      //else update and redraw screen
      redraw(); 
    }
    continue; 
  }

  return 0; 
}
