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

## 构建相关

通过参考 `/Users/morya/ws/live/capture/mini-push-all/mini-pusher/.github/workflows/build.yml` 编写当前项目的 build.yml 文件。

- 我需要 qt 版本是 6.8.x 
- 构建os要求（不需要其它操作系统支持）
    - windows 11 x64
    - macos arm64
- 不需要参考 M项目 build.yml 关于上游依赖的部分
- 需要自定义输出构建名称 为 `demo-settings.exe`, `demo-settings-macos`
- 构建输出目录为 `/Users/morya/ws/live/capture/mini-push-all/demoqt/build`
- 需要提供构建 artifact
    - `demo-settings.exe`
    - `demo-settings-macos`

## 构建结果（CI 已验证全绿）

workflow `Build and Package`（`.github/workflows/build.yml`），产物为**完整可运行包**（参照 mini-pusher 的部署逻辑，含全部 Qt 运行时依赖，下载解压即用）：

| job | runner | 部署方式 | artifact |
| --- | --- | --- | --- |
| `build-windows` | windows-2022 (x64, MSVC) | windeployqt --release | `demo-settings-windows`（release/ 整目录：exe + Qt DLL + plugins） |
| `build-macos` | macos-15 (arm64) | macdeployqt | `demo-settings-macos`（release/ 整目录：内嵌 Qt frameworks 的 `demo-settings-macos.app`） |

Qt 版本均为 6.8.3。macOS 侧为支撑 macdeployqt，CMake 输出改为 `.app` bundle（bare 可执行文件无法内嵌 frameworks）。

历史修复记录：

1. **Windows 产物路径落空**：MSBuild 多配置生成器仅设置 `RUNTIME_OUTPUT_DIRECTORY` 时会追加 `Release/` 子目录，导致 exe 实际落在 `build/Release/` 而 upload-artifact 找不到文件。修复：`CMakeLists.txt` 逐配置设置 `RUNTIME_OUTPUT_DIRECTORY_DEBUG/RELEASE/RELWITHDEBINFO/MINSIZEREL` 指向 `build/` 根（提交 `87f29d7`）。
2. **macOS job 排队即被取消**：`macos-14` runner 镜像已于 2026-11-02 退役，job 无 runner 可用、1 秒内被取消。修复：改用 `macos-15`（M1 arm64，满足 macos arm64 要求）（提交 `ce80f2c`）。
3. **产物只有裸 exe、无 Qt 依赖不可运行**：重写 build.yml，构建后以 windeployqt/macdeployqt 部署 Qt 运行时并上传整个 release 目录（macOS 需 bundle 形态，故 CMake 加 `MACOSX_BUNDLE`）。