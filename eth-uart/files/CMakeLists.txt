cmake_minimum_required (VERSION 2.8)

project (eth-uart)

add_definitions(-Wall -D _GNU_SOURCE)

add_executable(eth-uart eth-uart.c)
target_link_libraries(eth-uart iniparser)
install (TARGETS eth-uart DESTINATION bin)
