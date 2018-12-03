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
#include "system.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/alt_alarm.h>

#include "NN.h"
#include "Image.h"
#include "VGA.h"

VGA * pVGA;
char display[VGA_WIDTH*VGA_HEIGHT];
void drawline(int x1,int y1,int x2,int y2);


int make_ternary_cool_version(float val)
{
    if (val>.3) return 1;
    else if (val<.3) return -1;
    else return 0;
}


void load_image(NNLayer* layer, int layer_num){
    for(int i = 0; i < layer->n_neuron; i++){
        int val = layer->bias[i];    //make_ternary_cool_version(layer->bias[i]);
        if(layer_num == 0){
            ALT_CI_LOADBIAS1_0(val, i);
        } else if(layer_num == 1){
            ALT_CI_LOADBIAS2_0(val, i);
        } else if(layer_num == 2){
            ALT_CI_LOADBIAS3_0(val, i);
        }
        //printf("%i\n", val);
    }
    int test =0;
    for(int i = 0; i < layer->n_neuron; i++){
        for(int j = 0; j < layer->n_input; j++){
            if(j == layer->n_input -1){
                if(layer_num == 0){
                    test = ALT_CI_LOADLAYER1_0(layer->weight[layer->n_input*i + j], 2048 + i);
                } else if( layer_num == 1){
                    ALT_CI_LOADLAYER2_0(layer->weight[layer->n_input*i + j], 2048 + i);
                } else if(layer_num == 2){
                    ALT_CI_LOADLAYER3_0(layer->weight[layer->n_input*i + j], 2048 + i);
                }
                printf("Layer: %u, Address: %u, Value: %u\n",layer_num ,layer->n_input*i + j, test);
            } else {
                if(layer_num == 0){
                    ALT_CI_LOADLAYER1_0(layer->weight[layer->n_input*i + j], i);
                } else if( layer_num == 1){
                    ALT_CI_LOADLAYER2_0(layer->weight[layer->n_input*i + j], i);
                } else if(layer_num == 2){
                    ALT_CI_LOADLAYER3_0(layer->weight[layer->n_input*i + j], i);
                }
            }
            //printf("%i   ", layer->weight[layer->n_input*i + j]);
        }

    }

}

/*********************************************************************
 * main
 *********************************************************************/
int main(int argc, char **argv)
{
    int a=0, b=0, c=-1;

    printf("Entering ELE8307 Fall 2018 Project main() \r\n");

    pVGA = new VGA(ELE8307_VGA_0_BASE, (int)display);
    pVGA->send_to_display();
    pVGA->clr();

    /* Initialisation et application a une image de la machine neuronale (poids aleatoires) */

    printf("> Exemple 1: NN Aleatoire \r\n");
    NN network(3);
    int matrix_size = 16;

    network.layer[0].demo_init(0, matrix_size*matrix_size, 1024);
    network.layer[0].make_ternary();

    network.layer[1].demo_init(1, 1024 ,64);
    network.layer[1].make_ternary();

    network.layer[2].demo_init(2, 64, 10);
    network.layer[2].make_ternary();

    load_image(&network.layer[0], 0);
    load_image(&network.layer[1], 1);
    load_image(&network.layer[2], 2);

    Image my_image(60,200);
    my_image.make_fractal();
    my_image.printToScreen(0,0,pVGA);
    my_image.make_bw();
    my_image.printToScreen(120,0,pVGA);

///*START CONVOLUTION*/
//
///*TEST VGA*/
//

//      }
    printf("Start processing ...");


    int time1 = alt_nticks();
    int val = 0;
    for(int i=0; i<185; i++) {
        for(int j=0; j<45; j++) {
            if((i == 0) && (j == 0))
                c = ALT_CI_CONV_0(0, 0);
            else
                c = ALT_CI_CONV_0(0, 1);
            for (int k=0;k<10;k++) {
                val = (c>>(9-k))&1;
                pVGA->Set_Pixel_Color(585-60*k-j, 425-i, 255*val);
                //int val = (c>>(9-k))&1;
                //pVGA->Set_Pixel_Color(60*k+j,240+i,255*val);
                //printf(" val =%d a=%0u  b=%0u   c=%0u\n", val, a, b, c);
            }
        }
    }
    int time2 = alt_nticks();
    printf("done in %d ms\r\n",(time2-time1));

        Image* tableauImage[10];
        for(int i=0; i<10; i++){
            tableauImage[i] = new Image(45,185);
        }

        Image * result_image = my_image.apply_NN(&network, matrix_size, 0, tableauImage);

        for (int i=0;i<10;i++) {
            //tableauImage[i]->printToScreen(60*i,240,pVGA);
            delete tableauImage[i];
        }



    exit(0);
    return 0;
}

void drawline(int x1,int y1,int x2,int y2){
    int deltax = x2 - x1;
    int deltay = y2 - y1;
    int deltaerr = abs(deltay/deltax);
    float err = 0.0;
    int y = y1;
    for (int x = 0; x < x1; x++) {
        pVGA->Set_Pixel_Color(x,y,255);
        err = err + deltaerr;
        if (err >= 0.5) {
            y = y + deltay/(abs(deltay));
            err = err -1.0;
        }
    }
}


