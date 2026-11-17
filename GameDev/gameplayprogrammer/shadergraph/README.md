# 셰이더 그래프 (Shader Graph)

셰이더 개념, Shader Graph 노드, 툰 셰이더 학습 노트를 모았다. 문서 번호(Task ID)는 `GMD-SGR-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| GMD-SGR-001-DO | 개념 | [셰이더 기초 개념과 종류](01aboutshader.md) | 셰이더 종류, 언어, 그래픽 API, Unity 포맷을 이해한다 |
| GMD-SGR-002-DO | 개념 | [셰이더 및 모델 연구 일지](shaderresearchlog.md) | 모델 준비, 메탈릭, 아웃라인 실험 기록을 본다 |
| GMD-SGR-003-DO | 개념 | [셰이더 강의 메모 (노멀맵, 툰 셰이딩)](shaderlecture2.md) | 노멀맵, 툰 셰이딩, 색 혼합 연산을 이해한다 |
| GMD-SGR-004-REF | 표 | [고라니TV 셰이더 강의 타임라인](goranitvshadertimeline.md) | 강의 영상에서 노드가 나오는 시각을 찾는다 |
| GMD-SGR-005-REF | 표 | [Shader Graph 핵심 노드 입출력 표](shadernodes.md) | Fresnel Effect, Lerp, UV, Dissolve 등의 입력·출력·수식을 찾는다 |

## 읽는 순서

1. GMD-SGR-001-DO로 셰이더 기본을 읽는다.
2. GMD-SGR-003-DO와 GMD-SGR-002-DO로 툰 셰이딩과 아웃라인을 읽는다.
3. 노드를 찾을 때 GMD-SGR-004-REF, GMD-SGR-005-REF를 연다.
