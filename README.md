# qt6 QSettings 示例

## 实现逻辑

- 启动一个极简的 QDialog 项目
- 项目名称为 `demo-settings`
- 项目路径为 `/Users/morya/ws/live/capture/mini-push-all/demoqt` （当前已经在此项目目录中）
- 页面布局
    - QLabel -> "当前登录URL:"
    - QLineEdit -> "loginUrl"
    - 按钮组
        - QPushButton -> "Save" , 点击后，将 QLineEdit 控件中的内容保存到 QSettings 中，键值为 `loginUrl`
        - QPushButton -> "Cancel" , 点击后，关闭程序
- 配置处理逻辑
    - QSettings 初始化参数设置 QSettings("gouboyun-morya", "demoqt")
    - 通过 QSettings 读取 `loginUrl` 键值，设置到 QLineEdit 控件

## 参考项目

- [mini-pusher](https://github.com/morya/mini-pusher) 后续简称 M项目
- 依赖获取模型复刻自 obs-studio 的 `cmake/common/buildspec_common.cmake` + `cmake/{windows,macos}/buildspec.cmake`（OBS frontend 模式）

## 构建相关（OBS frontend 依赖模型）

Qt 不来自在线安装器/aqt，而是 **configure 期自动拉取 obs-deps releases 预编译产物**：

| 依赖 | 来源 | 用途 |
| --- | --- | --- |
| `prebuilt` | obs-deps release `2026-10-23`（windows-deps-x64.zip / macos-deps-arm64.tar.xz） | FFmpeg 系主依赖树（helloworld 不链接，模型完整性） |
| `qt6` | 同 release 的 `windows-deps-qt6-*` / `macos-deps-qt6-*`（qtbase 子集，= Qt **6.11.1** obs-deps 自编译） | find_package 与运行时 DLL/framework 的唯一来源 |
| `cef` | `cdn-fastly.obsproject.com/downloads/cef_binary_7871_*_v2` | 仅下载解压演示（helloworld 不链接） |

机制要点：

- 版本清单（日期 + 逐平台 SHA256 + CEF revision）内嵌 `CMakePresets.json` 的 hidden preset `dependencies` 的 `vendor.demoqt.dependencies`；
- `cmake/deps.cmake` 提供 `_get_dependency_data` / `_check_dependencies`：`file(DOWNLOAD + EXPECTED_HASH SHA256)` → 解压 `.deps/` → hash 哨兵文件幂等（缓存命中只跳过下载解压，**注册 CMAKE_PREFIX_PATH 两路共用**）；
- moc/uic/rcc 位于子集的 `libexec/`（mac）或 `bin/`（win），AUTOMOC 可用；**子集不含 windeployqt/macdeployqt**（qttools 未构建），故部署为手动最小集；
- 平台矩阵：`windows-x64`（VS2022 generator）/ `macos-arm64`（Unix Makefiles + `CMAKE_OSX_ARCHITECTURES=arm64`），`cmake --preset <name>` + `cmake --build --preset <name>`。

本地构建：`cmake --preset macos-arm64 && cmake --build --preset macos-arm64`（首次 configure 下载约 300MB，走 `.deps/` 缓存）。

## 构建结果（CI 已验证全绿）

workflow `Build and Package`（`.github/workflows/build.yml`），产物为**完整可运行包**（无部署工具，手动最小集 + arm64 ad-hoc 逐二进制重签）：

| job | runner | 部署方式 | artifact |
| --- | --- | --- | --- |
| `build-windows` | windows-2022 (x64, MSVC) | 手动拷 Qt6{Core,Gui,Widgets}.dll + `platforms/qwindows.dll` + `styles/qmodernwindowsstyle.dll` + vswhere 探查 app-local VC++ CRT | `demo-settings-windows`（~11MB） |
| `build-macos` | macos-15 (arm64) | 手动装配 bundle：QtCore/Gui/Widgets.framework → `Contents/Frameworks`，libqcocoa+libqoffscreen → `Contents/PlugIns/platforms`，`install_name_tool -add_rpath @executable_path/../Frameworks` + 逐二进制 `codesign -s -` | `demo-settings-macos`（~34MB），并以 `QT_QPA_PLATFORM=offscreen` headless 冒烟实证存活 |

`.deps/` 整目录进 actions/cache（key 跟随 CMakePresets.json 清单哈希），二次构建零下载。

历史修复记录（旧安装器架构时代，留档）：

1. **Windows 产物路径落空**：MSBuild 多配置生成器仅设 `RUNTIME_OUTPUT_DIRECTORY` 会追加 `Release/` 子目录。修复：逐配置 `RUNTIME_OUTPUT_DIRECTORY_DEBUG/RELEASE/...` 指向 `build/` 根（`87f29d7`，本次改造保留）。
2. **macos-14 runner 退役**：改用 macos-15（`ce80f2c`，保留）。
3. **OBS 模型落地期的三连修**（本次改造）：
   - CMake JSON 数组长度须用 `string(JSON out LENGTH json key)` 子命令，不是 GET 尾参；
   - `find_package(Qt6)` 在缓存命中场景必失败——skip 分支曾绕过 `CMAKE_PREFIX_PATH` 注册，已改为"下载解压可跳过、注册必执行"；
   - windows-2022 镜像裸 pwsh 无 `VCToolsRedistDir`，且 `VC\Redist\MSVC\v143\` 下无直挂 `x64` 层——改为 Redist 树内探查 `vcruntime140.dll` 所在目录。
