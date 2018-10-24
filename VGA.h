#ifndef   VGA_H
#define   VGA_H

#include "system.h"
#include "io.h"


//  VGA Parameter
#define VGA_WIDTH     640
#define VGA_HEIGHT    480

#define WHITE_COLORINDEX 0
#define RED_COLORINDEX 1
#define GREEN_COLORINDEX 2
#define BLUE_COLORINDEX 3
#define YELLOW_COLORINDEX 4
#define BROWN_COLORINDEX 5
#define CYAN_COLORINDEX 6
#define PURPLE_COLORINDEX 7

#define VGA_LEFT ((VGA_WIDTH-VGA_HEIGHT)/2)
#define VGA_RIGHT (VGA_WIDTH - VGA_LEFT - 1)
#define VGA_TOP 0
#define VGA_BOT (VGA_HEIGHT - 1)

//-------------------------------------------------------------------------
class VGA {
	int system_base_address;
	int memory_address;

public:
	VGA(int system_base_address, int memory_address) : system_base_address(system_base_address), memory_address(memory_address) {};

	inline void Set_Pixel(unsigned int x, unsigned int y) {
		if ( (x>=640) || (y>=480) ) return;
		int address = 640*y+x;
		IOWR_8DIRECT(memory_address, address, 255);
	}

	inline void Clr_Pixel(unsigned int x, unsigned int y) {
		if ( (x>=640) || (y>=480) ) return;
		int address = 640*y+x;
		IOWR_8DIRECT(memory_address, address, 192);
	}

	inline void Set_Pixel_Color(unsigned int x, unsigned int y, unsigned int color) {
		if ( (x>=640) || (y>=480) ) return;
		int address = 640*y+x;
		IOWR_8DIRECT(memory_address, address, color);
	}

	inline void send_to_display() {
		IOWR(system_base_address,0,memory_address);
	}

	void clr();
};

#endif //VGA_H
