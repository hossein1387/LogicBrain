/*
 * NNLayer.h
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */

#ifndef NNLAYER_H_
#define NNLAYER_H_
#include "VGA.h"

class NNLayer {
public:
	NNLayer();
	NNLayer(int new_n_input, int new_n_neuron);
	void init(int new_n_input, int new_n_neuron);
	float rand_FloatRange(float a, float b);
	void random_init(int new_n_input, int new_n_neuron);
	void make_ternary();
	virtual ~NNLayer();

	int n_input;
	int n_neuron;

	float *bias;
	float *weight;
	float *value;

	float fct(float x);
	float * propagate(float * source);

	void print_activation();
	void print();

};

#endif /* NNLAYER_H_ */
