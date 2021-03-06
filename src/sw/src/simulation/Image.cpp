/*
 * Image.cpp
 *
 *  Created on: Jul 15, 2013
 *      Author: jpdavid
 */

#include "Image.h"

#include "stdio.h"
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <bitset>
#include <string>


Image::Image() {
    // TODO Auto-generated constructor stub
    source_array = 0;
    length = 0;
    height = 0;
}

Image::Image(int new_length, int new_height) {
    // TODO Auto-generated constructor stub
    source_array = 0;
    init(new_length, new_height);
}

void Image::init(int new_length, int new_height) {
    // TODO Auto-generated constructor stub
    length = new_length;
    height = new_height;
    if (source_array != 0) delete[] source_array;
    source_array = new unsigned char [height*length];
    randomize();
}

void Image::randomize() {
    for (int y=0; y<height; y++) {
        for (int x=0; x<length; x++) {
            *source_pixel(x,y) = rand() &0xFF;
        }
    }
}

int Image::Get_Fractal_Level(float newRe, float newIm) {
    float cRe = -0.78;
    float cIm = 0.158;
    int i;

    for(i = 0; i < 63; i++) {
        float oldRe = newRe;
        float oldIm = newIm;
        float sqRe = newRe*newRe;
        float sqIm = newIm*newIm;
        if((sqRe + sqIm) > 4) break;
        newRe = sqRe - sqIm + cRe;
        newIm = 2 * oldRe * oldIm + cIm;

        //DEBUG
        //printf("(%f,%f)",newRe,newIm);
    }
    return i;
}

int Image::Get_Fractal_Color(int level) {
    if (level>63) level = 63;
    return ((level<<3) & 0xE0)+level;
}

void Image::make_fractal() {
    float sinAngle = 0;
    float cosAngle = 1;
    float Scale = 1;
    float X_position = 0;
    float Y_position = 0;

    float x,y;

    for (y=0; y<height; y++) {
        for (x=0; x<length; x++) {
            if ( (x==length/2) || (y==height/2) ) *source_pixel(x,y) = 0;
            else {
                float fx = (x-length/2)/(length/2);
                float fy = (y-height/2)/(height/2);
                float rotated_fx = (fx*cosAngle + fy*sinAngle)/Scale;
                float rotated_fy = (-fx*sinAngle + fy*cosAngle)/Scale;

                int level = Get_Fractal_Level(X_position+rotated_fx, Y_position+rotated_fy);
                *source_pixel(x,y) = 4*Get_Fractal_Color(level);
            }
        }
    }
}

unsigned char * Image::source_pixel(int x, int y) {
    // TODO Auto-generated constructor stub
    return source_array + (y*length+x);
}

void Image::make_bw() {
    // TODO Auto-generated constructor stub
    for (int y=0; y<height; y++) {
        for (int x=0; x<length; x++) {
            if (*source_pixel(x,y)>127) *source_pixel(x,y)=255;
            else *source_pixel(x,y)=0;
        }
    }
}

/*******************************************************
 * Application d'un reseau de neuronnes a cette image.
 *
 * Applique toutes les sous-images size x size de cette
 * image a l'entree de ce reseau de neuronnes.
 *
 *******************************************************/
void Image::apply_NN(NN * network, int size) {
    char output_file_name[50];
    sprintf(output_file_name, "orig_output.txt");
    std::ofstream output_file;
    output_file.open(output_file_name);

    float source[size*size];
    Image * result = new Image(length-size+1,height-size+1);
    int cnt = 0;
    int out_array[(length-size+1)*(height-size+1)];
    memset(out_array, 0, sizeof(int)*(length-size+1)*(height-size+1));

    for (int k = 0; k < 10; ++k)
    {
        cnt = 0;
        for (int y=0; y<=height-size; y++) {
            // printf("Processing line %i\r\n",y);
            for (int x=0; x<=length-size; x++) {
                /* Appliquer le reseau sur un sous-bloc de l'image */
                for (int j=0; j<size; j++) {
                    for (int i=0; i<size; i++) {
                        source[j*size + i] = (*source_pixel(x+i,y+j))/255.0;
                    }
                }
                network->propagate(source);

                /* Stocker les bons/meilleurs matchs */
                unsigned char pixel;
                pixel = 255*(network->layer[network->n_layer-1].value[k]);
                *(result->source_pixel(x,y)) = pixel;
                pixel = (pixel==255) ? 1 : 0;
                out_array[cnt] = (out_array[cnt]<<1 & 0xFFFFFFFE) + pixel;
                // printf("cnt=%0d\n", cnt);
                // if (cnt==(length-size+1)*(height-size+1)-1)
                // {
                //     printf("%0d\n", out_array[cnt]);
                // }
                cnt++;
            }
        }
    }

    for(int i=0; i<(length-size+1)*(height-size+1); i ++)
    {
        char str_tmp[50];
        std::string binary = std::bitset<10>(out_array[i]).to_string();
        // printf("%u\n", out_array[i]);
        sprintf(str_tmp, "%s\n", binary.c_str());
        output_file << str_tmp;
    }
    output_file.close();
}

/**********************************************************
 * Affiche l'image a l'ecran a la position x,y.
 *
 **********************************************************/
void Image::print() {
    printf("\n");
    for(int i=0; i<length; i++) {
        for(int j=0; j<height; j++) {
            int value = (int) *source_pixel(i,j);
            printf("%i,",value);
        }
        printf("\n");
    }
}

Image::~Image() {
    if (source_array != 0) delete[] source_array;
}

unsigned char * Image::new_source_pixel(int x, int y, int len) {
    return new_source_array + (y*len+x);
}

void Image::zero_pad(int desired_width, int desired_height)
{
    new_source_array = new unsigned char [desired_height*desired_width];
    for(int y=0; y<desired_height; y++) {
        for(int x=0; x<desired_width; x++) {
            if(y<height && x<length){
                *(new_source_pixel(x, y, desired_width)) = *source_pixel(x, y);
            } else{
                *(new_source_pixel(x, y, desired_width)) = 0;
            }
                printf("image(%0d, %0d)\n",y, x );
        }
    }
    // if (source_array != 0) delete[] source_array;

    height = desired_height;
    length = desired_width;
// Copy the new image to source array
    source_array = new unsigned char [desired_height*desired_width];
    for(int y=0; y<desired_height; y++) {
        for(int x=0; x<desired_width; x++) {
            *source_pixel(x,y) = *new_source_pixel(x, y, desired_width);
        }
    }
    if (source_array != 0) delete[] new_source_array;
}

void Image::save_image(const char* image_file_name="orig_image.txt")
{
    std::ofstream image_file;
    image_file.open (image_file_name);
    for(int i=0; i<length*height; i++)
    {
        // printf("%0.0f\n", weight[i]);
        int val = (source_array[i]==255) ? 1 : 0;
        char str_tmp[50];
        sprintf(str_tmp, "%d\n", val);
        image_file << str_tmp;
    }
    image_file.close();
}

