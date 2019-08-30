get_filename_component(CPP_THIRD_ZLIB_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

file(GLOB CPP_THIRD_ZLIB_H ${CPP_THIRD_ZLIB_CMAKE_DIR}/*.h)
file(GLOB CPP_THIRD_ZLIB_C ${CPP_THIRD_ZLIB_CMAKE_DIR}/*.c)
file(GLOB CPP_THIRD_ZLIB_CPP ${CPP_THIRD_ZLIB_CMAKE_DIR}/*.cpp)

set(CPP_THIRD_ZLIB_INC
        ${CPP_THIRD_ZLIB_CMAKE_DIR}
        )

set(CPP_THIRD_ZLIB_INCLUDE
        )

if(WIN32)
    set(CPP_THIRD_ZLIB_SRC
            ${CPP_THIRD_ZLIB_H}
            ${CPP_THIRD_ZLIB_C}
            ${CPP_THIRD_ZLIB_CPP})
else()
    set(CPP_THIRD_ZLIB_SRC
            ${CPP_THIRD_ZLIB_CMAKE_DIR}/zip.h
            ${CPP_THIRD_ZLIB_CMAKE_DIR}/ioapi.h
            ${CPP_THIRD_ZLIB_CMAKE_DIR}/crypt.h
            ${CPP_THIRD_ZLIB_CMAKE_DIR}/zip.c
            ${CPP_THIRD_ZLIB_CMAKE_DIR}/ioapi.c
            )
endif()
