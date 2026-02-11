# OpenClaw AI Assistant (project lisa)

작성일: 2026-02-11

대상 기기: MacBook Air/Pro M1 (8GB RAM), LG 그램

환경: macOS, ZSH, Ollama, Ubuntu Linux

***

### 1. 초기 환경 준비 (Prerequisites)

고성능 AI 환경 구축을 위한 기본 툴 체인 설치 과정입니다.

* Homebrew 설치: 맥용 패키지 관리자 설치
* Node.js 설치: OpenClaw 설치 과정을 node.js 를 활용해 버전 관리와 가상화할 수 있게 환경 구축
* Ollama 설치: 로컬 LLM 구동을 위한 런타임 설치 및 실행
* Shell 설정: ZSH 사용 중이며, 자동 완성 및 환경 변수 관리를 위한 `.zshrc` 수정
  * _Note:_ `command not found: compdef` 발생 시 `autoload -Uz compinit && compinit` 추가 필요

### 2. OpenClaw 설치 및 구성

클라우드와 로컬 모델을 통합 관리하는 OpenClaw의 핵심 세팅입니다.

* 설치 경로: `/Users/lisa/.openclaw/workspace`
* 주요 명령어:
  * `openclaw doctor`: 시스템 상태 진단
  * `openclaw models status`: 연결된 모델 및 쿨다운 상태 확인
* 모델 구성 전략:
  * Cloud: Ollama Cloud (`qwen3-vl:235b-cloud`) - 고성능 추론용
  * Local: `gemma3:4b` - 8GB RAM 환경에서의 최소 테스트용 (성능 한계 확인)
  * Fallback: 클라우드 리미트(HTTP 429) 발생 시 로컬로 전환하는 전략 수립

### 3. 외부 API 및 서비스 연동

Gemini와 같은 외부 고성능 엔진을 활용했던 경험입니다.

* Linux 서버 연동: 이전 리눅스 환경에서 Gemini API를 호출하여 최상의 지능(자비스급 경험) 확인.
* API 티어 관리: 1티어 요금제의 사용량 한도(2\~3일 내 소진) 확인 및 향후 고티어 혹은 로컬 대용량 모델 전환의 필요성 도출.

### 4. iMessage 연동 시도 (현재 미완료)

개인용 비서 'Clara'의 인터페이스를 위한 작업 기록입니다.

* 작업 내용: OpenClaw와 macOS 내장 iMessage DB 연동 시도.
* 발생 이슈:
  * 메시지 데이터베이스(`chat.db`) 접근 권한 문제.
  * 환경 변수 및 경로 설정 불일치.
* 향후 과제: 새 기기에서 전체 디스크 접근 권한(Full Disk Access) 재설정 및 권한 부여 프로토콜 재점검 필요.

### 5. 성능 병목 및 하드웨어 결론 (Retrospective)

* 8GB RAM의 한계: M1 통합 메모리 구조상 4B 이상의 모델은 스왑 발생으로 인해 반응 속도가 현저히 저하됨.
* LLM 지능의 임계점: 비서 시스템으로서 '지능적'인 반응을 얻기 위해서는 최소 70B 이상의 모델(로컬) 혹은 안정적인 클라우드 API(1티어 이상)가 필수적임.
* 최종 결론: 하드웨어를 64GB RAM 이상의 M-Max 칩셋 기기로 업그레이드할 때까지 현재의 워크플로우를 보존하고 로직만 유지함.

### 6. 세션 재시작 또는 게이트웨이 재시작 시 기억 초기화 문제 해결 과정

* OpenClaw 플러그인 중 mem0 을 활용해 자체 DB를 구축
* OpenClaw의 기존 방식 보다 효율적인 토큰 관리 및 세션을 종료(또는 게이트웨이를 재시작)해도 스스로 DB를 참조해 이전 기억을 복구할 수 있다고 함
* 문제는 테스트 과정에서 `qwen3-vl:235b-cloud` 모델의 주간 사용량 제한에 들어 더 이상 테스트를 진행할 수 없다는 결론을 내림

### 7. 추후 작업 시 참고 사항

* 무조건! 꼭! 로컬에서 고성능(양자화 가능한) 모델을 돌릴 수 있는 고성능 하드웨어를 준비한다.\
  (M4 64GB Ram 이상 모델) "재호야 나중에 돈 많이 벌어서 사자..."
* Local 환경에서 돌아가는 LLM 이 Claud 모델일 경우 (Ollama Cloud, Gemini API 등등) Fallback 모델을 따로 추가 설정해서 작업을 지속 가능하도록 세팅해야 한다. (외출해서 테스트 중에 아무리 입력해도 응답이 없어서 답답했음)
* 기존에 사용했던 메신저(OpenClaw를 외부에서 호출해서 사용하기 위해 사용한 채널)은 가능하면 iMessage를 사용하자 (물론 나중에 내가 여전히 맥을 쓴다는 가정하에, 아마도 맥을 안쓰지는 않을 것 같음) + (텔래그램 또는 와츠앱 은 별도의 메신저 서버를 거치는 것이 마음에 들지 않고 + 봇 설정을 잘못하면 중요한 자료를 유출할 경우도 있기 때문에, 텔래그램을 써봤지만 기능이 한정적이라 별로였음)

***

### 🛠 나중에 복구할 때 체크리스트

1. \[ ] 새 Mac에서 `chat.db` 접근 권한 수동 부여
2. \[ ] `openclaw.json` 내 `fallbacks` 리스트에 70B급 로컬 모델 추가
3. \[ ] Ollama Cloud 주간 쿼터 초기화 주기 확인
4. \[ ] Unity/Unreal 엔진 작업과 병행 시 메모리 점유율 최적화
