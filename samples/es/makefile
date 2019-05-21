RESDIR = result/
CC = ../../cparser/build/debug/cparser
AS = ../../binutils/as/as
AR = ../../binutils/ar/ar
LD = ../../binutils/ld/ld
CFLAGS = -S --target=riscv32 -I include -include sys/param.h -fbuiltin
LDFLAGS = -l libmath/libmath.a -l libfloat/libfloat.a
LIBS = libfloat/libfloat.a libmath/libmath.a

CSRCS = io.c es.c
ASRCS = start.s mulhw.s divhw.s
OSRCS = start.o mulhw.o divhw.o io.o es.o
OBJS = $(addprefix $(RESDIR), $(OSRCS))
BIN = $(RESDIR)firmware.bin

.PHONY:		all

.PRECIOUS: %.s

all:$(LIBS) $(RESDIR) $(BIN)

$(LIBS):
	make -r -C libfloat
	make -r -C libmath
    

$(RESDIR):
	mkdir -p $@ 

$(RESDIR)%.s:%.c
	export CPARSER_PP=cpp; \
	$(CC) $(CFLAGS) -o $@ $<

$(RESDIR)%.o:%.s
	$(AS) -o $@ $<

$(RESDIR)%.o:$(RESDIR)%.s
	$(AS) -o $@ $<

$(BIN):$(OBJS)
	$(LD) -h -o $@ $(LDFLAGS) $^
	python3 mkhex.py $(RESDIR)firmware
 

clean:
		rm -f -r $(RESDIR)
