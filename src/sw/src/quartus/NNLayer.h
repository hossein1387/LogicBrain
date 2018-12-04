/*
 * NNLayer.h
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */

#ifndef NNLAYER_H_
#define NNLAYER_H_
#include "VGA.h"

typedef short BYTE;

class NNLayer {
public:
    NNLayer();
    NNLayer(int new_n_input, int new_n_neuron);
    void init(int new_n_input, int new_n_neuron);
    float rand_FloatRange(float a, float b);
    void demo_init(int layer, int new_n_input, int new_n_neuron);
    void random_init(int new_n_input, int new_n_neuron);
    void make_ternary();
    virtual ~NNLayer();

    int n_input;
    int n_neuron;

    BYTE *bias;
    BYTE *weight;
    BYTE *value;

    BYTE fct(BYTE x);
    BYTE makeTernaryExtra(float fvalue);
    BYTE * propagate(BYTE * source);

    void print_activation();
    void print();
    int layer_num;
    void print_weight_mat();
    void print_bias();
    void zero_pad(int desired_num_input, int desired_num_neuron);

private:
    char weight_file_name[50];
    char bias_file_name[50];
    float* vec_2_dim(float* vec, int x, int y, int len);
    void zero_pad_weight(int desired_num_input, int desired_num_neuron);
    void zero_pad_bias(int desired_num_neuron);

};

#endif /* NNLAYER_H_ */
