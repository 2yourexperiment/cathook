CC=g++
CFLAGS=-std=gnu++11 -D_POSIX=1 -DRAD_TELEMETRY_DISABLED -DLINUX=1 -D_LINUX=1 -DPOSIX=1 -DGNUC=1 -DNO_MALLOC_OVERRIDE -O3 -w -c -shared -Wall -Wno-unknown-pragmas -fmessage-length=0 -m32 -fvisibility=hidden -fPIC
CFLAGS+=-D__DRM_HWID_0='$(HWID_0)' -D__DRM_HWID_1='$(HWID_1)' -D__DRM_HWID_2='$(HWID_2)' -D__DRM_HWID_3='$(HWID_3)' -D__DRM_NAME='"$(DRM_NAME)"' -D__DRM_EXPIRES='$(DRM_EXPIRES)' -DCATHOOK_BUILD_NUMBER='"$(COUNTER)"'
CINCLUDES=-I../../ssdk/public -I../../ssdk/mathlib -I../../ssdk/common -I../../ssdk/public/tier1 -I../../ssdk/public/tier0
LDFLAGS=-m32 -fno-gnu-unique -D_GLIBCXX_USE_CXX11_ABI=0 -shared
LDLIBS=-Bstatic -lvstdlib -lstdc++ -lc -ltier0
OBJ_DIR := obj
BIN_DIR := bin
SRC_DIR := src
OUT_NAME := libcathook.so
SOURCES := $(wildcard $(SRC_DIR)/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/copypasted/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/hacks/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/hooks/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/sdk/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/gui/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/ipc/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/segvcatch/*.cpp)
SOURCES += $(wildcard $(SRC_DIR)/targeting/*.cpp)
OBJECTS := $(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(patsubst %.cpp,%.o,$(SOURCES)))



.PHONY: clean directories

all: clean directories cathook

directories:
	mkdir -p bin
	mkdir -p obj
	mkdir -p obj/copypasted
	mkdir -p obj/hacks
	mkdir -p obj/hooks
	mkdir -p obj/sdk
	mkdir -p obj/gui
	mkdir -p obj/ipc
	mkdir -p obj/segvcatch
	mkdir -p obj/targeting

echo: $(OBJECTS)
	echo $(OBJECTS)

$(OBJECTS):
	echo Compiling $(patsubst %.o,%.cpp,$(patsubst $(OBJ_DIR)/%,$(SRC_DIR)/%,$@))
	$(CC) $(CFLAGS) $(CINCLUDES) $(patsubst %.o,%.cpp,$(patsubst $(OBJ_DIR)/%,$(SRC_DIR)/%,$@)) -o $@

cathook: $(OBJECTS)
	LIBRARY_PATH=/home/cat/cathook/tf2-internal/cathook/lib $(CC) -o $(BIN_DIR)/$(OUT_NAME) $(LDFLAGS) $(LDLIBS) $(OBJECTS)
	strip --strip-all $(BIN_DIR)/$(OUT_NAME)

clean:
	rm -rf bin
	rm -rf obj