# 고라니TV 셰이더 강의 타임라인

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-SGR-004-REF |
| 유형 | REF (강의 영상 시간 색인) |
| 목적 | 강의 영상에서 Shader Graph 노드와 주제가 나오는 시각을 찾는다 |
| 출처 | 외부 YouTube 영상 (링크는 각 행의 시간) |
| 확인 상태 | 미검증 (원본 목록을 표로 옮긴 것이며 영상과 대조하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 영상은 구버전 Shader Graph 기준으로 보인다. `PBR Master`, `Sprite Lit Master`, `Unlit Master`, `Visual Effect Master` 같은 마스터 노드는 최신 버전에서 Graph Settings와 Master Stack(Vertex·Fragment 블록)으로 바뀌었다. 노드 이름과 동작은 사용 중인 Unity·Shader Graph 버전 문서로 확인해야 한다(버전 확인 필요).
{% endhint %}

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [01aboutshader.md](01aboutshader.md) | GMD-SGR-001-DO | 셰이더 기초 개념과 종류 |
| [shadernodes.md](shadernodes.md) | GMD-SGR-005-REF | Shader Graph 핵심 노드 입출력 표 |

* 강의 영상: <https://youtu.be/KnueAgpUL3Y>

## 꼭 알아야 할 것

| 시간 | 주제 |
|---|---|
| [0:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=16s) | 셰이더의 작동원리 |
| [4:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=286s) | URP 프로젝트 생성 |
| [5:34](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=334s) | 2D, 3D에서 URP 업그레이드 방법 |
| [6:34](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=394s) | 머테리얼과 셰이더 |
| [9:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=540s) | 스크립트로 변수 참조 |
| [12:44](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=764s) | In, Out 매개변수의 형태 |
| [16:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=968s) | 버텍스와 프래그먼트 |
| [20:27](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1227s) | PBR마스터 변수 |
| [26:20](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1580s) | Sub 그래프 |
| [26:58](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1618s) | 벡터의 연산 |

## Artistic (예술적)

### Adjustment (조절)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [28:25](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1705s) | Channel Mixer | 색보정 |  |
| [28:52](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1732s) | Contrast | 대비 |  |
| [29:05](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1745s) | Hue | 색조 |  |
| [29:24](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1764s) | Invert Colors | 색반전 |  |
| [29:49](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1789s) | Replace Color | 색교체 |  |
| [30:02](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1802s) | Saturate | 채도 |  |
| [30:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1808s) | White Balance | 색온도 |  |

### Blend (혼합)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [30:37](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1837s) | Blend | 혼합 |  |

### Filter (필터)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [31:22](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1882s) | Dither | 잡음 |  |

### Mask (마스크)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [31:27](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1887s) | Channel Mask | 채널 마스크 |  |
| [31:39](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1899s) | Color Mask | 색깔 마스크 |  |

### Normal (노말)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [32:33](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1953s) | Normal Blend | 노말 혼합 |  |
| [32:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1966s) | Normal From Height | 높이에서 노말 추출 |  |
| [32:59](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1979s) | Normal From Texture | 텍스쳐에서 노말 추출 |  |
| [33:15](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1995s) | Normal Reconstruct Z | 노말 재구성 |  |
| [33:19](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=1999s) | Normal Strength | 노말 강도 |  |
| [33:23](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2003s) | Normal Unpack | 노말 풀기 |  |

### Utility (유틸)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [33:51](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2031s) | Colorspace Conversion | 색공간 변환 | 리니어, 감마 공간 |

## Channel (채널)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [35:33](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2133s) | Split | 분할 |  |
| [35:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2146s) | Combine | 결합 |  |
| [35:56](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2156s) | Flip | 뒤집기 |  |
| [36:26](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2186s) | Swizzle | 섞기 |  |

## Input (입력)

### Basic (기본)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [36:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2192s) | Boolean | 부울 |  |
| [36:48](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2208s) | Color | 색깔 | 포스트 프로세싱 |
| [38:03](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2283s) | Constant | 정적숫자 |  |
| [38:49](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2329s) | Integer | 정수 |  |
| [38:53](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2333s) | Slider | 슬라이더 |  |
| [38:59](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2339s) | Time | 시간 |  |
| [40:34](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2434s) | Vector1, Vector2, Vector3, Vector4 | 벡터1,2,3,4 | 벡터의 연산 |

### Geometry (기하학)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [41:25](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2485s) | Bitangent Vector | 비탄젠트 벡터 |  |
| [41:53](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2513s) | Normal Vector | 노말 벡터 | 오브젝트, 월드, 뷰, 탄젠트 좌표계 |
| [45:33](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2733s) | Position | 정점 위치 |  |
| [46:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=2776s) | Screen Position | 화면 UV | 굴절 셰이더 |
| [51:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3060s) | Tangent Vector | 탄젠트 벡터 |  |
| [51:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3076s) | UV UV |  |  |
| [54:25](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3265s) | Vertex Color | 정점 색깔 | 지형 셰이더 |
| [56:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3360s) | View Direction | 뷰 방향 |  |

### Gradient (그라데이션)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [57:04](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3424s) | Gradient | 그라데이션 |  |
| [57:36](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3456s) | Sample Gradient | 그라데이션 샘플 |  |

### Lighting (빛)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [57:58](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3478s) | Ambient | 환경광 |  |
| [58:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3534s) | Baked GI | 빛 굽기 | 라이트맵 |
| [59:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3594s) | Reflection Probe | 반사 구 |  |

### Matrix (행렬)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:00:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3600s) | Matrix 2x2, Matrix 3x3, Matrix 4x4 | 행렬2x2, 3x3, 4x4 | 행렬의 연산 |
| [1:01:57](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3717s) | Transformation Matrix | 변환행렬 |  |

### PBR (물리기반 렌더링)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:03:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3822s) | Dielectric Specular | 비금속 극성물질 | 물 굴절 셰이더 |
| [1:04:56](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3896s) | Metal Reflectance | 금속 반사율 |  |

### Scene (씬)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:05:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=3932s) | Camera | 카메라 | 깊이 텍스쳐 |
| [1:07:30](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4050s) | Fog | 안개 |  |
| [1:07:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4074s) | Object | 오브젝트 |  |
| [1:08:22](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4102s) | Scene Color | 씬 색깔 | 화면캡쳐 텍스쳐, URP업그레이드 |
| [1:10:52](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4252s) | Scene Depth | 씬 깊이 | Z버퍼, 가장자리 셰이더 |
| [1:14:19](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4459s) | Screen | 화면크기 |  |

### Texture (텍스쳐)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:14:29](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4469s) | Cubemap Asset | 큐브맵 |  |
| [1:14:50](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4490s) | Sample Cubemap | 큐브맵 샘플 | 창문반사 셰이더 |
| [1:15:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4546s) | Texture 2D Asset | 텍스쳐2D |  |
| [1:16:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4560s) | Sample Texture 2D | 텍스쳐2D 샘플 | 노멀맵 굴절 셰이더 |
| [1:17:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4620s) | Sampler State | 텍스쳐 설정 |  |
| [1:18:38](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4718s) | Sample Texture 2D LOD | 텍스쳐2D 샘플 디테일 |  |
| [1:19:20](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4760s) | Texture 2D Array Asset | 텍스쳐2D 배열 |  |
| [1:19:22](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4762s) | Sample Texture 2D Array | 텍스쳐2D 배열 샘플 | 텍스쳐2D 배열 에셋 |
| [1:20:09](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4809s) | Texture 3D Asset | 텍스쳐3D |  |
| [1:20:11](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4811s) | Sample Texture 3D | 텍스쳐3D 샘플 |  |
| [1:20:15](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4815s) | Texel Size | 텍스쳐의 화소 |  |

## Master (마스터)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:21:09](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4869s) | PBR Master | 물리기반 렌더링 마스터 |  |
| [1:22:04](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=4924s) | Sprite Lit Master, Sprite Unlit Master | 빛, 빛을 안 받는 스프라이트 마스터 | 2D 라이트 |
| [1:23:35](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5015s) | Unlit Master | 빛을 안 받는 마스터 |  |
| [1:23:50](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5030s) | Visual Effect Master | 시각효과 마스터 | Visual Effect Graph |

## Math (수학)

### Advanced (많은)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:24:24](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5064s) | Absolute | 절댓값 |  |
| [1:24:28](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5068s) | Exponential | 지수 | 정적숫자와 소수점 맞추기 |
| [1:25:33](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5133s) | Length | 길이 |  |
| [1:25:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5146s) | Log | 로그 |  |
| [1:26:29](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5189s) | Modulo | 나눈 나머지 |  |
| [1:26:48](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5208s) | Negate | 부정 |  |
| [1:27:04](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5224s) | Normalize | 정규화 |  |
| [1:27:40](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5260s) | Posterize | 포스터화 |  |
| [1:28:17](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5297s) | Reciprocal | 역수 |  |
| [1:28:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5312s) | Reciprocal Square Root | 제곱근의 역수 |  |

### Basic (기본)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:28:44](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5324s) | Add | 더하기 |  |
| [1:28:50](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5330s) | Divide | 나누기 |  |
| [1:28:56](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5336s) | Multiply | 곱하기 |  |
| [1:29:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5356s) | Power | 거듭제곱 |  |
| [1:29:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5372s) | Square Root | 제곱근 |  |
| [1:29:39](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5379s) | Subtract | 빼기 |  |

### Derivative (변화율)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:29:45](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5385s) | DDX, DDXY, DDY | 미분 X, XY, Y | 플랫 셰이더 |

### Interpolation (보간)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:32:38](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5558s) | Lerp | 선형 보간 |  |
| [1:32:49](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5569s) | Inverse Lerp | 역 보간 |  |
| [1:33:10](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5590s) | Smoothstep | 부드러운 보간 |  |

### Matrix (행렬)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:33:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5634s) | Matrix Construction | 행렬 건설 |  |
| [1:34:11](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5651s) | Matrix Split | 행렬 분할 |  |
| [1:34:30](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5670s) | Matrix Determinant | 행렬식 |  |
| [1:35:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5708s) | Matrix Transpose | 행렬 전치 |  |

### Range (범위)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:35:20](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5720s) | Clamp | 제한 |  |
| [1:35:25](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5725s) | Fraction | 소수부 |  |
| [1:35:40](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5740s) | Maximum | 최대 |  |
| [1:35:51](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5751s) | Minimum | 최소 |  |
| [1:35:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5754s) | One Minus 1 | 빼기 |  |
| [1:36:07](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5767s) | Random Range | 랜덤 |  |
| [1:36:14](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5774s) | Remap | 재매핑 |  |
| [1:37:09](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5829s) | Saturate | 포화 |  |

### Round (근삿값)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:37:33](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5853s) | Ceiling | 올림 |  |
| [1:37:41](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5861s) | Floor | 내림 |  |
| [1:37:48](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5868s) | Round | 반올림 |  |
| [1:37:56](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5876s) | Sign | 부호 |  |
| [1:38:07](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5887s) | Step | 단계 |  |
| [1:38:23](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5903s) | Truncate | 자르기 |  |

### Trigonometry (삼각함수)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:38:45](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=5925s) | Sine | 사인 |  |
| [1:40:40](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6040s) | Cosine | 코사인 |  |
| [1:41:02](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6062s) | Tangent | 탄젠트 |  |
| [1:41:29](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6089s) | Arcsine | 아크사인 |  |
| [1:42:00](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6120s) | Arccosine | 아크코사인 |  |
| [1:42:18](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6138s) | Arctangent | 아크탄젠트 |  |
| [1:42:28](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6148s) | Arctangent2 | 아크탄젠트2 |  |
| [1:43:11](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6191s) | Hyperbolic Sine | 쌍곡사인 |  |
| [1:43:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6222s) | Hyperbolic Cosine | 쌍곡코사인 |  |
| [1:43:49](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6229s) | Hyperbolic Tangent | 쌍곡탄젠트 |  |
| [1:44:17](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6257s) | Radians To Degrees | 라디안에서 도 |  |
| [1:44:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6282s) | Degrees To Radians | 도에서 라디안 |  |

### Vector (벡터)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:44:46](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6286s) | Cross Product | 외적 |  |
| [1:46:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6368s) | Distance | 거리 | 가까워지면 사라지는 셰이더 |
| [1:46:41](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6401s) | Dot Product | 내적 | 프레넬 셰이더 |
| [1:48:03](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6483s) | Fresnel Effect | 프레넬 |  |
| [1:49:23](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6563s) | Projection | 투영 |  |
| [1:50:20](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6620s) | Reflection | 반사 |  |
| [1:50:54](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6654s) | Rejection | 거부 |  |
| [1:51:14](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6674s) | Rotate About Axis | 축을 중심으로 회전 |  |
| [1:52:05](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6725s) | Sphere Mask | 구 마스크 |  |
| [1:52:43](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6763s) | Transform | 좌표계 변환 |  |

### Wave (파동)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:53:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6796s) | Noise Sine Wave | 노이즈 파동 |  |
| [1:53:24](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6804s) | Sawtooth Wave | 톱날 파동 |  |
| [1:53:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6822s) | Square Wave | 정사각형 파동 |  |
| [1:53:49](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6829s) | Triangle Wave | 삼각형 파동 |  |

## Procedural (절차)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:53:55](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6835s) | Checkboard | 바둑판 |  |

### Noise (노이즈)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:54:04](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6844s) | Gradient Noise | 그라데이션 노이즈 |  |
| [1:54:22](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6862s) | Simple Noise | 단순한 노이즈 |  |
| [1:54:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6872s) | Voronoi | 세포 | 카툰 물 셰이더 |

### Shape (모양)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:55:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6908s) | Ellipse | 타원 | 모양 마스크 |
| [1:55:21](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6921s) | Polygon | 다각형 |  |
| [1:55:29](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6929s) | Rectangle | 직사각형 |  |
| [1:55:32](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6932s) | Rounded Rectangle | 둥근 직사각형 |  |

## Utility (유틸)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [1:55:39](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=6939s) | Custom Function | 커스텀함수 | 빛 가져오기, hlsl파일, 램버트 공식, 하프 램버트 공식, 블린 퐁 공식, 카툰 셰이더 |
| [2:01:11](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7271s) | Preview | 미리보기 |  |

### Logic (논리회로)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [2:01:29](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7289s) | All | 모든 |  |
| [2:01:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7302s) | And | 그리고 |  |
| [2:01:48](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7308s) | Any | 어떤 |  |
| [2:01:51](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7311s) | Branch | 분기 |  |
| [2:02:04](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7324s) | Comparison | 비교 |  |
| [2:02:35](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7355s) | Is Front Face | 앞면인지 |  |
| [2:02:53](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7373s) | Is Infinite | 무한인지 |  |
| [2:03:05](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7385s) | Is NaN | NaN(숫자 아님)인지 |  |
| [2:03:21](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7401s) | Nand | 부정 그리고 |  |
| [2:03:34](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7414s) | Not | 부정 |  |
| [2:03:39](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7419s) | Or | 또는 |  |

## UV

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [2:03:44](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7424s) | Flipbook | 움직이는 스프라이트 |  |
| [2:05:05](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7505s) | Polar Coordinate | 극 좌표 |  |
| [2:06:28](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7588s) | Radial Shear | 뒤틀림 |  |
| [2:06:35](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7595s) | Rotate | 회전 |  |
| [2:06:48](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7608s) | Spherize | 구형화 |  |
| [2:07:01](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7621s) | Tiling And Offset | 타일과 이동 |  |
| [2:07:18](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7638s) | Triplanar | 삼면 | 부드러운 지형 셰이더 |
| [2:08:42](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7722s) | Twirl | 빙빙 꼬기 |  |

## Vertex Skinning (정점 표현)

| 시간 | 노드 (영문) | 한글 | 메모 |
|---|---|---|---|
| [2:08:57](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7737s) | Linear Blend Skinning | 관절과 피부 혼합 |  |

## 유튜브 셰이더 살펴보기

| 시간 | 주제 |
|---|---|
| [2:09:09](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7749s) | Forcefield 셰이더 |
| [2:10:08](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7808s) | Dissolve 셰이더 |
| [2:10:58](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7858s) | Flame 셰이더 |
| [2:12:18](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7938s) | Portal 셰이더 |
| [2:12:52](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=7972s) | Electricity 셰이더 |
| [2:14:14](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=8054s) | Distortion 셰이더 |
| [2:15:16](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=8116s) | Snow 셰이더 |
| [2:15:41](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=8141s) | Triplanar 셰이더 |
| [2:16:12](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=8172s) | Tornado 셰이더 |
| [2:16:35](https://www.youtube.com/watch?v=KnueAgpUL3Y&t=8195s) | Water 셰이더 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(REF 표)으로 재작성. 오역 정정: Normalize 일반화 → 정규화, Is NaN 허수 → 숫자 아님, Fraction 분수 → 소수부, Advanced 많은 → 고급, 오타 Gragh·Procedual |
