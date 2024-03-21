cmake_minimum_required(VERSION 3.10)

project(reader CXX)

option(RUN_CLANG_TIDY "run clang-tidy on compile" OFF)

add_subdirectory(libs)

file(GLOB srcs "src/*.cpp")

add_custom_target(
    check
    COMMAND ${CMAKE_SOURCE_DIR}/run_clang_tidy.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEPENDS ${srcs}
    COMMENT "Running clang-tidy on source files"
)

add_custom_target(
    style
    COMMAND ${CMAKE_SOURCE_DIR}/run_clang_format.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEPENDS ${srcs}
    COMMENT "Running clang-format on source files"
)

if(RUN_CLANG_TIDY)
    message(STATUS "Compiling with clang-tidy...")
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy")
endif(RUN_CLANG_TIDY)

add_executable(${PROJECT_NAME} ${srcs})

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)

set (internal_libs ilclient revision vgfont argparse gsl-lite)

find_package(OpenSSL QUIET)
if (NOT ${OpenSSL_FOUND})
    message(FATAL_ERROR "Install OpenSSL development: sudo apt install libssl-dev")
endif()

find_library(GLOG_LIBRARY
    NAME glog
    HINTS /usr/lib/arm-linux-gnueabihf
)

if(${GLOG_LIBRARY} MATCHES "GLOG_LIBRARY-NOTFOUND")
    message(FATAL_ERROR "Install glog: sudo apt install libgoogle-glog-dev")
endif()


find_package(Threads REQUIRED)

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Threads::Threads
    ${internal_libs}
    ${OPENSSL_LIBRARIES}
    ${GLOG_LIBRARY}
)

target_include_directories(${PROJECT_NAME}
PUBLIC
    ${PROJECT_SOURCE_DIR}/src
PRIVATE
    /opt/vc/include/
    ${OPENSSL_INCLUDE_DIR}
)

file(COPY ${PROJECT_SOURCE_DIR}/samples
    DESTINATION ${PROJECT_BINARY_DIR})


target_compile_definitions(${PROJECT_NAME}
PRIVATE
    -DSTANDALONE
    -D__STDC_CONSTANT_MACROS
    -D__STDC_LIMIT_MACROS
    -DTARGET_POSIX
    -D_LINUX 
    -DPIC
    -D_REENTRANT
    -D_LARGEFILE64_SOURCE
    -D_FILE_OFFSET_BITS=64
    -DHAVE_LIBOPENMAX=2
    -DOMX -DOMX_SKIP64BIT
    -DUSE_EXTERNAL_OMX
    -DHAVE_LIBBCM_HOST
    -DUSE_EXTERNAL_LIBBCM_HOST
    -DUSE_VCHIQ_ARM
)

target_compile_options(${PROJECT_NAME}
PRIVATE
    -Wall -g -pipe -Wno-psabi -ftree-vectorize
    -fPIC -U_FORTIFY_SOURCE
)
