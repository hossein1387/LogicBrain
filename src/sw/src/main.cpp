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
#include "NN.h"
#include "Image.h"

/*********************************************************************
 * main
 *********************************************************************/
int main(int argc, char **argv)
{
    printf("Entering ELE8307 Fall 2018 Project main() \r\n");


    /* Initialisation et application a une image de la machine neuronale (poids aleatoires) */

    printf("> Exemple 1: NN Aleatoire \r\n");
    NN network(3);
    int matrix_size = 16;

    network.layer[0].demo_init(0, matrix_size*matrix_size, 40);network.layer[0].make_ternary();
    network.layer[1].demo_init(1, 40, 40);network.layer[1].make_ternary();
    network.layer[2].demo_init(2, 40, 10);network.layer[2].make_ternary();

    network.layer[0].save_weights_and_bias();
    network.layer[1].save_weights_and_bias();
    network.layer[2].save_weights_and_bias();

    Image my_image(60,200);
    my_image.make_fractal();
    my_image.make_bw();
    my_image.save_image();
    printf("Start processing ...");

    // for (int i=0;i<10;i++) {
    //     Image * result_image = my_image.apply_NN(&network, matrix_size, i);
    // }

    return 0;
}


