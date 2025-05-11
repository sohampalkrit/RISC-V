# Target Raspberry Pi version
RPI_VERSION ?= 2B

# Output directory
BOOTMNT ?= .

# ARM Toolchain
ARMGNU ?= arm-none-eabi

# Compiler flags
COPS = -Wall -nostdlib -nostartfiles -ffreestanding \
    -mcpu=cortex-a7 -marm -Iinclude -DRPI_VERSION=2

ASMOPS = -Iinclude

BUILD_DIR = build
SRC_DIR = src

# Source files (includes ALL .c files including mini_uart.c)
C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)

OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%.s.o)

DEP_FILES = $(OBJ_FILES:.o=.d)
-include $(DEP_FILES)

all: kernel7.img

clean:
	rm -rf $(BUILD_DIR) *.img

$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@ 

$(BUILD_DIR)/%.s.o: $(SRC_DIR)/%.S
	mkdir -p $(dir $@)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@ 

kernel7.img: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	@echo "Building for Raspberry Pi $(RPI_VERSION)"
	$(ARMGNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel7.elf $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel7.elf -O binary kernel7.img

# Optional copy to SD card mount point
ifneq ($(BOOTMNT),.)
	cp kernel7.img $(BOOTMNT)/kernel7.img
endif
	sync

run: kernel7.img
	qemu-system-arm -M raspi2b -kernel kernel7.img -serial stdio -display none
