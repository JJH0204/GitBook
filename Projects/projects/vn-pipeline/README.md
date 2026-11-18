# VN-Pipeline 해체 분석

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-001-DO |
| 유형 | D&O (프로젝트 개요, 해체 분석 시리즈 안내) |
| 목적 | VN-Pipeline의 기능 지도와 전체 구조를 보이고, 페이지별 읽는 순서를 안내한다 |
| 확인 상태 | 미검증 (소스와 설계 문서를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

VN-Pipeline은 로컬 ComfyUI로 연애 시뮬레이션·비주얼 노벨용 에셋(캐릭터 시안, 표정 차분 스탠딩, 이벤트 CG, 배경)을 만드는 파이프라인이다. 여기에 게임 리소스(스프라이트 시트, 도트, 아이콘), 이미지·3D 모델에서 태그를 뽑는 기능, 포즈 ControlNet, 영상에서 3D 동작을 뽑는 모션 파이프라인이 더해졌다. 생성은 모두 한 대의 로컬 PC에서 처리하므로 API 비용이 들지 않는다.

{% hint style="info" %}
NOTE: 소스는 공개 레포 [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline)이다(MIT 라이선스, 모델 파일은 레포에 없다). 이 시리즈는 해당 레포의 커밋 `2beb8c9`(모션 파이프라인 추가) 시점을 읽고 쓴 것이다.
{% endhint %}

{% hint style="warning" %}
WARNING: 이 문서의 모든 동작 설명은 소스 코드와 설계 문서를 읽고 판단한 것이며, 실행해 확인하지 않았다(미검증). 접속 주소, 계정, 토큰 같은 값은 문서에 적지 않았다.
{% endhint %}

## 프로젝트 개요

| 항목 | 내용 | 출처 |
|---|---|---|
| 하는 일 | 프롬프트·캐릭터 설정을 ComfyUI 그래프로 바꿔 제출하고, 결과를 갤러리로 관리한다 | `README.md` |
| 구성 | 생성 로직 라이브러리(`vnlib/`) + CLI(`vn.py`) + 웹 GUI 서버(`studio/`) + 외부 엔진(ComfyUI) | 레포 구조 |
| 언어·런타임 | Python 3.13, 엔진 번들 Python(`aiohttp`, `Pillow`, `numpy`, `onnxruntime`) | `docs/STUDIO_SPEC.md` 0절 |
| 서버 | `aiohttp` 단일 프로세스, 로컬 전용 바인드, 기본 포트 8190 | `studio/server.py` |
| 화면 | 빌드 도구 없는 순수 HTML·CSS·JS(ES modules), 외부 CDN 의존 없음 | `studio/web/`, 설계 문서 |
| 엔진 | ComfyUI(포트 8188), Studio가 자식 프로세스로 켜고 끈다 | `studio/comfy_link.py`, `start.sh` |
| 저장 | 설정 JSON(`config/`), 캐릭터 JSON(`characters/`), 작업 기록 SQLite(`user/studio/jobs.sqlite3`), 이미지(`output/`) | `studio/common.py` |
| 대상 환경 | 외장 SSD에 설치한 macOS(Apple Silicon) 한 대 | 설계 문서 0절 |
| 코드 규모 | `studio/*.py` 약 6,250줄(서버 833, 작업 큐 1,069, 원격 접속 809), `vn.py` 433줄, `studio.sh` 277줄 | `wc -l` |
| 라이선스 | 코드 MIT. 모델은 모델마다 조건이 다르다(일부는 상업 이용 금지) | `README.md` |

## 기능 지도

| 기능 | 하는 일 | 서버 쪽 모듈 | 해설 페이지 |
|---|---|---|---|
| 생성·캐릭터·배경 | 프롬프트, 시안, 스프라이트, CG, 배경을 그래프로 만들어 제출 | `studio/jobs.py`, `vnlib/graphs.py` | [그래프와 프리셋](graphs-presets.md) |
| 프리셋·LoRA·설정 | 체크포인트·샘플러·품질 태그 묶음, LoRA 메모와 호환성 판정, 전역 설정 | `studio/library.py`, `vnlib/modelinfo.py` | [작업 큐와 라이브러리](jobs-library.md) |
| 작업 큐 | 제출, 진행률, 취소, 재시도, 서버 재시작 복구 | `studio/jobs.py`, `studio/comfy_link.py` | [작업 큐와 라이브러리](jobs-library.md) |
| 갤러리 | 이미지 스캔, 메타데이터 읽기, 썸네일, 휴지통 | `studio/gallery.py` | [작업 큐와 라이브러리](jobs-library.md) |
| 시크릿 모드 | 켜 둔 동안의 기록과 그림을 끄면 지운다 | `studio/secret.py` | [시크릿과 원격 접속](secret-remote.md) |
| 원격 접속 | 테일넷 안의 허용된 사용자만 휴대폰·다른 PC에서 접속 | `studio/remote.py` | [시크릿과 원격 접속](secret-remote.md) |
| 포즈 ControlNet | 3D·이미지에서 뼈대 그림을 만들어 생성에 쓴다 | `studio/poses.py`, `vnlib/pose.py` | [포즈 ControlNet](pose-controlnet.md) |
| 스프라이트 시트 | 동작 × 4방향 프레임을 한 장으로 | `vnlib/spritesheet.py` | [스프라이트 시트](spritesheet.md) |
| 태깅·도트·아이콘 | Danbooru 태그 추출, 도트 변환, 아이콘 세트 | `studio/tagging.py`, `vnlib/tagger.py` | [태깅·도트·아이콘](tagging-icons-dots.md) |
| 모션 | 영상 속 사람의 동작을 Unity용 FBX로 | `studio/motion.py`, `motion/` | [모션 파이프라인](motion.md) |

## 전체 구조 그림

```
  브라우저 (Studio 화면, 휴대폰 포함)
     |  HTTP (JSON) + SSE(/api/events)
     v
 [ studio/server.py ]  aiohttp, 127.0.0.1:8190 에만 바인드
     |  미들웨어: errors -> guard(호스트·원격·Origin 검사)
     |
     +-- Library ---- config/*.json, models/ 스캔
     +-- JobManager -- JobStore(SQLite) --- vnlib.graphs.build() 로 그래프 생성
     |       |
     |       +-- ComfyLink ---- HTTP /prompt /queue /history ---+
     |       |                  WebSocket(상시, 진행·미리보기) --+--> ComfyUI (8188)
     |       +-- 프로세스 관리(start.sh 실행·종료)               |       output/ 에 PNG 저장
     +-- Gallery ------ output/ 스캔, 썸네일 캐시 <---------------+
     +-- Secret / Remote / Downloads / Tagging / Poses / Motion
     |
     +-- EventHub -- SSE 로 status·job·preview·download·motion 방송

 [ vn.py ]  CLI. 같은 vnlib 로 그래프를 만들어 ComfyUI 에 직접 제출 (Studio 불필요)
 [ studio.sh ]  서버 실행기. 이미 떠 있으면 재사용, --open 이면 앱 창까지 연다
```

핵심 설계는 세 가지다.

1. **그래프 생성은 라이브러리 한 곳**: CLI와 GUI가 같은 `vnlib.graphs.build()`를 쓴다. 그래서 설정 파일과 결과가 두 경로에서 같다.
2. **브라우저는 ComfyUI에 직접 가지 않는다**: ComfyUI가 Origin이 다른 요청을 막으므로, 모든 통신을 Studio 서버가 중계한다. 서버는 이 덕분에 인증·경로 검사·진행 추적을 한곳에서 한다.
3. **진행 상태는 이벤트로 밀어 준다**: 서버가 ComfyUI의 WebSocket 메시지를 받아 작업 진행률로 바꾸고, SSE로 모든 화면에 방송한다.

## 읽는 순서

1. [구조 지도](structure.md): 디렉터리와 진입점(`vn.py`, `studio.sh`, `start.sh`)을 먼저 본다.
2. [서버](server.md): 라우팅, 미들웨어, 요청 한 건의 처리 흐름.
3. [작업 큐와 라이브러리·갤러리](jobs-library.md): 서버의 중심 세 모듈.
4. [시크릿 모드와 원격 접속](secret-remote.md): 데이터를 지우는 모드와 바깥에서 접속하는 경로의 방어 구조.
5. 생성 로직 쪽(`vnlib/`): [생성 그래프와 프리셋](graphs-presets.md) → [포즈 ControlNet](pose-controlnet.md) → [스프라이트 시트](spritesheet.md) → [태깅·도트·아이콘](tagging-icons-dots.md) → [모션 파이프라인](motion.md).

## 페이지 목록

| 페이지 | 유형 | 내용 |
|---|---|---|
| [structure.md](structure.md) | REF | 디렉터리, 진입점, 설정·데이터 파일 위치 |
| [server.md](server.md) | REF | API 경로 표, 미들웨어, 요청 한 건의 처리 흐름 |
| [jobs-library.md](jobs-library.md) | D&O | 작업 큐, 라이브러리(프리셋·LoRA), 갤러리, 다운로드, 캐릭터 API |
| [secret-remote.md](secret-remote.md) | D&O | 시크릿 모드와 원격 접속의 방어 구조 |
| [graphs-presets.md](graphs-presets.md) | D&O | 생성 그래프와 프리셋 |
| [pose-controlnet.md](pose-controlnet.md) | D&O | 포즈 ControlNet |
| [spritesheet.md](spritesheet.md) | D&O | 스프라이트 시트 |
| [tagging-icons-dots.md](tagging-icons-dots.md) | D&O | 태깅·도트·아이콘 |
| [motion.md](motion.md) | D&O | 모션 파이프라인 |

## 확인 필요

- 설계 문서(`docs/STUDIO_SPEC.md`)는 구현 계약서로 쓰였고 일부가 코드보다 오래됐다. 예를 들어 Job 객체의 `queue_position`·`pose`·`secret` 필드와 갤러리 종류 `pixel`·`sheet`·`icon`은 코드에만 있다. 이 시리즈는 코드를 기준으로 썼다.
- `README.md`의 `ComfyUI/motion-pipeline/` 설명은 "지금은 그대로는 실행되지 않는다"고 적혀 있다. 이 시리즈는 그 부분을 다루지 않는다.
- 레포에는 `tests/motion/test_motion.py` 한 파일만 있다(모션 보정 단위 테스트). 서버·그래프 테스트는 레포에 없다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 도구를 CLI에서 시작해 웹 GUI까지 키우게 된 이유를 내 말로 적어 보자.
- [ ] 브라우저가 ComfyUI에 직접 붙지 않고 서버가 중계하게 한 설계가 무엇을 쉽게 만들었는지 적어 보자.
- [ ] 로컬 전용 도구에 원격 접속을 붙이면서 가장 신경 쓴 점이 무엇이었는지 적어 보자.
