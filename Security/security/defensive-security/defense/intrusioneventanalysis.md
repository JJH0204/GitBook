# 침해사고 이벤트 분석 절차

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-014-MP |
| 목적 | 침해가 의심되는 Windows 시스템에서 프로세스, DLL, MFT, Prefetch, 이벤트 로그 아티팩트를 수집하고 분석한다 |
| 적용 대상 | Windows 10/11, 관리자 권한, 자신이 소유·관리하는 시스템 또는 허가받은 실습 환경 |
| 소요 시간 | 약 60분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 분석은 5단계로 진행한다: (1) 아티팩트 수집(Acquisition): 로그, 네트워크 캡처, 메모리 덤프, 시스템 이미지 같은 가공 전 데이터를 모은다. (2) 정보 추출(Extraction): 수집물에서 중요한 정보를 뽑는다. (3) 분석/해석(Interpretation). (4) 침해사고 분석 보고서 작성. (5) 대응 전략으로 대응. 이 문서의 절차는 1~3단계를 다룬다. 내용이 비어 있던 원본 항목(이벤트 로그, SANS PDF 등)은 표 6절에만 이름을 남기고 절차는 쓰지 않았다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Linux 침해 분석 아티팩트](linuxintrusionanalysis.md) | SEC-DEF-013-REF | Linux 쪽 아티팩트 |
| [침해사고 분석 및 대응 절차](securityincidentanalysisresponse.md) | SEC-DEF-015-DO | 분석 환경과 대응 흐름 |
| [Volatility 메모리 분석 도구](../../../../Programming/cs_basics/os_memory/memory-management/memorycheck.md) | - | 메모리 분석 |
| Sysinternals Suite | - | https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite |
| analyzeMFT | - | https://github.com/rowingdude/analyzeMFT |
| Eric Zimmerman's 도구 모음 | - | https://ericzimmerman.github.io/ |
| NirSoft WinPrefetchView | - | https://www.nirsoft.net/utils/win_prefetch_view.html |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 분석 대상 PC | Windows 10/11 | 가능하면 네트워크에서 분리한다 |
| 2 | Sysinternals Suite | 최신 | `procexp64.exe`, `listdlls`, `autoruns`, `pslist`, `psinfo`, `tcpview` 포함 |
| 3 | forecopy_handy | v1.2 | 외부 도구. 출처와 해시를 확인한 뒤 쓴다 |
| 4 | 외부 저장 장치 | 수집물을 담을 용량 | 수집물을 대상 PC의 디스크에 쓰지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 이 절차는 침해 의심 시스템에서 도구를 실행한다. 실행 자체가 Prefetch, 이벤트 로그, 접근 시간을 바꿔 증거를 훼손할 수 있다. 조직의 사고 대응 절차와 증거 보존 규정이 있으면 먼저 따른다. 허가받지 않은 시스템에는 수행하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 침입자가 흔적을 지웠다면 이 방법으로는 침해 사항을 찾을 수 없다. 결과가 깨끗해도 침해가 없다는 뜻이 아니다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 수집한 파일에는 계정, 사용 기록, 브라우저 데이터가 들어 있다. 외부 저장 장치를 안전하게 보관하고 허가받은 분석 담당자만 접근하게 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Sysinternals Suite를 외부 저장 장치에 내려받는다 | 폴더에 `procexp64.exe`가 있다 |
| 2 | PowerShell을 관리자 권한으로 연다 | 제목 표시줄에 `관리자`가 보인다 |
| 3 | 수집물 저장 경로를 정한다 | `<수집 경로>`가 외부 장치를 가리킨다 |

## 5. 절차

### A. 프로세스 확인

1. (5-A-01) `procexp64.exe`를 관리자 권한으로 실행한다 → 결과: 프로세스 트리가 보인다.
2. (5-A-02) 의심 프로세스의 실행 파일(이미지)을 저장한다. 원본은 "프로세스 창에서 이미지를 저장한다"고만 적었다(방법 확인 필요) → 결과: 파일이 `<수집 경로>`에 있다.
3. (5-A-03) 작업 목록을 본다: `tasklist` → 결과: 프로세스 목록이 출력된다.
4. (5-A-04) 서비스 정보와 함께 파일로 저장한다: `tasklist /SVC > <수집 경로>\<날짜>_tasklist.txt` → 결과: 파일이 만들어진다.

### B. DLL 수집

1. (5-B-01) Sysinternals Suite 폴더로 이동한다: `cd <Sysinternals 경로>`
2. (5-B-02) DLL 목록을 파일로 저장한다: `.\listdlls > <수집 경로>\<날짜>_listdlls.txt` → 결과: 프로세스별 `Base`, `Size`, `Path` 목록이 파일에 저장된다.
3. (5-B-03) 서명이 없는 DLL을 확인한다: `.\listdlls -u` → 결과: `Verified: Unsigned` 항목이 출력된다. 서명이 없다는 사실만으로 악성은 아니다. 게시자와 경로를 함께 본다.

