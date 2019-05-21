###Using cparser and libfirm to compile the softfloat library from
https://github.com/f32c/f32c/tree/master/src/lib/src for riscv32
and run it on picorv32 (https://github.com/cliffordwolf/picorv32)
with iverilog (https://github.com/steveicarus/iverilog).

#####Compilation of binutils, cparser, libfirm and samples:      
> make


For running it on picorv32(python3 and iverilog installation required):
> cd samples/es  

First build the simulation:    
> ./buildsim.sh  

Then run it:      
> ./simv  

