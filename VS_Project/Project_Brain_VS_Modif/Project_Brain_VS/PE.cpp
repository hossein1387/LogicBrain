#include "stdio.h"
#include "PE.h"

PE::PE(BYTE peSize)
{
	peSize_ = peSize;
}

PE::~PE() {}

BYTE PE::apply(BYTE* image, BYTE* weight)
{
	BYTE result = 0;

	for (int i = 0; i < peSize_; i++) 
	{
		result += image[i] * weight[i];
	}
	return result;
}