### C. forecopy_handy로 아티팩트 수집

1. (5-C-01) 도구가 있는 폴더로 이동한다: `cd <forecopy 경로>`
2. (5-C-02) MFT(파일 메타데이터)를 수집한다: `.\forecopy_handy.exe -m <수집 경로>` → 결과: MFT 파일이 저장된다.
3. (5-C-03) Prefetch(실행된 파일의 이력)를 수집한다: `.\forecopy_handy.exe -p <수집 경로>` → 결과: `.pf` 파일이 저장된다. 파일명이 바뀐 항목이 없는지 확인한다.
4. (5-C-04) 이벤트 로그를 수집한다: `.\forecopy_handy.exe -e <수집 경로>` → 결과: `.evtx` 파일이 저장된다.
5. (5-C-05) 브라우저(Chrome) 데이터를 수집한다: `.\forecopy_handy.exe -c <수집 경로>` → 결과: 브라우저 파일이 저장된다.

### D. 침해 징후 식별

1. (5-D-01) 수집한 `listdlls` 결과에서 명령줄을 검색한다: `findstr /i /c:"command line" <수집 경로>\<날짜>_listdlls.txt` (원본의 `type ... | findstr / "command line"`은 올바른 문법이 아니어서 정정했다) → 결과: 프로세스별 명령줄이 출력된다.
2. (5-D-02) 아래 항목을 하나씩 본다.

| 점검 항목 | 확인할 것 |
|---|---|
| 경로 정보와 파라미터 | 임시 폴더, 사용자 폴더 등 비정상 경로에서 실행된 프로세스 |
| 리니지(부모-자식 관계) | 문서 프로그램이 셸을 자식으로 띄우는 등 비정상 관계 |
| LOL(Living Off the Land) | `powershell`, `cmd` 같은 정상 도구를 악용한 실행 |
| 버전·서명 정보 | 서명 없음, 게시자와 파일 이름 불일치 |
| 네트워크 연결 | 비정상 외부 연결. TCPView 또는 `tcpvcon64`로 확인한다 |

### E. 타임라인 분석

1. (5-E-01) analyzeMFT를 설치한다: Python 3.x 환경에서 `pip install analyzeMFT` → 결과: 설치가 끝난다.
2. (5-E-02) MFT를 CSV로 변환한다: `python analyzeMFT.py -f <수집 경로>\mft\$MFT -l -o MFT.csv` → 결과: `MFT.csv`가 만들어진다. 이 경로와 옵션은 원본 기준이며 확인 필요다.
3. (5-E-03) Prefetch를 분석한다: NirSoft `WinPrefetchView`로 `.pf` 파일을 연다 → 결과: 프로그램을 실행할 때 함께 실행된 DLL 가운데 메모리에 이미 적재된 파일을 볼 수 있다.

## 6. 추가 점검 도구

| 도구 | 용도 |
|---|---|
| 서비스 관리자 (`Win + R` > `services.msc`) | 서비스 확인. "내가 관리할 수 없는 서비스"는 부모(종속성이 부여된) 서비스가 있다는 뜻이다 |
| 레지스트리 편집기 | 시작 프로그램 등록으로 악성코드가 실행되는 것을 막기 위해 자동 실행 키를 확인한다 |
| Autoruns | 자동 실행 항목 전체를 본다 |
| `pslist.exe` | 프로세스 관리 도구 |
| `psinfo.exe` | 시스템 정보 도구 |
| TCPView, `tcpvcon64` | `netstat`의 GUI·명령줄 대응. 프로세스별 연결을 본다 |
| 이벤트 뷰어 | 수집한 `.evtx`를 확인한다 |

## 7. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `<수집 경로>`의 파일 목록 | 수집 파일이 있다 | tasklist, listdlls, MFT, Prefetch, evtx 파일이 있다 |
| 2 | 파일 크기 | 0바이트 파일이 없다 | 모든 파일이 1바이트 이상 |
| 3 | 수집물의 해시 값 기록 | 해시가 기록된다 | `Get-FileHash <파일>` 결과를 분석 기록에 남겼다 |

## 8. 복구

이 절차는 대상 시스템의 설정을 바꾸지 않는다. 수집 도구와 임시 파일은 아래와 같이 정리한다.

1. (8-01) 대상 PC에 복사한 도구가 있으면 삭제한다.
2. (8-02) 수집물은 외부 저장 장치에 보관하고 대상 PC에는 남기지 않는다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 증거 훼손 WARNING과 개인정보 CAUTION을 추가했다. `findstr` 문법을 정정하고, 원본의 날짜·사용자 경로를 `<날짜>`, `<수집 경로>`로 바꿨다. 이미지·출력 예시는 삭제했다. 내용이 없던 항목("이벤트 로그", "Autoruns", "SANS PDF", "과제")은 6절 표로 정리하거나 삭제했다 |
