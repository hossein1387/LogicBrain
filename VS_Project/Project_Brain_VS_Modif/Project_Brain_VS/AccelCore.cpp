#include "stdio.h"
#include "AccelCore.h"

AccelCore::AccelCore(BYTE accelCoreSize) 
{
	accelCoreSize_ = accelCoreSize;
	for (int i = 0; i < accelCoreSize_; i++)
	{
		PE* temp = new PE(8);
		peVector_.push_back(temp);
	}
}


AccelCore::~AccelCore() 
{
	for (int i = 0; i < accelCoreSize_; i++)
	{
		delete peVector_[i];
	}
}

BYTE AccelCore::nonLinear(BYTE value)
{
	if (value>0) return 1;
	else return 0;
}


BYTE AccelCore::apply(BYTE* input, BYTE* weight, BYTE inputSize, BYTE weightSize, BYTE bias) 
{
	assert((inputSize%accelCoreSize_) == 0);
	assert((weightSize%accelCoreSize_) == 0);
	assert(inputSize == weightSize);

	BYTE sum = bias;
	for (int i = 1; i <= accelCoreSize_; i++)
	{
		BYTE inputSlice[8];
		BYTE weightSlice[8];
		memcpy(inputSlice, &input[8 * (i - 1)], sizeof(short) * 8);
		memcpy(weightSlice, &weight[8 * (i - 1)], sizeof(short) * 8);
		sum += peVector_[i-1]->apply(inputSlice, weightSlice);
	}
	return nonLinear(sum);
}