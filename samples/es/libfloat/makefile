#
# Makefile for Libs
CC = ../../../cparser/build/debug/cparser
AS = ../../../binutils/as/as
AR = ../../../binutils/ar/ar 
CFLAGS = -S --target=riscv32 -I ../include -include sys/param.h


CSRCS = $(wildcard *.c)
ASRCS = $(patsubst %.c,%.s,$(CSRCS))
OSRCS = $(patsubst %.c,%.o,$(CSRCS))
BIN = libfloat.a

.PHONY:		all

.PRECIOUS: %.s

all:		$(BIN)

%.s:%.c
	export CPARSER_PP=cpp; \
	echo $(CPARSER_PP); \
	$(CC) $(CFLAGS) $<

%.o:%.s
	$(AS) -o $@ $<

$(BIN):$(OSRCS)
	$(AR) -rsv $@ $^

clean:
		rm -f *~ $(OSRCS) $(ASRCS) $(BIN)
