################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/RiskClientSocket.cpp \
../src/RiskServerApp.cpp \
../src/RiskServerHandler.cpp \
../src/Room.cpp 

OBJS += \
./src/RiskClientSocket.o \
./src/RiskServerApp.o \
./src/RiskServerHandler.o \
./src/Room.o 

CPP_DEPS += \
./src/RiskClientSocket.d \
./src/RiskServerApp.d \
./src/RiskServerHandler.d \
./src/Room.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -D_VERSION='"2.3.9.3"' -DLINUX -I/home/mihaibirsan/Software/jsoncpp-src-0.5.0/include -I/home/mihaibirsan/Software/Sockets-2.3.9.3 -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


