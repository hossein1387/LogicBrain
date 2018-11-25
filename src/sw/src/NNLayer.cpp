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

    bias = new BYTE[n_neuron];

    weight = new BYTE[n_neuron*n_input];
    value = new BYTE[n_neuron];
	accelCore_ = new AccelCore((n_input/8));

}

int MYrand() {
    static unsigned long seed=0x1234567;
    seed = seed * 3196829161;
    return seed >> 1;
}

float NNLayer::rand_FloatRange(float a, float b) {
    return ((b-a)*((float)MYrand()/0x7FFFFFFF))+a;
}

BYTE NNLayer::makeTernaryExtra(float fvalue){
    if (fvalue >= 0.4) {
        return 1;
    } else if(fvalue <=-0.4){
        return -1;
    } else {
        return 0;
    }
}

void NNLayer::random_init(int new_n_input, int new_n_neuron) {
    // TODO Auto-generated constructor stub
    init(new_n_input, new_n_neuron);

    bias = new BYTE[n_neuron];

    BYTE * cur_weight = weight;
    for (int i=0; i<n_neuron; i++) {
        bias[i] = makeTernaryExtra(rand_FloatRange(-log2(new_n_input),log2(new_n_input)));
        for (int j=0; j<n_input; j++) {
            *(cur_weight++) = makeTernaryExtra(rand_FloatRange(-1,1));
        }
    }
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
    BYTE * cur_weight = weight;
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
	delete accelCore_;
}

//Edit this function for ternary logic
BYTE NNLayer::fct(BYTE x) {
//	return 1.0/(1.0+exp(-x));
	if (x>0) return 1.0;
	else return 0;
}

BYTE * NNLayer::propagate(BYTE * source) {
	// TODO Auto-generated constructor stub
	BYTE * cur_weight = weight;


	for (int i=0; i<n_neuron; i++) {
		BYTE acc = bias[i];
		BYTE acc_hw = 0;
		acc_hw = accelCore_->apply(source, cur_weight, n_input, n_input, bias[i]);
		for (int j=0; j<n_input; j++) {
			acc += *(cur_weight++) * source[j];
		}
		assert(fct(acc) == acc_hw);
		//printf("old %i, new %i \n", fct(acc), acc_hw);
		value[i] = fct(acc); //Binary result
		value[i] = acc_hw; //Binary result
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

	BYTE * cur_weight = weight;

    for (int i=0; i<n_neuron; i++) {
        printf("Neuron %i: %f, {", i+1, bias[i]);
        for (int j=0; j<n_input; j++) {
            if (j!=0) printf(", %2.2f", *(cur_weight++));
            else printf("%2.2f", *(cur_weight++));
        }
        printf("}, %f\r\n",value[i]);
    }
}
