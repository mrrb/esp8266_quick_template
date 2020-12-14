PR_NAME := template

#
SRC    := ./src
INC    := ./include
LIBS   := ./libs
DRIVER := ./driver

BUILD := ./build
OBJ   := $(BUILD)/obj

SRCS_USER   := $(shell find $(SRC) -name "*.c")
SRCS_LIBS   := $(shell find $(LIBS) -name "*.c")
SRCS_DRIVER := $(shell find $(DRIVER) -name "*.c")

OBJS_USER   := $(patsubst $(SRC)/%.c, $(OBJ)/src/%.o, $(SRCS_USER))
OBJS_LIBS   := $(patsubst $(LIBS)/%.c, $(OBJ)/libs/%.o, $(SRCS_LIBS))
OBJS_DRIVER := $(patsubst $(DRIVER)/%.c, $(OBJ)/driver/%.o, $(SRCS_DRIVER))

SRCS := $(SRCS_USER) $(SRCS_LIBS) $(SRCS_DRIVER)
OBJS := $(OBJS_USER) $(OBJS_LIBS) $(OBJS_DRIVER)

#
CC = xtensa-lx106-elf-gcc
CFLAGS = -I$(SRC) -I$(INC) -I$(LIBS) -I$(DRIVER) -DICACHE_FLASH -mlongcalls -std=gnu11
LDLIBS = -nostdlib -Wl,--start-group -lmain -lnet80211 -lwpa -llwip -lpp -lphy -lc -Wl,--end-group -lgcc
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
