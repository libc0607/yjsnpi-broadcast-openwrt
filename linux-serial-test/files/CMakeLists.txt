cmake_minimum_required (VERSION 2.8)

project (linux-serial-test)

add_definitions(-Wall -D _GNU_SOURCE)

add_executable(linux-serial-test  linux-serial-test.c)
install (TARGETS linux-serial-test DESTINATION bin)
