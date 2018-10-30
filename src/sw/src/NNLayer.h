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

};

#endif /* NNLAYER_H_ */
