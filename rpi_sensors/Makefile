# -----------------------------
# Compiler and Tools
# -----------------------------
CC := aarch64-linux-gnu-gcc

# -----------------------------
# Directories
# -----------------------------
SRC_DIRS := . i2c htu21d bmp280 db
BUILD_DIR := build
BIN_DIR := $(BUILD_DIR)/bin
OBJ_DIR := $(BUILD_DIR)/obj

# -----------------------------
# Compilation Flags
# -----------------------------
CFLAGS := -Wall -Wextra $(addprefix -I, $(SRC_DIRS))
LDFLAGS := -lsqlite3

# -----------------------------
# Source and Object Files
# -----------------------------
SRCS := main.c \
        i2c/i2c.c \
        htu21d/htu21d.c \
        bmp280/bmp280.c \
        db/db.c

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))

# -----------------------------
# Output Executable
# -----------------------------
TARGET := $(BIN_DIR)/rpi_sensors

# -----------------------------
# Default Target
# -----------------------------
all: directories $(TARGET)

# -----------------------------
# Create necessary directories
# -----------------------------
directories:
	mkdir -p $(OBJ_DIR) $(BIN_DIR) $(OBJ_DIR)/i2c $(OBJ_DIR)/htu21d $(OBJ_DIR)/bmp280 $(OBJ_DIR)/db

# -----------------------------
# Link the final binary
# -----------------------------
$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

# -----------------------------
# Compile each .c into .o
# -----------------------------
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIRS)
	$(CC) $(CFLAGS) -c $< -o $@

# -----------------------------
# Clean
# -----------------------------
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
