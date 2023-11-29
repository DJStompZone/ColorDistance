CC = gcc
CFLAGS = -O2 -Wall -fPIC
TARGET = color_distance
SRC = color_distance.c
PYTHON_VERSIONS = 3.8 3.9 3.10 3.11 3.12

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PYTHON_VERSION = $(shell for ver in $(PYTHON_VERSIONS); do \
        if [ -d "/usr/include/python$$ver" ]; then \
            echo $$ver; \
            break; \
        fi; \
    done)
endif
ifeq ($(UNAME_S),Darwin)
    PYTHON_VERSION = $(shell for ver in $(PYTHON_VERSIONS); do \
        if [ -d "/usr/include/python$$ver" ]; then \
            echo $$ver; \
            break; \
        fi; \
    done)
endif
ifeq ($(OS),Windows_NT)
    PYTHON_VERSION = $(shell for ver in $(PYTHON_VERSIONS); do \
        if [ -d "$$LOCALAPPDATA/Programs/Python/Python$$ver/include" ]; then \
            echo $$ver; \
            break; \
        fi; \
    done)
endif

ifeq ($(PYTHON_VERSION),)
    $(error Python headers not found)
endif

all: $(TARGET).so

$(TARGET).so: $(SRC)
	$(CC) $(CFLAGS) -shared -o $(TARGET).so $(SRC) -I/usr/include/python$(PYTHON_VERSION) -lpython$(PYTHON_VERSION)

clean:
	rm -f $(TARGET).so

.PHONY: all clean
