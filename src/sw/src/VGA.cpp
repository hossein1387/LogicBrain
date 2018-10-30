#include "VGA.h"
#include "io.h"

//-------------------------------------------------------------------------
void VGA::clr() {
  int x;
  for (x=0;x<640*480/4;x++) {
     IOWR(memory_address, x, 0x0);
  }
}
