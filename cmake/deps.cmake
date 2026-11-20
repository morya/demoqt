# OBS frontend 模型的依赖获取复刻（简化版 obs-studio cmake/common/buildspec_common.cmake）
#
# 语义与上游一致：
#   - 依赖版本清单（日期 + SHA256）内嵌于 CMakePresets.json 的 vendor 字段；
#   - configure 期 file(DOWNLOAD + EXPECTED_HASH) 拉 obs-deps releases / CEF CDN，
#     解压到 .deps/，hash 哨兵文件实现幂等与换版自动重解；
#   - qt6/prebuilt 接入 CMAKE_PREFIX_PATH，CEF 以 CEF_ROOT_DIR 缓存暴露。
# 与上游的差异（有意为之）：
#   - 仅 windows-x64 / macos-arm64 两平台；
#   - 无 universal/x86/arm64-cross 分支；
#   - helloworld 不链接这些依赖，仅演示获取与布局面。

# _get_dependency_data: 从 CMakePresets.json 的 hidden preset "dependencies" 读 vendor 清单
function(_get_dependency_data variable_name)
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/CMakePresets.json" preset_data)

  string(JSON presets_count ERROR_VARIABLE presets_error LENGTH "${preset_data}" "configurePresets")
  if(presets_error)
    message(FATAL_ERROR "Unable to read configurePresets from CMakePresets.json: ${presets_error}")
  endif()

  set(found_index -1)
  math(EXPR last_index "${presets_count} - 1")
  foreach(index RANGE 0 ${last_index})
    string(JSON preset_name GET "${preset_data}" "configurePresets" ${index} "name")
    if(preset_name STREQUAL "dependencies")
      set(found_index ${index})
      break()
    endif()
  endforeach()

  if(found_index EQUAL -1)
    message(FATAL_ERROR "CMakePresets.json must contain a hidden preset named 'dependencies' with vendor dependencies")
  endif()

  string(JSON dependency_data GET "${preset_data}" "configurePresets" ${found_index} "vendor" "demoqt" "dependencies")
  set(${variable_name} "${dependency_data}" PARENT_SCOPE)
endfunction()

# _check_dependencies: 按平台下载/校验/解压 prebuilt、qt6、cef 三件套
function(_check_dependencies)
  if(WIN32)
    set(arch "x64")
    set(platform "windows-x64")
    set(prebuilt_filename "windows-deps-VERSION-ARCH.zip")
    set(qt6_filename "windows-deps-qt6-VERSION-ARCH.zip")
    set(cef_filename "cef_binary_VERSION_windows_ARCH_REVISION.zip")
  elseif(APPLE)
    if(NOT CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
      message(FATAL_ERROR "This project only supports macOS arm64 (got CMAKE_OSX_ARCHITECTURES='${CMAKE_OSX_ARCHITECTURES}')")
    endif()
    set(arch "arm64")
    set(platform "macos-arm64")
    set(prebuilt_filename "macos-deps-VERSION-ARCH.tar.xz")
    set(qt6_filename "macos-deps-qt6-VERSION-ARCH.tar.xz")
    set(cef_filename "cef_binary_VERSION_macos_ARCH_REVISION.tar.xz")
  else()
    message(FATAL_ERROR "Unsupported platform (this demo only targets windows-x64 and macos-arm64)")
  endif()

  set(dependencies_dir "${CMAKE_CURRENT_SOURCE_DIR}/.deps")
  set(prebuilt_destination "obs-deps-VERSION-ARCH")
  set(qt6_destination "obs-deps-qt6-VERSION-ARCH")
  set(cef_destination "cef_binary_VERSION_${platform}")

  _get_dependency_data(dependency_data)

  foreach(dependency IN ITEMS prebuilt qt6 cef)
    string(JSON data GET "${dependency_data}" ${dependency})
    string(JSON version GET "${data}" "version")
    string(JSON hash GET "${data}" "hashes" ${platform})
    string(JSON url GET "${data}" "baseUrl")
    string(JSON label GET "${data}" "label")
    string(JSON revision ERROR_VARIABLE revision_error GET "${data}" "revision" ${platform})

    set(file "${${dependency}_filename}")
    string(REPLACE "VERSION" "${version}" file "${file}")
    string(REPLACE "ARCH" "${arch}" file "${file}")
    if(revision_error)
      string(REPLACE "_REVISION" "" file "${file}")
    else()
      string(REPLACE "_REVISION" "_v${revision}" file "${file}")
    endif()

    set(destination "${${dependency}_destination}")
    string(REPLACE "VERSION" "${version}" destination "${destination}")
    string(REPLACE "ARCH" "${arch}" destination "${destination}")

    # hash 哨兵：同版命中则整个下载/解压链路 skip（对应上游 _check_deps_version 的简化）
    set(marker "${dependencies_dir}/.dependency_${dependency}_${platform}.sha256")
    if(EXISTS "${marker}")
      file(READ "${marker}" marker_hash)
      if(marker_hash STREQUAL hash AND EXISTS "${dependencies_dir}/${destination}")
        message(STATUS "Setting up ${label} (${arch}) - skipped")
        continue()
      endif()
    endif()

    if(dependency STREQUAL cef)
      set(url "${url}/${file}")
    else()
      set(url "${url}/${version}/${file}")
    endif()

    if(NOT EXISTS "${dependencies_dir}/${file}")
      message(STATUS "Downloading ${url}")
      file(DOWNLOAD "${url}" "${dependencies_dir}/${file}.tmp" STATUS download_status EXPECTED_HASH SHA256=${hash})
      list(GET download_status 0 error_code)
      list(GET download_status 1 error_message)
      if(error_code)
        file(REMOVE "${dependencies_dir}/${file}.tmp")
        message(FATAL_ERROR "Unable to download ${url}: ${error_message}")
      endif()
      file(RENAME "${dependencies_dir}/${file}.tmp" "${dependencies_dir}/${file}")
      message(STATUS "Downloading ${url} - done")
    endif()

    file(REMOVE_RECURSE "${dependencies_dir}/${destination}")
    file(MAKE_DIRECTORY "${dependencies_dir}/${destination}")
    file(ARCHIVE_EXTRACT INPUT "${dependencies_dir}/${file}" DESTINATION "${dependencies_dir}/${destination}")
    file(WRITE "${marker}" "${hash}")

    if(dependency STREQUAL qt6 OR dependency STREQUAL prebuilt)
      list(APPEND CMAKE_PREFIX_PATH "${dependencies_dir}/${destination}")
    elseif(dependency STREQUAL cef)
      set(CEF_ROOT_DIR "${dependencies_dir}/${destination}" CACHE PATH "CEF root directory" FORCE)
    endif()

    message(STATUS "Setting up ${label} (${arch}) - done")
  endforeach()

  list(REMOVE_DUPLICATES CMAKE_PREFIX_PATH)
  set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" CACHE PATH "CMake prefix search path" FORCE)
endfunction()
