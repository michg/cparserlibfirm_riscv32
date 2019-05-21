.text
.p2align 4,,15
.globl __divsi3 
__divsi3:
div x10, x10, x11
ret

.p2align 4,,15
.globl __modsi3 
__modsi3:
rem x10, x10, x11
ret

.p2align 4,,15
.globl __udivsi3 
__udivsi3:
divu x10, x10, x11
ret

.p2align 4,,15
.globl __umodsi3 
__umodsi3:
remu x10, x10, x11
ret
