cmake_minimum_required (VERSION 2.8)

project (setsbus)

add_definitions(-Wall -D _GNU_SOURCE)

add_executable(setsbus setsbus.c)
install (TARGETS setsbus DESTINATION bin)
