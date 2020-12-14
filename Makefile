PR_NAME := template

#
SRC   := ./src
INC   := ./include
LIBS  := ./libs
BUILD := ./build
OBJ   := $(BUILD)/obj

SRCS_USER := $(shell find $(SRC) -name "*.c")
SRCS_LIBS := $(shell find $(LIBS) -name "*.c")

OBJS_USER := $(patsubst $(SRC)/%.c, $(OBJ)/src/%.o, $(SRCS_USER))
OBJS_LIBS := $(patsubst $(LIBS)/%.c, $(OBJ)/libs/%.o, $(SRCS_LIBS))

SRCS := $(SRCS_USER) $(SRCS_LIBS)
OBJS := $(OBJS_USER) $(OBJS_LIBS)

#
CC = xtensa-lx106-elf-gcc
CFLAGS = -I$(SRC) -I$(INC) -I$(LIBS) -DICACHE_FLASH -mlongcalls -w
LDLIBS = -nostdlib -Wl,--start-group -lmain -ldriver -lnet80211 -lwpa -llwip -lpp -lphy -lc -Wl,--end-group -lgcc
LDFLAGS = -Teagle.app.v6.ld

#
all: $(BUILD)/$(PR_NAME)-0x00000.bin

$(BUILD)/$(PR_NAME)-0x00000.bin: $(BUILD)/$(PR_NAME)
	esptool.py elf2image $^

$(BUILD)/$(PR_NAME)-0x10000.bin: $(BUILD)/$(PR_NAME)-0x00000.bin

$(BUILD)/$(PR_NAME): $(OBJS)
	$(CC) $^ $(LDLIBS) $(LDFLAGS) -o $@

$(OBJ)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): $(SRCS)

flash: $(BUILD)/$(PR_NAME)-0x00000.bin $(BUILD)/$(PR_NAME)-0x10000.bin
	esptool.py write_flash 0 $(word 1,$^) 0x10000 $(word 2,$^)

clean:
	rm -fr ./build/

.PHONY: flash clean all
