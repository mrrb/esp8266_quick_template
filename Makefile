PR_NAME := template

#
SRC   := ./src
INC   := ./include
BUILD := ./build
OBJ   := $(BUILD)/obj

SRCS := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(SRCS))


#
CC = xtensa-lx106-elf-gcc
CFLAGS = -I$(SRC) -I$(INC) -DICACHE_FLASH -mlongcalls
LDLIBS = -nostdlib -Wl,--start-group -lmain -lnet80211 -lwpa -llwip -lpp -lphy -lc -Wl,--end-group -lgcc
LDFLAGS = -Teagle.app.v6.ld

#
all: $(BUILD)/$(PR_NAME)-0x00000.bin

$(BUILD)/$(PR_NAME)-0x00000.bin: $(BUILD)/$(PR_NAME)
	esptool.py elf2image $^

$(BUILD)/$(PR_NAME)-0x10000.bin: $(BUILD)/$(PR_NAME)-0x00000.bin

$(BUILD)/$(PR_NAME): $(OBJS)
	$(CC) $^ $(LDLIBS) $(LDFLAGS) -o $@

$(OBJ)/%.o: $(SRC)/%.c
	mkdir -p $(OBJ)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): $(SRCS)

flash: $(BUILD)/$(PR_NAME)-0x00000.bin $(BUILD)/$(PR_NAME)-0x10000.bin
	esptool.py write_flash 0 $(word 1,$^) 0x10000 $(word 2,$^)

clean:
	rm -fr ./build/

.PHONY: flash clean all
