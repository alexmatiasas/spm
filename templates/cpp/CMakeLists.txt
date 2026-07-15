cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(include)

add_executable(${PROJECT_NAME} src/main.cpp)

enable_testing()
add_subdirectory(tests)