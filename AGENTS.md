# AGENTS.md

面向 AI 编码助手（Claude Code / Cursor / Trae / Copilot / Windsurf 等）的规则文件。

## 仓库定位

`lj_flutter_package` 是 Flutter 基础组件库：网络请求、路由管理、Event Bus、调试面板、iOS 字重补偿及 20+ 常用 UI 组件。

- 完整文档与示例代码：根目录 `README.md`
- 可运行示例工程：`example/`（各组件 demo 页面在 `example/lib/demo_pages/`）
- iOS 字重标定数据：`.trae/skills/font-weight-compare/references/ios-calibration.md`

## 强制规则（基于本框架开发业务代码时）

1. **初始化**：`main()` 中必须先 `await LJUtil.initInstance()`，否则 `LJUtil.preferences` 等为 null
2. **网络请求**：统一使用 `LJNetwork.post/get/put/delete`；错误已由全局 `LJNetwork.handleAllFailureCallBack` 处理，业务层 `try-catch` 即可，不要重复弹错误提示
3. **路由跳转**：使用 `RouterManager.pushNamed/pop/replaceNamed/popUntil`，**禁止**直接使用 `Navigator.push`
4. **页面参数**：在 `initState` 的 `addPostFrameCallback` 中用 `context.argumentMap` / `context.argument` 获取，三种路由方案均支持；无 context 时可用 `RouterManager.argument` / `RouterManager.argumentMap`（动画转场期间可能参数错乱）；GoRouter 下不要拿全局 `RouterManager.context` 去调 `.argument` 扩展，会报错
5. **资源释放**：StatefulWidget 的 `dispose()` 必须释放 controller、调用 `LJEventBus.off(eventName)` 取消订阅
6. **字体字重**：统一使用 `lib/utils/lj_define.dart` 中的 `ultralight/thin/light/regular/medium/semibold/bold` 常量（iOS 自动补偿），**禁止**直接写 `FontWeight.w400` 等裸值，也不要自行使用 x50 中间字重；引用这些常量的 `TextStyle`/`Text` **不能加 `const`**（平台判断是运行时逻辑）
7. **禁止事项**：不要在 `build()` 中发起网络请求；列表分页不要用 `setState` 模拟数据流，使用 `LJRefreshListViewController`；不要重复造轮子，优先使用框架已有组件

## 组件优先级

| 场景       | 必须使用                                  | 禁止使用                 |
| ---------- | ----------------------------------------- | ------------------------ |
| 轮播图     | `LJSwiper`                                | 自行实现 PageView        |
| 网络图片   | `LJNetworkImage`                          | `Image.network`          |
| 验证码按钮 | `SendCodeButton`                          | 自行实现倒计时           |
| 底部安全区 | `BottomContainer`                         | 手动算 SafeArea          |
| 拖拽悬浮   | `LJDragContainer`                         | 自行实现 GestureDetector |
| 下拉刷新   | `LJRefreshListView` / `LJRefreshGridView` | 第三方 refresh           |
| 路由       | `RouterManager`                           | `Navigator` / `Get.to`   |
| 网络请求   | `LJNetwork`                               | 直接 `dio`               |
| 事件通信   | `LJEventBus`                              | 自行实现 Stream          |
| 字体字重   | `medium` / `regular` 等语义化字重常量     | `FontWeight.w400` 裸值   |

## 命名规范

- 文件名小写下划线 + `lj_` 前缀：`lj_network.dart`、`lj_event_bus.dart`
- 路由名以 `/` 开头：`/loginPage`、`/orderPage`

## 本仓库开发约定

- 目录职责：UI 组件放 `lib/ui_component/`，工具类放 `lib/utils/`，通用 Widget 放 `lib/widgets/`，调试相关放 `lib/debug/`
- 新增文件记得在 `lib/lj_flutter_package.dart` 中补 `export`
- 平台差异逻辑封装在常量/工具内部（参考字重常量的平台自适应 getter 写法），业务侧不感知平台判断

## 作为依赖在业务项目中使用

- 本 package 通过 git 引用。业务项目如需让 AI 遵守以上规则，**直接把本文件复制到业务项目根目录**即可（`AGENTS.md` 已被 Claude Code / Copilot / Cursor / Windsurf 等主流工具读取）
- 完整文档在 pub 缓存中：`~/.pub-cache/git/lj_flutter_package-*/`（含 `README.md`、本 `AGENTS.md` 及全部源码）。注意：只有业务项目根目录的规则文件会被 AI 工具自动加载，缓存中的文件需 AI 按需读取
