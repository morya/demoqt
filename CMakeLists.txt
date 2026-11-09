cmake_minimum_required(VERSION 3.16)

project(demo-settings VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准与 AUTOMOC
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

# WIN32：Windows 下不弹 cmd 窗口；MACOSX_BUNDLE：macOS 下生成 .app
# bundle（macdeployqt 只支持 bundle 形态，bare exe 无法内嵌 Qt frameworks）
add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE main.cpp)

# 产物名称：Windows 为 demo-settings.exe，macOS 为 demo-settings-macos(.app)
if(APPLE)
    set(SETTINGS_OUTPUT_NAME "demo-settings-macos")
else()
    set(SETTINGS_OUTPUT_NAME "demo-settings")
endif()

# 输出目录：项目根下的 build/
# 多配置生成器（Windows MSBuild/VS）仅设 RUNTIME_OUTPUT_DIRECTORY 会追加
# Release/ 等子目录，必须逐配置设置，产物才真正落在 build/ 根。
set(SETTINGS_BUILD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/build)
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME ${SETTINGS_OUTPUT_NAME}
    RUNTIME_OUTPUT_DIRECTORY ${SETTINGS_BUILD_DIR}
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${SETTINGS_BUILD_DIR}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${SETTINGS_BUILD_DIR}
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${SETTINGS_BUILD_DIR}
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${SETTINGS_BUILD_DIR})

if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_BUNDLE_NAME "demo-settings"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.gouboyun.demo-settings"
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION})
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets)
