#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
compare_weights.py — 逐行测量两张字重截图的笔画墨迹密度并做对比。

用法:
  python compare_weights.py <基准端.png> <对比端.png> [--start 100] [--step 50]
                          [--count N] [--plot out.png] [--names native flutter]

依赖: pillow, numpy（--plot 额外需要 matplotlib）

截图约定见同目录 skill 的 SKILL.md：裁掉外框/导航栏，最后一行完整、
避开 FAB 与 home 指示条；脚本只取左侧 72% 宽度。
"""
import argparse
import sys

import numpy as np
from PIL import Image


def detect_rows(path):
    """返回 [(ink_density, complete), ...]，按截图中的行顺序。"""
    a = np.asarray(Image.open(path).convert("L")).astype(np.float64)
    h, w = a.shape
    x1 = int(w * 0.72)  # 避开右侧 FAB / 角标
    sub = a[0:h, 0:x1]

    # 宽阈值抓全部文字（含很淡的低字重），按 y 投影分段
    proj = (sub < 235).sum(axis=1)
    bands, in_b = [], False
    for y, v in enumerate(proj):
        if v > 3 and not in_b:
            start, in_b = y, True
        elif v <= 3 and in_b:
            bands.append((start, y))
            in_b = False
    if in_b:
        bands.append((start, len(proj)))

    # 合并 <6px 的碎片（同一行字内的断缝）
    merged = []
    for s, e in bands:
        if merged and s - merged[-1][1] < 6:
            merged[-1] = (merged[-1][0], e)
        else:
            merged.append((s, e))

    rows = []
    for s, e in merged:
        if not (26 <= e - s <= 55):      # 样本行（约 22pt@3x ~35-40px）；灰标签约 15px 被排除
            continue
        dark = sub[s:e] < 245
        ys, xs = np.where(dark)
        if len(xs) < 200:
            continue
        if (xs.max() - xs.min()) < int(w * 0.30):   # 排除窄碎片/标题残片
            continue
        complete = (xs.min() > 3 and xs.max() < x1 - 4 and s > 3 and e < h - 6)
        crop = sub[s:e][ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        # 连续墨迹密度：白=0，纯黑=1，抗锯齿边缘自然部分加权
        ink = float(np.clip((255 - crop) / 255, 0, 1).mean())
        rows.append((ink, complete))
    return (w, h), rows


def to_map(rows, start, step):
    return {start + step * i: row for i, row in enumerate(rows)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("base")
    ap.add_argument("other")
    ap.add_argument("--start", type=int, default=100, help="首行字重，默认 100")
    ap.add_argument("--step", type=int, default=50, help="字重步长，默认 50")
    ap.add_argument("--count", type=int, default=0, help="行数，默认自动")
    ap.add_argument("--plot", default="", help="可选：输出对照图路径")
    ap.add_argument("--names", nargs=2, default=["base", "other"])
    args = ap.parse_args()

    (nb, b) = detect_rows(args.base)
    (no, o) = detect_rows(args.other)
    n = args.count or max(len(b), len(o))
    weights = [args.start + args.step * i for i in range(n)]
    mb = to_map(b, args.start, args.step)
    mo = to_map(o, args.start, args.step)

    print(f"== {args.names[0]} {nb} rows={len(b)}   {args.names[1]} {no} rows={len(o)} ==")
    print("\n== same-weight ==")
    print(f"{'w':>5}{args.names[0]:>10}{args.names[1]:>10}{'o-b pp':>9}{'o/b':>8}")
    common = []
    for w in weights:
        if w in mb and w in mo and mb[w][1] and mo[w][1]:
            vb, vo = mb[w][0], mo[w][0]
            common.append(w)
            print(f"{w:>5}{vb:>10.4f}{vo:>10.4f}{(vo-vb)*100:>+9.2f}{vo/vb:>8.3f}")
        else:
            tag_b = "ok" if mb.get(w, (0, False))[1] else "clip/缺失"
            tag_o = "ok" if mo.get(w, (0, False))[1] else "clip/缺失"
            print(f"{w:>5}  ({args.names[0]}:{tag_b}, {args.names[1]}:{tag_o})")

    print("\n== step deltas (x100) — 0.00 表示吸附，负值表示非单调 ==")
    for name, d in ((args.names[0], mb), (args.names[1], mo)):
        parts, prev = [], None
        for w in weights:
            if w in d:
                v = d[w][0]
                if prev is not None:
                    parts.append(f"{w-args.step}->{w}:{(v-prev)*100:+.2f}")
                prev = v
        print(f"  {name:<8}" + "  ".join(parts))

    print(f"\n== cross-match: 每个 {args.names[0]} 字重 ≈ {args.names[1]} 哪个字重 ==")
    valid_o = {w: v[0] for w, v in mo.items() if v[1]}
    for w in common:
        vb = mb[w][0]
        best = min(valid_o, key=lambda k: abs(valid_o[k] - vb))
        print(f"  {args.names[0]} w{w:<4} {vb:.4f}  ~=  "
              f"{args.names[1]} w{best:<4} {valid_o[best]:.4f}  gap {abs(valid_o[best]-vb)*100:+.2f}pp")

    if args.plot:
        _plot(weights, mb, mo, common, args)
        print(f"\nplot -> {args.plot}")


def _plot(weights, mb, mo, common, args):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib import font_manager

    for cand in ["/System/Library/Fonts/PingFang.ttc",
                 "/System/Library/Fonts/Hiragino Sans GB.ttc"]:
        try:
            font_manager.fontManager.addfont(cand)
            plt.rcParams["font.family"] = font_manager.FontProperties(fname=cand).get_name()
            break
        except Exception:
            pass
    plt.rcParams["axes.unicode_minus"] = False

    fig, ax = plt.subplots(1, 2, figsize=(15, 6))
    ax[0].plot(common, [mb[w][0]*100 for w in common], "o-", label=args.names[0])
    ax[0].plot(common, [mo[w][0]*100 for w in common], "s-", label=args.names[1])
    ax[0].set_xlabel("字重")
    ax[0].set_ylabel("墨迹密度 (%)")
    ax[0].set_title("同字重对比")
    ax[0].set_xticks(common)
    ax[0].grid(alpha=.25)
    ax[0].legend()

    valid_o = {w: v[0] for w, v in mo.items() if v[1]}
    mapped = [min(valid_o, key=lambda k: abs(valid_o[k]-mb[w][0])) for w in common]
    ax[1].plot(common, common, "--", color="#bbb", label="理想 y=x")
    ax[1].plot(common, mapped, "o-", color="#2ca02c", label="视觉等价字重")
    ax[1].set_xlabel(f"{args.names[0]} 字重")
    ax[1].set_ylabel(f"{args.names[1]} 字重")
    ax[1].set_title("视觉等价映射")
    ax[1].set_xticks(common)
    ax[1].set_yticks(weights)
    ax[1].grid(alpha=.25)
    ax[1].legend()
    plt.tight_layout()
    plt.savefig(args.plot, dpi=140, bbox_inches="tight", facecolor="white")


if __name__ == "__main__":
    sys.exit(main())
