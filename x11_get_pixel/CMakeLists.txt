cmake_minimum_required(VERSION 3.25)
project(x11_get_pixel)

set(CMAKE_C_STANDARD 99)
add_executable(x11_get_pixel x11_get_pixel.c)
target_link_libraries(x11_get_pixel X11)