#
# Makefile for Libs
RESDIR = ../result_rv32im/
CC = ../../../cparser/build/debug/cparser
AS = ../../../binutils/as/as
AR = ../../../binutils/ar/ar 
CFLAGS = -S --target=riscv32 -I ../include -include sys/param.h


CSRCS = $(wildcard *.c)
ASRCS = $(patsubst %.c,%.s,$(CSRCS))
OSRCS = $(patsubst %.c,%.o,$(CSRCS))
OBJS = $(addprefix $(RESDIR), $(OSRCS)) 
BIN = $(RESDIR)libfloat.a

.PHONY:		all

.PRECIOUS: $(RESDIR)%.s

all:		$(BIN)

$(RESDIR)%.s:%.c
	export CPARSER_PP=cpp; \
	echo $(CPARSER_PP); \
	$(CC) -o $@ $(CFLAGS) $<

$(RESDIR)%.o:$(RESDIR)%.s
	$(AS) -o $@ $<

$(BIN):$(OBJS)
	$(AR) -rsv $@ $^
	rm -f $(OBJS)

