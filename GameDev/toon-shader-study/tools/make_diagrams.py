"""학습 가이드용 개념 그림 생성 (matplotlib). 출력: <repo>/images/*.png"""
import sys, os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Polygon, Rectangle, Arc

OUT = sys.argv[1]
plt.rcParams["font.family"] = "Malgun Gothic"
plt.rcParams["axes.unicode_minus"] = False
plt.rcParams["figure.dpi"] = 110
INK, ACC, ACC2, SOFT = "#1d2433", "#e8590c", "#1971c2", "#868e96"


def save(fig, name):
    fig.savefig(os.path.join(OUT, name), bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("wrote", name)


def box(ax, x, y, w, h, title, sub, color):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.08", fc=color, ec=INK, lw=1.2))
    ax.text(x + w / 2, y + h * 0.66, title, ha="center", va="center", fontsize=12, weight="bold", color=INK)
    ax.text(x + w / 2, y + h * 0.3, sub, ha="center", va="center", fontsize=9, color=INK)


def arrow(ax, x0, y0, x1, y1, text=""):
    ax.add_patch(FancyArrowPatch((x0, y0), (x1, y1), arrowstyle="-|>", mutation_scale=16, lw=1.4, color=INK))
    if text:
        ax.text((x0 + x1) / 2, y0 + 0.13, text, ha="center", fontsize=8, color=ACC2)


# 1. 렌더링 파이프라인 (공장)
fig, ax = plt.subplots(figsize=(11, 2.6)); ax.axis("off"); ax.set_xlim(0, 11); ax.set_ylim(0, 2.2)
steps = [("메시 데이터", "점·노멀·UV\n(재료 창고)", "#fff3bf"), ("버텍스 셰이더", "점마다 한 번\n위치 옮기기", "#d0ebff"),
         ("래스터라이저", "삼각형을\n픽셀로 쪼개기", "#e9ecef"), ("프래그먼트 셰이더", "픽셀마다 한 번\n색 칠하기", "#ffe3e3"),
         ("화면", "깊이·블렌딩\n후 완성", "#d3f9d8")]
for i, (t, s, c) in enumerate(steps):
    box(ax, 0.2 + i * 2.18, 0.4, 1.8, 1.4, t, s, c)
    if i < len(steps) - 1:
        arrow(ax, 0.2 + i * 2.18 + 1.8, 1.1, 0.2 + (i + 1) * 2.18, 1.1)
ax.text(5.5, 2.1, "GPU 공장의 작업 순서 — 파란 칸과 빨간 칸이 우리가 쓰는 '셰이더'", ha="center", fontsize=11, color=INK)
save(fig, "day01-pipeline.png")

# 2. 좌표 공간 여행
fig, ax = plt.subplots(figsize=(12, 2.8)); ax.axis("off"); ax.set_xlim(0, 12.2); ax.set_ylim(0, 2.4)
spaces = [("오브젝트 공간", "모델 혼자 기준\n(내 방 안 위치)", "#fff3bf"), ("월드 공간", "세상 전체 기준\n(도시 지도 위치)", "#d3f9d8"),
          ("뷰 공간", "카메라 기준\n(내 눈에서 본 위치)", "#d0ebff"), ("클립 공간", "원근 적용 직전\n(-w..w 상자)", "#e5dbff"),
          ("화면 공간", "픽셀 좌표\n(모니터 칸 번호)", "#ffe3e3")]
mats = ["Model 행렬\nTransformObjectToWorld", "View 행렬", "Projection 행렬\nTransformWorldToHClip", "원근 나눗셈\n÷ w"]
for i, (t, s, c) in enumerate(spaces):
    box(ax, 0.1 + i * 2.45, 0.35, 1.85, 1.45, t, s, c)
    if i < len(spaces) - 1:
        arrow(ax, 0.1 + i * 2.45 + 1.85, 1.07, 0.1 + (i + 1) * 2.45, 1.07)
        ax.text(0.1 + i * 2.45 + 2.17, 1.95, mats[i], ha="center", fontsize=7.5, color=ACC2)
save(fig, "day02-coordinate-spaces.png")

# 3. 행렬 = 변환 기계 (격자 변형)
fig, axs = plt.subplots(1, 3, figsize=(10, 3.4))
M = {"이동 (Translate)": (np.array([[1, 0], [0, 1]]), np.array([1.0, 0.5])),
     "회전 (Rotate 30°)": (np.array([[np.cos(np.pi / 6), -np.sin(np.pi / 6)], [np.sin(np.pi / 6), np.cos(np.pi / 6)]]), np.zeros(2)),
     "크기 (Scale ×1.5, ×0.7)": (np.array([[1.5, 0], [0, 0.7]]), np.zeros(2))}
house = np.array([[0, 0], [1, 0], [1, 1], [0.5, 1.5], [0, 1], [0, 0]])
for ax, (name, (A, t)) in zip(axs, M.items()):
    ax.plot(house[:, 0], house[:, 1], color=SOFT, lw=2, label="원래")
    h2 = house @ A.T + t
    ax.plot(h2[:, 0], h2[:, 1], color=ACC, lw=2.5, label="변환 후")
    ax.set_aspect("equal"); ax.set_xlim(-1, 3); ax.set_ylim(-0.5, 2.5); ax.grid(alpha=0.3); ax.set_title(name, fontsize=11)
axs[0].legend(loc="upper left", fontsize=8)
fig.suptitle("행렬은 '점을 옮기는 기계' — 같은 집을 기계에 넣으면 모양이 바뀐다", fontsize=12)
save(fig, "day02-matrix-machine.png")

# 4. 내적 (손전등)
fig, ax = plt.subplots(figsize=(5.2, 4)); ax.set_aspect("equal"); ax.axis("off")
ax.plot([-1.6, 1.6], [0, 0], color=INK, lw=3); ax.text(1.0, -0.2, "표면", fontsize=10)
ax.add_patch(FancyArrowPatch((0, 0), (0, 1.3), arrowstyle="-|>", mutation_scale=18, lw=2.5, color=ACC2)); ax.text(0.05, 1.35, "N (표면이 보는 방향)", fontsize=10, color=ACC2)
ang = np.radians(50); L = np.array([np.sin(ang), np.cos(ang)]) * 1.3
ax.add_patch(FancyArrowPatch((0, 0), tuple(L), arrowstyle="-|>", mutation_scale=18, lw=2.5, color=ACC)); ax.text(L[0] + 0.05, L[1], "L (빛이 오는 방향)", fontsize=10, color=ACC)
ax.add_patch(Arc((0, 0), 0.8, 0.8, theta1=40, theta2=90, color=INK)); ax.text(0.12, 0.5, "θ", fontsize=13)
ax.text(-1.6, -0.75, "N · L = |N||L| cos θ\n정면이면 1, 옆이면 0, 뒤면 음수", fontsize=11, color=INK)
ax.set_xlim(-1.7, 1.9); ax.set_ylim(-1.0, 1.7)
save(fig, "day06-dot-product.png")

# 5. 램버트 vs 하프 램버트
th = np.linspace(0, 180, 361); c = np.cos(np.radians(th))
fig, ax = plt.subplots(figsize=(7, 3.6))
ax.plot(th, np.maximum(c, 0), lw=2.5, color=ACC2, label="Lambert: max(0, N·L)")
ax.plot(th, c * 0.5 + 0.5, lw=2.5, color=ACC, label="Half-Lambert: N·L × 0.5 + 0.5")
ax.axvline(90, color=SOFT, ls="--"); ax.text(92, 0.92, "빛과 직각", color=SOFT, fontsize=9)
ax.set_xlabel("빛과 표면이 이루는 각도 θ (도)"); ax.set_ylabel("밝기"); ax.grid(alpha=0.3); ax.legend()
ax.set_title("하프 램버트는 그림자 쪽도 0으로 뚝 떨어지지 않아 '부드러운 밑그림'이 된다")
save(fig, "day06-lambert-vs-half.png")

# 6. smoothstep 블러
x = np.linspace(0, 1, 500)
def smoothstep(a, b, v):
    t = np.clip((v - a) / max(b - a, 1e-6), 0, 1); return t * t * (3 - 2 * t)
fig, ax = plt.subplots(figsize=(7, 3.6))
for blur, col in [(0.01, INK), (0.1, ACC2), (0.25, ACC)]:
    ax.plot(x, smoothstep(0.5 - blur, 0.5 + blur, x), lw=2.5, color=col, label=f"Blur = {blur}")
ax.axvline(0.5, color=SOFT, ls="--"); ax.text(0.51, 0.05, "Border = 0.5", color=SOFT)
ax.set_xlabel("빛 값 (하프 램버트)"); ax.set_ylabel("밝은 쪽일 확률(0=그림자, 1=빛)"); ax.legend(); ax.grid(alpha=0.3)
ax.set_title("smoothstep: 경계선 Border 근처에서만 0→1 로 넘어가는 '계단'")
save(fig, "day07-smoothstep-blur.png")

# 7. 2단 툰 밴드 컬러 바
lightv = np.linspace(0, 1, 600)
base = np.array([1.0, 0.82, 0.62]); c1 = np.array([0.72, 0.74, 0.82]); c2 = np.array([0.55, 0.57, 0.66])
def band(b1, bl1, b2, bl2):
    s1 = 1 - smoothstep(b1 - bl1, b1 + bl1, lightv); s2 = 1 - smoothstep(b2 - bl2, b2 + bl2, lightv)
    col = np.ones((len(lightv), 3)) * base
    col = col * (1 - s1[:, None]) + (base * c1) * s1[:, None]
    col = col * (1 - s2[:, None]) + (base * c2) * s2[:, None]
    return col
fig, axs = plt.subplots(3, 1, figsize=(8, 3.2))
for ax, (title, p) in zip(axs, [("기본: 1차 0.5 / 2차 0.25, blur 0.1", (0.5, 0.1, 0.25, 0.1)), ("딱딱하게: blur 0.01", (0.5, 0.01, 0.25, 0.01)), ("그림자 넓게: 1차 0.7", (0.7, 0.1, 0.35, 0.1))]):
    ax.imshow(band(*p)[None, :, :], aspect="auto", extent=[0, 1, 0, 1]); ax.set_yticks([]); ax.set_ylabel(title, rotation=0, ha="right", va="center", fontsize=9)
axs[-1].set_xlabel("빛 값 0 (어두움) → 1 (밝음)")
for ax in axs[:-1]: ax.set_xticks([])
fig.suptitle("툰 셰이딩 = 빛 값을 '색 계단'으로 바꾸기 (밝은 색 · 1차 그림자 · 2차 그림자)", fontsize=11)
save(fig, "day07-toon-bands.png")

# 8. 섀도맵 원리
fig, ax = plt.subplots(figsize=(7.5, 4)); ax.axis("off"); ax.set_xlim(0, 10); ax.set_ylim(0, 6)
ax.add_patch(Circle((1.2, 5.2), 0.35, color="#ffd43b")); ax.text(0.5, 5.75, "빛 = 두 번째 카메라", fontsize=10)
ax.add_patch(Rectangle((4, 2.3), 1.2, 1.2, color=SOFT)); ax.text(4.0, 3.65, "물체", fontsize=10)
ax.plot([0, 10], [0.8, 0.8], color=INK, lw=3); ax.text(8.2, 0.35, "바닥", fontsize=10)
for xg in [3.0, 6.5, 8.5]:
    ax.plot([1.2, xg], [5.2, 0.8], color="#fab005", lw=1, ls="--")
ax.add_patch(Polygon([[5.9, 0.8], [8.0, 0.8], [5.2, 2.3], [4.6, 2.3]], color="#343a40", alpha=0.35)); ax.text(6.2, 1.05, "그림자", color="white", fontsize=10)
ax.text(5.6, 5.3, "① 빛 위치에서 '가장 가까운 거리'를\n   사진처럼 찍어 둔다 (섀도맵)\n② 화면의 각 픽셀이 그 사진보다\n   멀면 → 가려졌다 = 그림자", fontsize=10, color=INK, va="top")
save(fig, "day08-shadow-map.png")

# 9. GI 포스터라이즈
lum = np.linspace(0, 1, 500)
def posterize(v, n, soft):
    f = v * n; i = np.floor(f); fr = f - i
    return (i + smoothstep(0.5 - soft, 0.5 + soft, fr)) / n
fig, ax = plt.subplots(figsize=(6.5, 3.4))
ax.plot(lum, lum, color=SOFT, ls="--", label="원래 하늘빛(부드러움)")
ax.plot(lum, posterize(lum, 3, 0.1), color=ACC, lw=2.5, label="툰화: 3단계")
ax.set_xlabel("원래 밝기"); ax.set_ylabel("툰화된 밝기"); ax.legend(); ax.grid(alpha=0.3)
ax.set_title("GI 툰화 — 부드러운 환경광도 계단으로 만든다 (ToonPosterize)")
save(fig, "day10-gi-posterize.png")

# 10. 프레넬 림
th = np.linspace(0, 90, 300); fres = 1 - np.cos(np.radians(th))
fig, ax = plt.subplots(figsize=(6.5, 3.4))
ax.plot(th, fres, color=ACC2, lw=2.5, label="fresnel = 1 - N·V")
ax.plot(th, smoothstep(0.6, 0.65, fres), color=ACC, lw=2.5, label="림 = smoothstep(0.6, 0.65, fresnel)")
ax.set_xlabel("시선과 표면이 비스듬한 정도 (0°=정면, 90°=테두리)"); ax.legend(); ax.grid(alpha=0.3)
ax.set_title("테두리(시선과 거의 직각)일수록 fresnel 이 커진다 → 가장자리만 빛나는 림")
save(fig, "day11-fresnel-rim.png")

# 11. 인버티드 헐
fig, axs = plt.subplots(1, 2, figsize=(9, 4))
for ax in axs: ax.set_aspect("equal"); ax.axis("off"); ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.8, 1.8)
t = np.linspace(0, 2 * np.pi, 200)
axs[0].fill(np.cos(t) * 1.25, np.sin(t) * 1.25, color="#212529"); axs[0].fill(np.cos(t), np.sin(t), color="#ffd8a8")
for a in np.linspace(0, 2 * np.pi, 12, endpoint=False):
    axs[0].add_patch(FancyArrowPatch((np.cos(a), np.sin(a)), (np.cos(a) * 1.25, np.sin(a) * 1.25), arrowstyle="-|>", mutation_scale=9, color=ACC))
