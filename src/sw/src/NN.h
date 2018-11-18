/*
 * NN.h
 *
 *  Created on: Jul 11, 2013
 *      Author: jpdavid
 */
#ifndef NN_H_
#define NN_H_

#include "NNLayer.h"
#include "utils.h"

class NN {
public:
	NN(int new_n_layer);
	virtual ~NN();

	int n_layer;
	NNLayer * layer;
	void make_ternary();
	BYTE * propagate(BYTE * source);
	int  getMaxOutputIndex();
	int getMaxOutputValue();
	void print();
	void printOutputs();
};

#endif /* NN_H_ */
