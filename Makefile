#
# 'make'        build executable file 'main'
# 'make clean'  removes all .o and executable files
#

# define the Cpp compiler to use
# CC	= armv7a-linux-androideabi21-clang
# CXX = armv7a-linux-androideabi21-clang++
# CC	= aarch64-linux-android21-clang
# CXX = aarch64-linux-android21-clang++
# CC	= gcc
CXX = g++
AR 	= ar

# define any compile-time flags
CMDFLAGS 	:=
CFLAGS		:= -fPIC
CXXFLAGS	:= -Wall -Wextra -fPIC -g
ARFLAGS		:= -rcs 

# define library paths in addition to /usr/lib
#   if I wanted to include libraries not in /usr/lib I'd specify
#   their path using -Lpath, something like:
LFLAGS =

# define output directory
OUTPUT	:= output

# define source directory
SRC		:= src

# define include directory
INCLUDE	:= include

# define lib directory
LIB		:= lib

LIBLIAZ:= libliaz
LIAZLIB:= liazlib

ifeq ($(OS),Windows_NT)
MAIN	:= main.exe
SOURCEDIRS	:= $(SRC)
INCLUDEDIRS	:= $(INCLUDE)
LIBDIRS		:= $(LIB)
FIXPATH = $(subst /,\,$1)
RM			:= del /q /f
MD	:= mkdir
JNIMDINCLUDE:= win32
else
MAIN	:= main
SOURCEDIRS	:= $(shell find $(SRC) -type d)
INCLUDEDIRS	:= $(shell find $(INCLUDE) -type d)
LIBDIRS		:= $(shell find $(LIB) -type d)
FIXPATH = $1
RM = rm -f
MD	:= mkdir -p
ifeq ($(shell uname),Darwin)
JNIMDINCLUDE := darwin 
else
JNIMDINCLUDE := linux
endif
endif

# define any directories containing header files other than /usr/include
INCLUDES	:= $(patsubst %,-I%,$(INCLUDEDIRS:%/=%))

# define the C libs
LIBS		:= $(patsubst %,-L%,$(LIBDIRS:%/=%))

# define the C source files
CSOURCES		:= $(wildcard $(patsubst %,%/*.c,$(SOURCEDIRS)))
CPPSOURCES		:= $(wildcard $(patsubst %,%/*.cpp,$(SOURCEDIRS)))

# define the C object files
OBJECTS		:= $(CSOURCES:.c=.o) $(CPPSOURCES:.cpp=.o)

LIBOBJECTS	:= $(filter-out src/main.o,$(OBJECTS))

# define the dependency output files
DEPS		:= $(OBJECTS:.o=.d)

#
# The following part of the makefile is generic; it can be used to
# build any executable just by changing the definitions above and by
# deleting dependencies appended to the file from 'make depend'
#

OUTPUTMAIN		:= $(call FIXPATH,$(OUTPUT)/$(MAIN))
OUTPUTSTATICLIB	:= $(call FIXPATH,$(OUTPUT)/$(LIBLIAZ))
OUTPUTDYNAMICLIB:= $(call FIXPATH,$(OUTPUT)/$(LIBLIAZ))

all: $(OUTPUT) $(MAIN)
	@echo Executing 'all' complete!

static-compile-32: $(OUTPUT) $(LIBLIAZ)-32
	@echo Executing 'static-compile-32' complete!

static-compile-64: $(OUTPUT) $(LIBLIAZ)-64
	@echo Executing 'static-compile-64' complete!

dynamic-compile-32: $(OUTPUT) $(LIAZLIB)-32
	@echo Executing 'dynamic-compile-32' complete!

dynamic-compile-64: $(OUTPUT) $(LIAZLIB)-64
	@echo Executing 'dynamic-compile-64' complete!

$(OUTPUT):
	$(MD) $(OUTPUT)

$(LIBLIAZ)-32: $(OBJECTS) 
	@echo $(LIBOBJECTS)
	@echo AR $(ARFLAGS) $(OUTPUTSTATICLIB)-i386.a $(LIBOBJECTS)
	$(AR) $(ARFLAGS) $(OUTPUTSTATICLIB)-i386.a $(LIBOBJECTS)

$(LIBLIAZ)-64: $(OBJECTS) 
	@echo $(LIBOBJECTS)
	@echo AR $(ARFLAGS) $(OUTPUTSTATICLIB)-x86-64.a $(LIBOBJECTS) $(LIBS)
	$(AR) $(ARFLAGS) $(OUTPUTSTATICLIB)-x86-64.a $(LIBOBJECTS) $(LIBS)

$(LIAZLIB)-32: $(OBJECTS)
	@echo $(LIBOBJECTS)
	@echo CXX -shared -fPIC $(CMDFLAGS) -o $(OUTPUTDYNAMICLIB)-arm-v7.so $(LIBOBJECTS) $(LIBS)
	$(CXX) -shared -fPIC $(CMDFLAGS) -o $(OUTPUTDYNAMICLIB)-arm-v7.so $(LIBOBJECTS) $(LIBS)

$(LIAZLIB)-64: $(OBJECTS)
	@echo $(LIBOBJECTS)
	@echo CXX -shared -fPIC $(CMDFLAGS) -o $(OUTPUTDYNAMICLIB)-arm-v8.so $(LIBOBJECTS) $(LIBS)
	$(CXX) -shared -fPIC $(CMDFLAGS) -o $(OUTPUTDYNAMICLIB)-arm-v8.so $(LIBOBJECTS) $(LIBS)

$(MAIN): $(OBJECTS)
	@echo $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(OUTPUTMAIN) $(OBJECTS) $(LFLAGS) $(LIBS)

# include all .d files
-include $(DEPS)

# this is a suffix replacement rule for building .o's and .d's from .c's
# it uses automatic variables $<: the name of the prerequisite of
# the rule(a .c file) and $@: the name of the target of the rule (a .o file)
# -MMD generates dependency output files same name as the .o file
# (see the gnu make manual section about automatic variables)
.c.o:
	@echo CC $(CFLAGS) $(CMDFLAGS) $(INCLUDES) -c -MMD $< -o $@ 
	$(CC) $(CFLAGS) $(CMDFLAGS) $(INCLUDES) -c -MMD $< -o $@

.cpp.o:
	@echo CXX $(CXXFLAGS) $(CMDFLAGS) $(INCLUDES) -c -MMD $< -o $@
	$(CXX) $(CXXFLAGS) $(CMDFLAGS) $(INCLUDES) -c -MMD $< -o $@

.PHONY: clean
clean:
	$(RM) $(OUTPUTMAIN)
	$(RM) $(OUTPUTSTATICLIB)*.a
	$(RM) $(OUTPUTDYNAMICLIB)*.so
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	@echo Cleanup complete!

static32: static-compile-32
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	@echo Executing 'static32: static-compile-32' compile! 

static64: static-compile-64
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	@echo Executing 'static64: static-compile-64' compile! 

dynamic32: dynamic-compile-32 
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	@echo Executing 'dynamic32: dynamic-compile-32' compile!

dynamic64: dynamic-compile-64
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	@echo Executing 'dynamic64: dynamic-compile-64' compile!

run: all
	$(RM) $(call FIXPATH,$(OBJECTS))
	$(RM) $(call FIXPATH,$(DEPS))
	./$(OUTPUTMAIN)
	@echo Executing 'run: all' complete!
