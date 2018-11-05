#include "stdafx.h"
#include <fstream>

#ifndef PE_H_
#define PE_H_

class PE {
public:
	PE(BYTE peSize);
	~PE();

	BYTE apply(BYTE* image, BYTE* weight);

private:
	BYTE peSize_;

};

#endif 
