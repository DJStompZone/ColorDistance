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
        if [ -d "/Users/desco/.pyenv/versions/3.$$ver/include/python3.$$ver" ]; then \
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

# Use Python to find the include path
PYTHON_INCLUDE_PATH = $(shell python3 -c "import sysconfig; print(sysconfig.get_path('include'))")
# Dynamically set the library path based on Python version
PYTHON_LIB_PATH = $(shell python3 -c "import sysconfig; print('/'.join(sysconfig.get_path('stdlib').split('/')[:-2])+'/lib')")

FALLBACK_PYTHON_VERSION = $(shell python3 -c "import platform; print('3.'+str(platform.python_version()).split('3.')[-1].split('.')[0])")

ifeq ($(PYTHON_VERSION),)
    PYTHON_VERSION = $(FALLBACK_PYTHON_VERSION)
endif

ifeq ($(PYTHON_VERSION),)
    $(error Python headers not found)
endif

all: $(TARGET).so

$(TARGET).so: $(SRC)
	$(CC) $(CFLAGS) -shared -o $(TARGET).so $(SRC) -I$(PYTHON_INCLUDE_PATH) -L$(PYTHON_LIB_PATH) -lpython$(PYTHON_VERSION)

clean:
	rm -f $(TARGET).so

.PHONY: all clean
