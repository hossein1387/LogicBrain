/********************************************************************
 * main.cpp
 *
 * Routine principale pour le projet ELE8307 A13.
 *
 * v1.2 - Application avec une machine pre-entrainee pour la
 *          reconnaissance de caracteres en braille* (avec une image
 *          50x100 pixels contenant 9 characteres 16x16).
 *
 *      - Ajout d'un #define pour activer/desactiver les printf dans
 *          la routine Image::apply_NN();
 *
 * Author : (V)-F)-I)
 *
 ********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#ifdef ALTERA
#include <sys/alt_alarm.h>
#endif

#include "NN.h"
#include "Image.h"
#ifdef ALTERA
#include "VGA.h"
VGA * pVGA;
char display[VGA_WIDTH*VGA_HEIGHT];
#endif

/*********************************************************************
 * main
 *********************************************************************/
int main(int argc, char **argv)
{
    printf("Entering ELE8307 Fall 2018 Project main() \r\n");

#ifdef ALTERA
    pVGA = new VGA(ELE8307_VGA_0_BASE, (int)display);
    pVGA->send_to_display();
    pVGA->clr();
#endif
    /* Initialisation et application a une image de la machine neuronale (poids aleatoires) */

    printf("> Exemple 1: NN Aleatoire \r\n");
    NN network(3);
    int matrix_size = 16;

    network.layer[0].random_init(matrix_size*matrix_size, 40);
    network.layer[1].random_init(40, 40);network.layer[1].make_ternary();
    network.layer[2].random_init(40, 10);network.layer[2].make_ternary();

    Image my_image(60,200);
    my_image.make_fractal();
#ifdef ALTERA
    my_image.printToScreen(0,0,pVGA);
#endif
    my_image.make_bw();
#ifdef ALTERA
    my_image.printToScreen(120,0,pVGA);
#endif
    printf("Start processing ...");

    for (int i=0;i<1;i++) {
#ifdef ALTERA
        int time1 = alt_nticks();
#endif
        Image * result_image = my_image.apply_NN(&network, matrix_size, i);
#ifdef ALTERA
        int time2 = alt_nticks();
        result_image->printToScreen(60*i,240,pVGA);
        delete result_image;
        printf("done in %d ms\r\n",(time2-time1));
#endif
    }
    exit(0);
    return 0;
}


