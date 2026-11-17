"""추가 개념 그림 3장: Day03 하늘 그라데이션, Day04 정점 보간, Day16 2x2 쿼드 미분."""
import sys, os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

OUT = sys.argv[1]
plt.rcParams["font.family"] = "Malgun Gothic"
plt.rcParams["axes.unicode_minus"] = False
plt.rcParams["figure.dpi"] = 110
INK = "#1d2433"


def save(fig, name):
    fig.savefig(os.path.join(OUT, name), bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("wrote", name)


# Day03: SceneToon_Sky 의 frag 를 그대로 옮긴 그라데이션
zen = np.array([0.35, 0.55, 0.85]); hor = np.array([0.8, 0.85, 0.9]); gnd = np.array([0.5, 0.48, 0.45])
h = np.linspace(1, -1, 300)
fig, axs = plt.subplots(1, 3, figsize=(9, 3.6))
for ax, sharp in zip(axs, [0.5, 2.0, 8.0]):
    up = np.clip(np.clip(h, 0, 1) ** (1 / sharp), 0, 1)
    down = np.clip(np.clip(-h, 0, 1) ** (1 / sharp), 0, 1)
    col = hor + (zen - hor) * up[:, None]
    col = col + (gnd - col) * down[:, None]
    ax.imshow(np.repeat(col[:, None, :], 40, axis=1), aspect="auto", extent=[0, 1, -1, 1])
    ax.axhline(0, color="white", lw=0.8, ls="--")
    ax.set_xticks([]); ax.set_title(f"Horizon Sharpness = {sharp}")
axs[0].set_ylabel("dir.y  (위 1 … 수평 0 … 아래 -1)")
fig.suptitle("SceneToon_Sky: 시선이 위를 볼수록 하늘색, 아래를 볼수록 땅색", fontsize=12)
save(fig, "day03-sky-gradient.png")

# Day04: 정점 3개의 색이 픽셀로 '보간'되는 모습
n = 400
xs, ys = np.meshgrid(np.linspace(0, 1, n), np.linspace(0, 1, n))
A, B, C = np.array([0.05, 0.05]), np.array([0.95, 0.05]), np.array([0.5, 0.95])
def bary(px, py):
    v0, v1 = B - A, C - A
    v2x, v2y = px - A[0], py - A[1]
    d00, d01, d11 = v0 @ v0, v0 @ v1, v1 @ v1
    d20 = v2x * v0[0] + v2y * v0[1]; d21 = v2x * v1[0] + v2y * v1[1]
    den = d00 * d11 - d01 * d01
    v = (d11 * d20 - d01 * d21) / den; w = (d00 * d21 - d01 * d20) / den
    return 1 - v - w, v, w
u, v, w = bary(xs, ys)
inside = (u >= 0) & (v >= 0) & (w >= 0)
img = np.ones((n, n, 3))
img[inside] = (u[..., None] * np.array([1, 0.2, 0.2]) + v[..., None] * np.array([0.2, 0.8, 0.2]) + w[..., None] * np.array([0.2, 0.3, 1]))[inside]
fig, ax = plt.subplots(figsize=(5, 4.4))
ax.imshow(img, origin="lower", extent=[0, 1, 0, 1]); ax.axis("off")
for p, name in [(A, "정점 A (빨강)"), (B, "정점 B (초록)"), (C, "정점 C (파랑)")]:
    ax.plot(*p, "o", color=INK); ax.text(p[0], p[1] + (0.04 if p[1] > 0.5 else -0.07), name, ha="center", fontsize=10)
ax.set_title("버텍스 셰이더는 꼭짓점 3개만 계산 →\n그 사이 픽셀 값은 GPU가 '섞어서' 채워 준다 (Varyings 보간)", fontsize=11)
save(fig, "day04-interpolation.png")

# Day16: 2x2 쿼드 미분
fig, ax = plt.subplots(figsize=(6.4, 4)); ax.axis("off"); ax.set_xlim(0, 6.4); ax.set_ylim(0, 4)
vals = {(0, 1): 0.30, (1, 1): 0.34, (0, 0): 0.31, (1, 0): 0.36}
for (cx, cy), val in vals.items():
    ax.add_patch(Rectangle((0.3 + cx * 1.4, 0.6 + cy * 1.4), 1.3, 1.3, fc="#d0ebff", ec=INK, lw=1.5))
    ax.text(0.95 + cx * 1.4, 1.25 + cy * 1.4, f"u = {val:.2f}", ha="center", va="center", fontsize=11)
ax.text(1.65, 3.55, "GPU는 픽셀을 2×2 묶음으로 동시에 칠한다", ha="center", fontsize=11, color=INK)
ax.text(3.4, 2.6, "ddx(u) = 오른쪽 - 왼쪽\n          = 0.34 - 0.30 = 0.04", fontsize=11, va="center")
ax.text(3.4, 1.3, "ddy(u) = 아래 - 위\n          = 0.31 - 0.30 = 0.01\n\nfwidth(u) = |ddx| + |ddy| = 0.05\n→ '한 픽셀 사이에 값이 얼마나 변하나'", fontsize=11, va="center")
save(fig, "day16-quad-derivatives.png")
