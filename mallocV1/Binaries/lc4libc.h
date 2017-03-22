/* This file contains typedefs and function declarations for
   the traps defined in lc4_trap_wrappers.asm */

/* handy data types & colors we'll use in asteroids */
typedef int lc4int;
typedef unsigned int lc4uint;
typedef char lc4char;
typedef int lc4bool;

#define TRUE  1
#define FALSE 0

#define NULL (void*)0

#define BLACK  0x0000U
#define WHITE  0xFFFFU
#define GRAY8  0x2108U
#define YELLOW 0x7FF0U
#define RED    0x7C00U
#define ORANGE 0xF600U
#define BLUE   0x0033U
#define GREEN  0x3300U
#define CYAN   0x0770U

/*
 * These interface directly with the traps contained in os.asm.
 *
 * Functions are declared here so they can be used from asteroids.c. These
 * functions are defined in lc4libc.asm, providing a wrapper around
 * the traps so they can be used from C compiled with lcc.
 */

//String functions
char lc4_getc();
void lc4_putc(char c);
void lc4_puts(lc4uint *str);
lc4uint lc4_getc_timer(lc4int duration);

//Draw functions
void lc4_draw_sprite(lc4int x, lc4int y, lc4uint color, lc4uint *sprite);
void lc4_draw_pixel(lc4int x, lc4int y, lc4uint color);
void lc4_draw_circle(lc4int x, lc4int y, lc4int radius, lc4uint color);

//lfsr functions
void lc4_lfsr_set_seed(int seed);
int lc4_lfsr();

//Double buffer functions
void lc4_halt();
void lc4_reset_vmem();
void lc4_blt_vmem();
