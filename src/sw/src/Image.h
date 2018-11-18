/*
 * Image.h
 *
 *  Created on: Jul 15, 2013
 *      Author: jpdavid
 */

#ifndef IMAGE_H_
#define IMAGE_H_

#include "NN.h"
#ifdef ALTERA
#include "system.h"
#include "io.h"
#endif
#include "stdlib.h"
#include <iostream>
#include <fstream>
#include "utils.h"
class Image {
public:
	Image();
	Image(int new_length, int new_height);
	void init(int new_length, int new_height);
	void randomize();

	int Get_Fractal_Level(float newRe, float newIm);
	int Get_Fractal_Color(int level);
	void make_fractal();

	unsigned char * source_pixel(int x, int y);
	void make_bw();
	Image * apply_NN(NN * network, int size, int pos);
//	void printToScreen(int x, int y, VGA *pVGA);
	void printToText(int x, int y);
	void print();
	~Image();

	int height;
	int length;
	unsigned char *source_array;
};

#endif /* IMAGE_H_ */
