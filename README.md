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