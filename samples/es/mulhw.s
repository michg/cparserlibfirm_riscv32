.text
.p2align 4,,15
.globl __mulsi3 
__mulsi3:
mul x10, x10, x11
ret
.p2align 4,,15
.globl __muldi3 
__muldi3:
mulhu x11, x10, x12
mul x10, x10, x12
ret
