###Using cparser and libfirm to compile the floating math-library from
https://github.com/f32c/f32c/tree/master/src/lib/src for rv32im and rv32imf
and run it (rv32im) on picorv32 (https://github.com/cliffordwolf/picorv32)
with iverilog (https://github.com/steveicarus/iverilog) and
and rv32imf on pulpino (https://github.com/pulp-platform/riscv)
verilator (https://www.veripool.org/wiki/verilator) .


#####Compilation of binutils, cparser, libfirm:      
> make

To try rv32im:
> cd samples/es
> make -r -f makerv32im

For running it on picorv32(python3 and iverilog installation required):
first build the simulation:    
> ./buildsim.sh  

then run it:      
> ./simv  


To try rv32imf:
> cd samples/es
> make -r -f makerv32imf

For running it on pulpino(verilator installation required):
first build the simulation:    
> cd samples/es/verilator-model
> make

then run it:      
> ./testbench ../result_rv32imf/firmware.bin