axs[0].set_title("① 몸보다 살짝 큰 '뒤집힌 풍선'을\n노멀 방향으로 부풀려 검게 칠한다", fontsize=10)
sq = np.array([[-1, -1], [1, -1], [1, 1], [-1, 1]])
axs[1].add_patch(Polygon(sq * 1.0, color="#ffd8a8"))
for (p, n) in [((1, 0), (1, 0)), ((0, 1), (0, 1)), ((-1, 0), (-1, 0)), ((0, -1), (0, -1))]:
    off = np.array(n) * 0.25
    edge = np.array([[-1, -1], [1, -1]]) if n == (0, -1) else np.array([[1, -1], [1, 1]]) if n == (1, 0) else np.array([[1, 1], [-1, 1]]) if n == (0, 1) else np.array([[-1, 1], [-1, -1]])
    axs[1].plot(*(edge + off).T, color="#212529", lw=4)
axs[1].plot([1.25, 1.18], [1.0, 1.18], color=ACC, lw=2); axs[1].text(0.35, 1.45, "면 노멀로 밀면\n모서리가 벌어진다", fontsize=9, color=ACC)
axs[1].set_title("② 각진 모델은 면마다 노멀이 달라 틈이 생긴다\n→ '평균 노멀(스무스 노멀)'을 따로 구워 둔다", fontsize=10)
save(fig, "day12-inverted-hull.png")

