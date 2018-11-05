/*
 * NNLayer.h
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */
#include "stdafx.h"
#include "AccelCore.h"

#ifndef NNLAYER_H_
#define NNLAYER_H_

class NNLayer {
public:
	NNLayer();
	NNLayer(int new_n_input, int new_n_neuron);
	void init(int new_n_input, int new_n_neuron);
	float rand_FloatRange(float a, float b);
	void random_init(int new_n_input, int new_n_neuron);
	BYTE makeTernaryExtra(float fValue);
	void make_ternary();
	virtual ~NNLayer();

	int n_input;
	int n_neuron;

	BYTE *bias;
	BYTE *weight;
	BYTE *value;

	BYTE fct(BYTE x);
	BYTE * propagate(BYTE * source);

	void print_activation();
	void print();
private:
	AccelCore* accelCore_;

};

#endif /* NNLAYER_H_ */
