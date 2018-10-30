/********************************************************************
 * main.cpp
 *
 * Routine principale pour le projet ELE8307 A13.
 *
 * v1.2 - Application avec une machine pre-entrainee pour la
 * 			reconnaissance de caracteres en braille* (avec une image
 * 			50x100 pixels contenant 9 characteres 16x16).
 *
 *		- Ajout d'un #define pour activer/desactiver les printf dans
 *			la routine Image::apply_NN();
 *
 * Author : (V)-F)-I)
 *
 ********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <sys/alt_alarm.h>

#include "NN.h"
#include "Image.h"
#include "VGA.h"

VGA * pVGA;
char display[VGA_WIDTH*VGA_HEIGHT];

/*********************************************************************
 * main
 *********************************************************************/
int main(int argc, char **argv)
{
	printf("Entering ELE8307 Fall 2018 Project main() \r\n");

	pVGA = new VGA(ELE8307_VGA_0_BASE, (int)display);
	pVGA->send_to_display();
	pVGA->clr();

    /* Initialisation et application a une image de la machine neuronale (poids aleatoires) */

    printf("> Exemple 1: NN Aleatoire \r\n");
    NN network(3);
    int matrix_size = 16;

    network.layer[0].random_init(matrix_size*matrix_size, 40);
    network.layer[1].random_init(40, 40);network.layer[1].make_ternary();
    network.layer[2].random_init(40, 10);network.layer[2].make_ternary();

	Image my_image(60,200);
	my_image.make_fractal();
	my_image.printToScreen(0,0,pVGA);
	my_image.make_bw();
	my_image.printToScreen(120,0,pVGA);
	printf("Start processing ...");

	for (int i=0;i<1;i++) {
		int time1 = alt_nticks();
		Image * result_image = my_image.apply_NN(&network, matrix_size, i);
		int time2 = alt_nticks();
		result_image->printToScreen(60*i,240,pVGA);
		delete result_image;
		printf("done in %d ms\r\n",(time2-time1));
	}
	exit(0);
	return 0;
}


