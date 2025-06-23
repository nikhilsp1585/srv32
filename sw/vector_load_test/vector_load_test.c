#include <stdint.h>
int main(){
    int32_t vects[4] = {0xaaaaaaaa,0xbbbbbbbb,0xcccccccc,0xdddddddd};
    asm volatile(

        "li t0, 4\n"
        "vsetvli t0, t0, e32, m1, ta, ma\n"
        "vle32.v v0, (%0)\n"
        :
        : "r"(vects)
    );
    return 0;
}