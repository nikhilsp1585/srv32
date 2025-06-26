#include <stdint.h>

int main() {
    // Test vector_load function
    int32_t src[4] = {0x12345678, 0xabcdef12, 0xcccfffee, 0xeefeeccc}; // Source vector
    int32_t dst[4];               // Destination vector

    asm volatile(
        "li t0, 4 \n"        // Load the address of src into t0
        "vsetvli t0, t0, e32, m1, ta, ma\n"
        "vle32.v v1, (%0)\n"   // Load vector from src into v0
        "vle32.v v2, (%0)\n" 
        "vse32.v v2, (%1)\n"  // Store vector from
        : 
        : "r"(src), "r"(dst) // Input operands
        : "t0", "v1"           // Clobbered registers
    );
    return 0;
}