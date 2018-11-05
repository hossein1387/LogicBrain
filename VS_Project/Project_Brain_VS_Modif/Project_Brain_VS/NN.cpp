/*
 * NN.cpp
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */

#include "NN.h"
#include "stdio.h"

NN::NN(int new_n_layer) {
	// TODO Auto-generated constructor stub
	n_layer = new_n_layer;
	layer = new NNLayer[n_layer];
}

NN::~NN() {
	// TODO Auto-generated destructor stub
}

void NN::make_ternary() {
	for (int i=0; i<n_layer; i++) {
		layer[i].make_ternary();
	}
}

BYTE * NN::propagate(BYTE * source) {
	for (int i=0; i<n_layer; i++) {
		source = layer[i].propagate(source);
	}
	return source;
}

int NN::getMaxOutputIndex() {
	float maxval = layer[n_layer-1].value[0];
	int maxindex = 0;
	for(int i=1; i<layer[n_layer-1].n_neuron; i++) {
		if( layer[n_layer-1].value[i] > maxval) {
			maxval = layer[n_layer-1].value[i];
			maxindex = i;
		}
	}
	return maxindex;
}

int NN::getMaxOutputValue() {
	float maxval = layer[n_layer-1].value[0];
	for(int i=1; i<layer[n_layer-1].n_neuron; i++) {
		if( layer[n_layer-1].value[i] > maxval) {
			maxval = layer[n_layer-1].value[i];
		}
	}
	return maxval;
}

void NN::print() {
	for (int i=0; i<n_layer; i++) {
		printf("Layer : %i\r\n",i);

		layer[i].print();
	}
}

void NN::printOutputs() {

	for(int i=0; i<layer[n_layer-1].n_neuron; i++) {
		printf("Neuron[%i]: %2.2f \r\n",i, layer[n_layer-1].value[i]);
	}
	printf("\r\n");
}