# 12. 외곽선 폭 vs 거리
d = np.linspace(0.5, 12, 300)
fov = np.radians(60); H = 1080
world_w = 0.00113  # 실측 _OutlineWidth 0.113 → 1.13mm
px_world = world_w / (2 * d * np.tan(fov / 2)) * H
fig, ax = plt.subplots(figsize=(7, 3.6))
ax.plot(d, px_world, color=ACC2, lw=2.5, label="World 모드: 월드 1.13mm 폭")
ax.plot(d, np.maximum(px_world, 1.0), color=ACC, lw=2.5, ls="--", label="최소 1px 보장(_OutlineMinPixels)")
ax.axhline(1.0, color=SOFT, lw=1); ax.text(9.5, 1.05, "1 픽셀", color=SOFT)
ax.axvline(6, color=SOFT, ls=":"); ax.text(6.1, 1.6, "쿼터뷰 6m → 0.18px", color=INK, fontsize=9)
ax.set_xlabel("카메라까지 거리 (m)"); ax.set_ylabel("화면에서의 외곽선 두께 (px)"); ax.set_ylim(0, 2.2); ax.legend(); ax.grid(alpha=0.3)
ax.set_title("1픽셀보다 얇은 선은 프레임마다 켜졌다 꺼졌다 → '자글거림'(PLAN-19)")
save(fig, "day12-outline-width-vs-distance.png")

