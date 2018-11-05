/*
 * Image.cpp
 *
 *  Created on: Jul 15, 2013
 *      Author: jpdavid
 */

#include "Image.h"

#include "stdio.h"
#include "io.h"

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
Image * Image::apply_NN(NN * network, int size, int pos) {
	BYTE* source = new BYTE[size*size]; 
	Image * result = new Image(length-size+1,height-size+1); //-size (pour tenir compte de l'épaisseur du kernel)

	for (int y=0; y<=height-size; y++) {
		printf("Processing line %i\r\n",y);
		for (int x=0; x<=length-size; x++) {
			/* Appliquer le reseau sur un sous-bloc de l'image */
			for (int j=0; j<size; j++) {
				for (int i=0; i<size; i++) {
					source[j*size + i] = (*source_pixel(x + i, y + j)) / 255;   // source contient le résultat des multiplications
				}
			}
			network->propagate(source);  // Cette fonction fait les additions des multiplications précédentes

			/* Stocker les bons/meilleurs matchs */
			unsigned char pixel;
			pixel = 255*(network->layer[network->n_layer-1].value[pos]);
			*(result->source_pixel(x,y)) = pixel;
		}
	}
	return result;
}

/**********************************************************
 * Affiche l'image a l'ecran a la position x,y.
 *
 **********************************************************/
/*
void Image::printToScreen(int x, int y, VGA *pVGA) {
	for(int i=0; i<length; i++) {
		for(int j=0; j<height; j++) {
			pVGA->Set_Pixel_Color(x+i,y+j,*source_pixel(i,j));
		}
	}
}
*/

/**********************************************************
* Affiche l'image dans un fichier texte.
*
**********************************************************/

void Image::printToText(int x, int y) {
	std::ofstream fileOutput;
	fileOutput.open("image.csv");

	for(int i=0; i<length; i++) {
		for(int j=0; j<height; j++) {
			//pVGA->Set_Pixel_Color(x+i,y+j,*source_pixel(i,j));
			//std::cout << *source_pixel(i, j) << "\n";
			fileOutput << int(*source_pixel(i, j)) << ", ";
		}
		fileOutput << "\n";
	}

	fileOutput.close();
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

