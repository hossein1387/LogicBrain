/*
 * NNLayer.cpp
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */

#include "NNLayer.h"
#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "Image.h"
#include <iostream>
#include <fstream>

#define MAKE_TERNARY_THRESHOLD 0.3

NNLayer::NNLayer() {
    // TODO Auto-generated constructor stub
    n_input = 0;
    n_neuron = 0;
    bias = 0;
    weight = 0;
    value = 0;
}

NNLayer::NNLayer(int new_n_input, int new_n_neuron) {
    // TODO Auto-generated constructor stub
    init(new_n_input, new_n_neuron);
}

void NNLayer::init(int new_n_input, int new_n_neuron) {
    // TODO Auto-generated constructor stub
    n_input = new_n_input;
    n_neuron = new_n_neuron;

    bias = new float[n_neuron];

    weight = new float[n_neuron*n_input];
    value = new float[n_neuron];
}

int MYrand() {
    static unsigned long seed=0x1234567;
    seed = seed * 3196829161;
    return seed >> 1;
}

float NNLayer::rand_FloatRange(float a, float b) {
    return ((b-a)*((float)MYrand()/0x7FFFFFFF))+a;
}

void NNLayer::random_init(int new_n_input, int new_n_neuron) {
    // TODO Auto-generated constructor stub
    init(new_n_input, new_n_neuron);

    bias = new float[n_neuron];

    float * cur_weight = weight;
    for (int i=0; i<n_neuron; i++) {
        bias[i] = rand_FloatRange(-log2(new_n_input),log2(new_n_input));
        for (int j=0; j<n_input; j++) {
            *(cur_weight++) = rand_FloatRange(-1,1);
        }
    }
}

int get_demo_weight(int layer, int neuron, int input) {
    unsigned seed=0x1234567;
    unsigned state = seed + ((layer * 1031)+neuron)*1031+input;

    for (int i=0;i<32;i++) {
        unsigned low = state & 0xFFFF;
        unsigned high = state >> 16;
        low+=(high * 0x158F);
        low &= 0xFFFF;
        state = (low <<17) + (high <<1) + (low >>15);
    }
    state = state&3;

    int result = 0;
    if (state != 3) result = state-1;
    return result;
}

int get_demo_bias(int layer, int neuron, int nb_input) {
    unsigned long seed=0x1234567;
    unsigned state = seed + ((layer * 1031) + neuron) * (neuron + 1);

    for (int i=0;i<32;i++) {
        unsigned low = state & 0xFFFF;
        unsigned high = state >> 16;
        low+=(high * 0x158F);
        low &= 0xFFFF;
        state = (low <<17) + (high <<1) + (low >>15);
    }
    int result = state;
    if (nb_input>=256) result>>=28;
    else if (nb_input>=16) result>>=29;
    else if (nb_input>=4) return result>>=30;
    else result = 0;
    return result;
}


void NNLayer::demo_init(int layer, int new_n_input, int new_n_neuron) {
    // TODO Auto-generated constructor stub
    init(new_n_input, new_n_neuron);

    bias = new float[n_neuron];

    float * cur_weight = weight;
    for (int i=0; i<n_neuron; i++) {
        bias[i] = get_demo_bias(layer, i, new_n_input);
        for (int j=0; j<n_input; j++) {
            *(cur_weight++) = get_demo_weight(layer,i,j);
        }
    }
    this->layer_num = layer;
    sprintf(weight_file_name, "weight_l%0d.txt", layer);
    sprintf(bias_file_name, "bias_l%0d.txt", layer);
}

int vector_weight(int x) {
    int result = 0;
    while (x != 0) {
        if (x & 1) result++;
        x >>=1;
    }
    return result;
}

void NNLayer::make_ternary() {
    float * cur_weight = weight;
    for (int i=0; i<n_neuron; i++) {
        bias[i] = trunc(bias[i]);
        for (int j=0; j<n_input; j++) {
            if (*cur_weight>MAKE_TERNARY_THRESHOLD) *cur_weight = 1;
            else if (*cur_weight<-MAKE_TERNARY_THRESHOLD) *cur_weight = -1;
            else *cur_weight = 0;
            cur_weight++;
        }
    }
}

NNLayer::~NNLayer() {
    // TODO Auto-generated destructor stub
}

//Edit this function for ternary logic
float NNLayer::fct(float x) {
//  return 1.0/(1.0+exp(-x));
    if (x>0) return 1.0;
    else return 0;
}

float * NNLayer::propagate(float * source) {
    // TODO Auto-generated constructor stub
    float * cur_weight = weight;

    for (int i=0; i<n_neuron; i++) {
        float acc = bias[i];

        for (int j=0; j<n_input; j++) {
            acc += *(cur_weight++) * source[j];
        }
        value[i] = fct(acc);
    }
    return value;
}

void NNLayer::print_activation() {
    printf("---------------\n");
    for (int i=0; i<n_neuron; i++) {
        printf("%i, %i\n", i, (int)value[i]);
    }
}

void NNLayer::print() {
    // TODO Auto-generated constructor stub

    float * cur_weight = weight;

    for (int i=0; i<n_neuron; i++) {
        printf("Neuron %i: %f, {", i+1, bias[i]);
        for (int j=0; j<n_input; j++) {
            if (j!=0) printf(", %2.2f", *(cur_weight++));
            else printf("%2.2f", *(cur_weight++));
        }
        printf("}, %f\r\n",value[i]);
    }
}

void NNLayer::save_weights_and_bias()
{
    std::ofstream weight_file;
    weight_file.open (weight_file_name);
    for(int i=0; i<n_neuron*n_input; i++)
    {
        // printf("%0.0f\n", weight[i]);
        char str_tmp[50];
        sprintf(str_tmp, "%0.0f\n", weight[i]);
        weight_file << str_tmp;
    }
    weight_file.close();

    std::ofstream bias_file;
    bias_file.open (bias_file_name);
    for(int i=0; i<n_neuron; i++)
    {
        // printf("%0.0f\n", weight[i]);
        char str_tmp[50];
        sprintf(str_tmp, "%0.0f\n", bias[i]);
        bias_file << str_tmp;
    }
    bias_file.close();
}
