CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
PROJECT (INIPARSER)

SET (SRC_LIST dictionary iniparser)
ADD_LIBRARY (iniparser SHARED ${SRC_LIST})

set_target_properties(iniparser PROPERTIES VERSION 4.1 SOVERSION 4)

install(TARGETS iniparser DESTINATION /usr/lib)
