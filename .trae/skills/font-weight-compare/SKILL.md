---
name: font-weight-compare
description: 对比两端（Flutter vs 原生，或任意两平台）字体字重的实际渲染差异。用户要求对比/校准字重、字重显示不一致、Flutter 字体偏细、出字重补偿表、对比 iOS/Android/macOS/Windows/Linux 渲染时使用。不用于字号、颜色或布局问题。
---

# 字重渲染像素对比（font-weight-compare）

通过对两张截图**逐行测量笔画墨迹密度（ink density）**，客观比较相同字重值在不同渲染端的差异，并给出“视觉等价字重”交叉匹配，作为平台字重补偿值的标定依据。

## 何时使用

- 用户要对比 Flutter 与 iOS/Android 原生、或 Flutter 桌面端（macOS/Windows/Linux）的字重显示。
- 需要产出平台字重补偿映射（如设计 w400 在 Flutter(某平台) 应写成多少）。
- 典型触发：「字重对比」「Flutter 字体偏细」「标定字重」「和原生字重不一致」。

## 前置：准备合格截图（结果可靠的前提）

让被测页面把同一句样本文字按固定步长（建议 50）从 w100 到 w900 纵向排列，灰字小标签 `w###` + 黑色大字样本。参考本仓库：

- Flutter：`example/lib/demo_pages/pages/font_weight_page.dart`
- iOS 原生：桌面 `FontWeightCompare/FontWeightCompare/ContentView.swift`

截图要求（务必向用户确认/要求）：

1. 两端**同一句文字、同一字号、同一颜色（纯黑）、同一背景（纯白）**。
2. **裁掉模拟器外框和顶部导航栏**，从 w100 标签开始；不要包含返回箭头、导航标题。
3. 避开右下角 FAB / DEBUG 角标（脚本只取左侧 72% 宽度）；**最后一行必须完整、远离 home 指示横条**，必要时分段截图（w100~w650、w700~w900 两张）。
4. 两端截图宽度一致（同机型/同逻辑分辨率@同样 scale）。脚本以“密度=墨迹/包围盒”归一化，轻微缩放可接受，但不要一端放大截图。
5. 一次只测一个平台对，不要把不同平台混在一张图。

## 运行

脚本只依赖 pillow + numpy（绘图可选 matplotlib）。优先用已建好的 venv：

```bash
PY=/tmp/imgvenv/bin/python
[ -x "$PY" ] || { /opt/homebrew/bin/python3 -m venv /tmp/imgvenv && /tmp/imgvenv/bin/pip -q install pillow numpy; }

# 基本对比（默认从 w100 起、步长 50）
"$PY" scripts/compare_weights.py <基准端.png> <对比端.png>

# 高字重分段：从 w700 起，共 5 行
"$PY" scripts/compare_weights.py native_hi.png flutter_hi.png --start 700 --count 5

# 额外输出曲线图
"$PY" scripts/compare_weights.py a.png b.png --plot /tmp/weight_compare.png
```

输出三张表：

- **same-weight**：同字重下两端墨迹密度、差值（pp, 百分点）与比值 f/n。
- **step deltas**：相邻档增量。增量≈0 即“吸附”（两档渲染相同）；出现负值说明该端非单调（合成粗体抖动）。
- **cross-match**：基准端每一档在对比端视觉上最接近的字重，即补偿映射的直接依据。

## 如何解读与产出补偿表

1. 密度是相对量，只在**同次测量的两张图之间**比较；不要跨截图组比绝对值。
2. 优先采用**单调、可区分**的匹配：cross-match 若把多档映到同一值（高档常见，说明该端实体档位稀疏），可在相邻 Plateau 间手动选值以保持层级，并向用户说明这是“保持层级”而非“严格最近”。
3. 低字重（≤w250）和高字重（≥w700）两端都容易吸附，补偿不可靠；规范建议主要使用 w300~w600。
4. 补偿值**只对被标定的平台有效**：iOS 的差值不能用于 Android/macOS/Windows/Linux（系统字体和引擎合成策略都不同）。每加一个平台，用该平台原生工程重新跑一遍本流程。
5. 把确认后的映射写进 `lib/utils/lj_define.dart` 的平台分支（`isIOS` / `isAndroid` / `Platform.isMacOS` 等），getter 形式，不要再用 const 常量（const 无法按平台切换），并同步处理 `quickText`/`textStyle`/`quickGradientText` 默认字重的可空兜底（当前为 `?? regular`）。

## 已知校准记录（iOS，22pt，SF/PingFang）

- 稳定区间 w300~w600：Flutter 比原生细约 6~7pp（粗度约为原生 0.72~0.78）。
- 实测等视觉锚点（v1 严格匹配）：原生 w300 ≈ Flutter w450；w400 ≈ w600。
- 吸附对：Flutter w100=w150、w200=w250、w600=w650、w700=w750、w800=w850；
  w350/450/550 仅偏向相邻整百、方向不固定。有效阶梯只有整百档。
- 补偿映射经两版迭代：v1 严格按密度（跨度大，已弃用），**当前采用 v2 视觉走查
  保守版**（light 350 / regular 450 / medium 600 / semibold 700 / bold 不补偿）。
- 详见 `references/ios-calibration.md`（含两版映射与弃用原因）。
