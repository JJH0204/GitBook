# 트러블슈팅 노트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UTS-001-REF |
| 유형 | REF (노트 작성 규칙과 후보 목록 표) |
| 목적 | 실제로 겪은 문제를 4단계로 정리하는 노트의 작성 규칙과 후보 목록을 제공한다 |
| 적용 대상 | Unity 6000.3, URP, Windows 팀 프로젝트 사례 |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 수치는 원본 그대로이고 이 환경에서 재측정하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 작성 규칙

1. 실제로 겪은 문제를 [템플릿](template.md)(GMD-UTS-002-REF)의 4단계로 정리한다: 문제 상황 → 원인 분석 → 해결 과정 → 수치화된 결과.
2. 노트는 AI 없이 내 말로 쓴다. 면접관은 노트의 모든 문장에 "왜요?"라고 물을 수 있다.
3. 파일 이름은 `NN-짧은-제목.md`로 한다. 예: `01-frame-spike.md`

## 2. 후보 목록

후보는 팀 프로젝트(Unity 6000.3, URP, Windows)에서 실제로 있었던 일이다. 자세한 수치와 경위는 Drive 기획서 폴더의 계획서 문서와 팀 저장소 커밋에서 확인한다.

| # | 제목 | 분류 | 핵심 사실 | 쓰는 날 |
|---|---|---|---|---|
| 01 | 전투 초반 프레임 스파이크 | 성능 | 풀링이 원인이라는 가설을 측정으로 기각. 스파이크의 74~81%가 VFX 첫 사용 초기화였다. PSO 워밍업으로 100ms 넘는 프레임이 4 → 0 | [Day 22](../day22-troubleshooting-performance.md) |
| 02 | 투사체가 바닥에 먹히는 버그 | 버그(물리) | `SphereCastNonAlloc`이 시작부터 겹친 바닥을 distance 0으로 보고해서 벽으로 오판했다. 한 줄 수정 후 명중 0/10 → 6/6 | [Day 23](../day23-troubleshooting-bug.md) |
| 03 | 종료할 때 크래시 | 크래시(엔진) | D3D12 PSO 라이브러리 캐시를 저장하다 해제된 메모리를 읽는 Unity 엔진 버그. 실행 인자로 우회했고, 이후 D3D11 전환으로 경로 자체가 사라짐 | Day 23 선택 재료 |
| 04 | D3D12 → D3D11 전환 결정 | 의사결정 | D3D11에서는 PSO 기록이 0개, 셰이더 비용이 프레임당 최대 0.8ms였다. 주의할 점: D3D11 전용 빌드를 `-force-d3d12`로 실행하면 VFX Graph 이펙트가 전부 사라지므로 비교 기준선으로 쓸 수 없다 | 직접 |
| 05 | BGM 첫 재생 끊김 | 성능(오디오) | BGM이 Decompress On Load로 설정돼 있어서 첫 `Play()` 때 메인 스레드에서 트랙 전체를 디코드했다(`SoundManager.LoadFMODSound`가 들어간 프레임 최대 743ms). `AssetPostprocessor`로 BGM을 Streaming으로 자동 설정했다. 빌드 측정은 아직 하지 않았다 | 직접 |
| 06 | 방에 들어갈 때 적 동기 스폰 스파이크 | 성능(스크립트) | 방 진입 시 적을 한 번에 동기 스폰해서 최대 274ms가 걸렸다(D3D11 전투 측정). **아직 해결 안 됨.** 직접 고치고 노트로 쓰면 가장 좋은 사례가 된다 | 직접 |
| 07 | PlayMode 테스트가 멈추는 문제 | 에디터 도구 | "Play From Splash" 메뉴가 도메인 리로드 때 종료 핸들러를 잃어버려 `playModeStartScene`이 그대로 남았다. `[InitializeOnLoad]` + `SessionState` 플래그로 고쳤다 | 직접 |
| 08 | git에서 내용이 같은데 수정됨으로 뜨는 파일 | 도구(Git) | `core.autocrlf=true`인데 Unity가 LF로 저장해서, git이 크기만 보고 수정됐다고 판단했다(diff는 비어 있음). 체크아웃이 막힐 때 `git add`로 stat을 갱신해 해결했다 | 직접 |

## 3. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [template.md](template.md) | GMD-UTS-002-REF | 트러블슈팅 노트 템플릿 |
| [../day22-troubleshooting-performance.md](../day22-troubleshooting-performance.md) | GMD-UCS-023-TS | Day 22 프레임 스파이크 |
| [../day23-troubleshooting-bug.md](../day23-troubleshooting-bug.md) | GMD-UCS-024-TS | Day 23 투사체 버그 |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 작성 규칙 절과 작업 식별 추가 |