# 13. 엣지 검출 (깊이 격자)
depth = np.array([[9, 9, 9, 9, 9], [9, 9, 3, 3, 9], [9, 3, 3, 3, 9], [9, 3, 3, 3, 9], [9, 9, 9, 9, 9]], float)
edge = np.zeros_like(depth)
for y in range(4):
    for x in range(4):
        edge[y, x] = abs(depth[y, x] - depth[y, x + 1]) + abs(depth[y, x] - depth[y + 1, x]) + abs(depth[y, x] - depth[y + 1, x + 1])
fig, axs = plt.subplots(1, 2, figsize=(8, 3.6))
axs[0].imshow(depth, cmap="Blues_r"); axs[0].set_title("깊이 텍스처 (작을수록 가깝다)")
for (yy, xx), v in np.ndenumerate(depth): axs[0].text(xx, yy, int(v), ha="center", va="center", color="white" if v < 5 else INK)
axs[1].imshow(edge > 3, cmap="Reds"); axs[1].set_title("이웃과 차이가 크면 → 외곽선")
for ax in axs: ax.set_xticks([]); ax.set_yticks([])
save(fig, "day13-edge-detection.png")

# 14. SDF 얼굴 그림자 임계값
xs = np.linspace(0, 1, 400); ys = np.linspace(0, 1, 300); X, Y = np.meshgrid(xs, ys)
sdf = np.clip(X * 1.0 + 0.15 * np.sin(Y * 6), 0, 1)
fig, axs = plt.subplots(1, 4, figsize=(12, 3))
axs[0].imshow(sdf, cmap="gray", origin="lower"); axs[0].set_title("SDF 텍스처\n(그림자 시작 순서 지도)")
for ax, cov, name in zip(axs[1:], [0.2, 0.5, 0.8], ["빛이 앞쪽", "빛이 옆", "빛이 뒤쪽"]):
    ax.imshow(sdf > cov, cmap="gray", origin="lower"); ax.set_title(f"{name}\n임계값 {cov} → 흰 곳만 밝음")
