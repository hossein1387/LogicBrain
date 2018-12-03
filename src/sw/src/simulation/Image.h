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
    unsigned char * new_source_pixel(int x, int y, int len);
    void make_bw();
    void apply_NN(NN * network, int size);
    void zero_pad(int desired_height, int desired_width);
    void print();
    ~Image();
    void save_image(const char* image_file_name);

    int height;
    int length;
    unsigned char *source_array;
    unsigned char *new_source_array;
};

#endif /* IMAGE_H_ */
