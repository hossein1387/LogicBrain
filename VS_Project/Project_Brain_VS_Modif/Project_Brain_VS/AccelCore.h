#include "stdafx.h"
#include <vector>
#include "PE.h"
#include <assert.h>
#include <fstream>

#ifndef ACCELCORE_H_
#define ACCELCORE_H_

class AccelCore {
public:
	AccelCore(BYTE accelCoreSize);
	~AccelCore();

	BYTE apply(BYTE* input, BYTE* weight, BYTE inputSize, BYTE weightSize, BYTE bias);
	BYTE nonLinear(BYTE value);

private:

	BYTE accelCoreSize_;
	std::vector<PE*> peVector_;

};
#endif 