for ax in axs: ax.set_xticks([]); ax.set_yticks([])
save(fig, "day14-sdf-threshold.png")

# 15. 블린-퐁 하프 벡터
fig, ax = plt.subplots(figsize=(5.4, 4)); ax.set_aspect("equal"); ax.axis("off")
ax.plot([-1.6, 1.6], [0, 0], color=INK, lw=3)
Lv = np.array([np.sin(np.radians(-55)), np.cos(np.radians(-55))]); Vv = np.array([np.sin(np.radians(35)), np.cos(np.radians(35))])
Hv = (Lv + Vv) / np.linalg.norm(Lv + Vv)
for v, col, name in [(Lv, ACC, "L (빛)"), (Vv, ACC2, "V (눈)"), (Hv, "#2b8a3e", "H = (L+V) 정규화")]:
    ax.add_patch(FancyArrowPatch((0, 0), tuple(v * 1.3), arrowstyle="-|>", mutation_scale=16, lw=2.3, color=col)); ax.text(*(v * 1.38), name, color=col, fontsize=10, ha="center")
ax.add_patch(FancyArrowPatch((0, 0), (0, 1.15), arrowstyle="-|>", mutation_scale=14, lw=1.5, color=SOFT, ls="--")); ax.text(0.05, 1.18, "N", color=SOFT)
ax.text(-1.6, -0.75, "H 가 N 과 겹칠수록(N·H → 1)\n반짝임이 강하다 (Blinn-Phong)", fontsize=11)
ax.set_xlim(-1.7, 1.8); ax.set_ylim(-1.0, 1.8)
save(fig, "day15-blinn-phong.png")

