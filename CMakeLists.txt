cmake_minimum_required(VERSION 3.16)

project(demo-settings VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准与 AUTOMOC
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

# WIN32：Windows 下不弹 cmd 窗口（其它平台自动忽略）
add_executable(${PROJECT_NAME} WIN32 main.cpp range_selector.cpp recorder.cpp chatbox.cpp)

# 产物名称：Windows 为 demo-settings.exe，macOS 为 demo-settings-macos
if(APPLE)
    set(SETTINGS_OUTPUT_NAME "demo-settings-macos")
else()
    set(SETTINGS_OUTPUT_NAME "demo-settings")
endif()

# 输出目录：项目根下的 build/
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME ${SETTINGS_OUTPUT_NAME}
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets)
