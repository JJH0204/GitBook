# Volatility 메모리 분석 도구

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-MEM-007-MP |
| 목적 | Volatility 3를 설치하고 Windows 메모리 덤프에서 프로세스·네트워크·메모리 영역 정보를 출력한다 |
| 적용 대상(Effectivity) | Windows 10/11 (분석 환경), Python 3, Volatility 3 |
| 소요 시간 | 설치 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 설치 단계와 플러그인 목록을 정리한 것이며 설치·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 정정 요지: `netscan`은 "저장된 메모리 데이터 출력"이 아니라 메모리 덤프에서 네트워크 연결과 소켓을 스캔하고, `malfind`는 악성 프로그램을 찾는 것이 아니라 의심스러운 RWX 메모리 영역(코드 인젝션 후보)을 탐지한다. 구글 검색 결과 링크는 공식 저장소·문서 링크로 바꿨다. 고아 문장 "윈도우 시스템 파일"을 삭제하고 비어 있던 "설치 확인" 단계를 채웠다. 설치 단계 `pip install -r requirements.txt`와 선택 단계 설명은 원본에 없어 추가했다(미검증).
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [windowsmemorylayout.md](../windows-internals/windowsmemorylayout.md) | PRG-WIN-001-DO | Windows PE 메모리 레이아웃 |
| [memorylayout.md](memorylayout.md) | PRG-MEM-002-DO | 메모리 레이아웃 (Layout) |

* [Volatility 3 저장소](https://github.com/volatilityfoundation/volatility3)
* [Volatility 3 문서](https://volatility3.readthedocs.io)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | 분석용, 인터넷 연결 | 증거 원본이 있는 PC와 분리한다 |
| 2 | Python | 3.x (Volatility 3 저장소의 요구 버전 확인) | 5-A 단계에서 확인 |
| 3 | Microsoft C++ Build Tools | 최신 | `python-snappy` 빌드에 필요할 때만 |
| 4 | 메모리 덤프 사본 | 분석 허가를 받은 덤프의 복사본 | 원본은 건드리지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 메모리 덤프에는 계정 정보, 암호, 개인 정보가 들어 있을 수 있다. 소유자 또는 조직의 허가를 받은 덤프만 분석한다. 허가 없는 시스템의 덤프 분석은 불법일 수 있다.
{% endhint %}

{% hint style="danger" %}
WARNING: 증거로 쓸 덤프는 원본을 읽기 전용으로 보관하고 해시 값(SHA-256 등)을 기록한 뒤 복사본으로만 분석한다. 원본을 수정하면 증거 능력을 잃는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 분석 결과(계정, 해시, 내부 주소)를 공개 문서나 저장소에 붙이지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 분석용 PC를 준비한다 | 증거 원본이 있는 PC가 아니다 |
| 2 | 분석 허가를 확인한다 | 소유자 또는 조직의 허가가 있다 |
| 3 | 덤프 파일의 해시를 기록한다 | PowerShell `Get-FileHash <덤프 파일>` 결과를 메모한다 |

## 5. 절차

### A. 설치

1. (5-A-01) PowerShell을 연다. 빌드 도구 설치가 필요하면 관리자 권한으로 연다.
2. (5-A-02) Python 설치 여부를 확인한다: `python --version` → 결과: 버전 번호가 출력된다. 없으면 설치한다.
3. (5-A-03) 필요하면 [Visual C++ Build Tools](https://visualstudio.microsoft.com/ko/visual-cpp-build-tools/)를 설치한다. 다음 단계에서 빌드 오류가 날 때만 필요하다.
4. (5-A-04) [python-snappy](https://pypi.org/project/python-snappy/)를 설치한다: `pip install python-snappy` → 결과: 설치가 오류 없이 끝난다. 압축 덤프를 읽을 때 쓰는 선택 구성요소이며 필요 여부는 Volatility 3 문서로 확인한다.
5. (5-A-05) [Volatility 3 소스](https://github.com/volatilityfoundation/volatility3)를 내려받는다: `git clone https://github.com/volatilityfoundation/volatility3.git` → 결과: `volatility3` 폴더가 생긴다.
6. (5-A-06) 폴더로 이동해 의존성을 설치한다: `cd volatility3`, `pip install -r requirements.txt` → 결과: 설치가 오류 없이 끝난다.
7. (5-A-07) 설치를 확인한다: `python vol.py -h` → 결과: 도움말이 출력된다.

### B. 덤프 분석

1. (5-B-01) 시스템 정보를 출력한다: `python vol.py -f <덤프 파일> windows.info.Info` → 결과: 커널 버전, 아키텍처 등 시스템 정보가 출력된다.
2. (5-B-02) 프로세스 계층을 출력한다: `python vol.py -f <덤프 파일> windows.pstree.PsTree` → 결과: 부모·자식 프로세스 트리가 출력된다.
3. (5-B-03) 필요한 플러그인을 같은 형식으로 실행한다. 아래 표를 본다.

| 플러그인 | 출력 |
|---|---|
| `windows.pstree.PsTree` | 프로세스 계층 구조 |
| `windows.psscan.PsScan` | 메모리에서 프로세스 구조체를 스캔해 목록에서 숨겨졌거나 종료된 프로세스 후보까지 출력 |
| `windows.netstat.NetStat` | 네트워크 연결 정보 |
| `windows.netscan.NetScan` | 메모리 덤프에서 네트워크 연결과 소켓을 스캔 |
| `windows.cmdline.CmdLine` | 프로세스별 명령줄 인자 |
| `windows.malfind.Malfind` | 의심스러운 RWX 메모리 영역(코드 인젝션 후보) 탐지 |
| `windows.filescan.FileScan` | 메모리에 있는 파일 객체 스캔 |

{% hint style="info" %}
NOTE: `malfind` 결과는 후보일 뿐이다. 정상 프로그램(JIT 컴파일러 등)도 RWX 영역을 만들 수 있다. 다른 증거와 함께 판단한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `python vol.py -h` | 도움말 출력 | 오류 없음 |
| 2 | `python vol.py -f <덤프 파일> windows.info.Info` | 시스템 정보 출력 | 커널 버전 행이 있다 |

## 7. 복구

1. (7-01) 분석이 끝나면 덤프 사본과 출력 결과를 안전한 위치로 옮기거나 삭제한다.
2. (7-02) 원본 덤프의 해시를 다시 계산해 4단계에서 기록한 값과 같은지 확인한다: `Get-FileHash <덤프 파일>`
3. (7-03) 설치를 되돌리려면 `volatility3` 폴더를 삭제하고 `pip uninstall python-snappy`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성, 플러그인 설명 정정, 증거 보존 경고 추가 |