# 16. MatCap 원리
fig, axs = plt.subplots(1, 2, figsize=(8, 3.6))
yy, xx = np.mgrid[-1:1:300j, -1:1:300j]; r = np.sqrt(xx ** 2 + yy ** 2)
mc = np.clip(1 - np.sqrt((xx - 0.35) ** 2 + (yy - 0.4) ** 2) * 1.6, 0, 1); mc[r > 1] = np.nan
axs[0].imshow(mc, cmap="copper", origin="lower"); axs[0].set_title("MatCap 텍스처 (반사가 그려진 공 사진)")
axs[1].axis("off"); axs[1].text(0, 0.5, "① 픽셀의 노멀을 '카메라 기준'으로 바꾼다 (normalVS)\n② 노멀의 x, y 를 0~1 로 옮기면 UV 가 된다\n     uv = normalVS.xy × 0.5 + 0.5\n③ 그 UV 로 공 사진에서 색을 집어 더한다\n\n→ 빛 계산 없이 '그려 둔 반사'를 붙이는 마법 스티커", fontsize=11, va="center")
axs[0].set_xticks([]); axs[0].set_yticks([])
save(fig, "day15-matcap-principle.png")

# 17. 배리언트 폭발
n = np.arange(0, 21)
fig, ax = plt.subplots(figsize=(7, 3.4))
ax.semilogy(n, 2.0 ** n, color=ACC, lw=2.5, marker="o", ms=4)
ax.set_xlabel("켜고 끌 수 있는 키워드 개수"); ax.set_ylabel("가능한 조합 수 (로그)"); ax.grid(alpha=0.3, which="both")
ax.text(10.5, 2 ** 10 * 1.5, "10개 → 1,024가지", fontsize=10); ax.text(17, 2 ** 17 * 1.6, "20개 → 약 100만", fontsize=10, ha="center")
ax.set_title("키워드 하나 늘 때마다 셰이더 사본이 두 배 — 그래서 '안 쓰는 조합'을 거른다")
save(fig, "day16-variant-explosion.png")

# 18. 스플랫맵
fig, axs = plt.subplots(1, 3, figsize=(10, 3.2))
yy, xx = np.mgrid[0:1:200j, 0:1:200j]
ctrl = np.stack([np.clip(1 - xx * 2, 0, 1), np.clip(xx * 2 - 0.5, 0, 1) * np.clip(1.5 - xx * 2, 0, 1) + 0.0, np.clip(yy * 2 - 1, 0, 1)], -1)
ctrl = np.clip(ctrl, 0, 1)
axs[0].imshow(ctrl, origin="lower"); axs[0].set_title("Control 맵 (R·G·B·A = 어느 물감을\n얼마나 쓸지 적은 지도)")
layers = [np.array([0.35, 0.6, 0.25]), np.array([0.6, 0.5, 0.35]), np.array([0.85, 0.85, 0.9])]
blend = sum(ctrl[..., i:i + 1] * layers[i] for i in range(3)) / np.maximum(ctrl.sum(-1, keepdims=True), 1e-4)
axs[1].imshow(np.clip(blend, 0, 1), origin="lower"); axs[1].set_title("섞인 결과 (잔디·흙·눈)")
axs[2].axis("off"); axs[2].text(0, 0.5, "색 = (레이어0×R + 레이어1×G\n      + 레이어2×B + 레이어3×A)\n      ÷ (R+G+B+A)\n\nSampleTerrainAlbedo()", fontsize=11, va="center")
for ax in axs[:2]: ax.set_xticks([]); ax.set_yticks([])
save(fig, "day19-splatmap.png")
