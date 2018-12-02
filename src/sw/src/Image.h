/*
 * Image.h
 *
 *  Created on: Jul 15, 2013
 *      Author: jpdavid
 */

#ifndef IMAGE_H_
#define IMAGE_H_

#include "NN.h"
#include "stdlib.h"

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
    void apply_NN(NN * network, int size);
    void print();
    ~Image();
    void save_image();

    int height;
    int length;
    unsigned char *source_array;
};

#endif /* IMAGE_H_ */
