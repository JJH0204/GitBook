# IntrusionEventAnalysis

## 1) 침해사고 아티팩트 수집 (Acquisition)

* 가공되지 않은 데이터 자체 (로그 / 네트워크 트래픽 캡쳐 / 메모리 덤프 / 시스템 이미지 등)
* Process / Event Log / MFT (Master File Table) / Prefetch / Suspicious File / Memory Dump / Web Browser (Cookie, history, cache, ...) / Persistence / Registry / ...

## 2) 정보 추출 (Extraction)

* 수집된 아티팩트에서 중요한 정보를 추출

## 3) 분석/해석 (Interpretation)

* 수집된 정보를 분석

## 4) 침해사고 분석 보고서 작성

## 5) 대응 전략을 통해 대응

***

## 분석 과정

{% stepper %}
{% step %}
### 준비: Sysinternals 설치 및 Process Explorer 실행

1. [sysinternals suite](https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite) 설치
2. procexp64.exe를 관리자 권한으로 실행
{% endstep %}

{% step %}
### 프로세스 이미지 저장

프로세스 창에서 이미지(실행 파일) 저장
{% endstep %}

{% step %}
### PowerShell 열기 및 작업목록 확인

1. PowerShell을 관리자 권한으로 실행
2. 작업 목록 보기:

```powershell
tasklist
```
{% endstep %}

{% step %}
### 작업 목록을 파일로 저장

```powershell
tasklist /SVC > 241105_tasklist.txt
```
{% endstep %}

{% step %}
### Listdlls 실행하여 DLL 목록 수집

sysinternals suite를 설치한 경로로 이동하여 실행:

```powershell
.\listdlls
# 예:
.\listdlls > C:\Users\Administrator\Desktop\241105_listdlls.txt
```

예시 출력:

{% code title="listdlls 출력 예" %}
```
Listdlls64.exe pid: 3932
Command line: "C:\SysinternalsSuite\Listdlls.exe"

Base                Size      Path
0x000000004d140000  0x38000   C:\SysinternalsSuite\Listdlls64.exe
0x000000007c3d0000  0x1f8000  C:\WINDOWS\SYSTEM32\ntdll.dll
0x000000007c090000  0xc2000   C:\WINDOWS\System32\KERNEL32.DLL
...
```
{% endcode %}
{% endstep %}

{% step %}
### 서명(Unsigned) 정보 확인

```powershell
.\listdlls -u
```

예시 출력:

{% code title="listdlls -u 출력 예" %}
```
0x00000000287e0000  0x235000  C:\WINDOWS\assembly\NativeImages_v4.0.30319_64\Microsoft.Pae3498d9#\471d3ed897a0c12882e7d71d405f7f28\Microsoft.PowerShell.Commands.Management.ni.dll
    Verified:    Unsigned
    Publisher:   Microsoft Corporation
    Description: Microsoft Windows PowerShell Management Commands
    Product:     Microsoft (R) Windows (R) Operating System
    Version:     10.0.19041.3636
    File version:10.0.19041.3636
    Create time: Thu Aug 23 16:05:48 2068
```
{% endcode %}
{% endstep %}

{% step %}
### 주의사항: 흔적이 지워진 경우의 한계

만약 침입자가 흔적을 지웠다면 위와 같은 방법으로는 침해 사항을 찾을 수 없습니다.
{% endstep %}
{% endstepper %}

***

## Forecopy

* [설치경로 (forecopy\_handy)](https://github.com/proneer/Tools/blob/master/forecopy/forecopy_handy\(v1.2\).7z)
* MFT(파일의 메타데이터) 수집:

```powershell
.\forecopy_handy.exe -m .\
```

* Prefetch (시스템에서 실행된 파일의 이력) 수집:

```powershell
.\forecopy_handy.exe -p .\
```

중요) 파일명이 변경된 항목이 없는지 잘 확인하세요.

* 이벤트 로그:

```powershell
.\forecopy_handy.exe -e .\
```

* 브라우저(Chrome) 데이터:

```powershell
.\forecopy_handy.exe -c .\
```

***

## 이벤트 로그

***

## 레지스트리 편집

* 시작프로그램으로 등록되어 악성코드가 실행되는 것을 방지해야 함

***

## 서비스 관리자

win+R > service.msc

* "내가 관리할 수 없는 서비스"는 부모(종속성이 부여된) 서비스가 있다는 의미입니다.

***

## Autoruns

(Autoruns 관련 도구 활용)

***

## pslist.exe

* 프로세스 관리 도구

***

## psinfo.exe

***

## 주요 침해사고 징후 식별 방법

* 경로 정보 및 파라미터 분석
* 리니지(족보, 혈통) 분석
* LOL (Living Off the Land) 프로세스 동작 여부 분석
* 버전 정보 및 서명 정보 확인
* 프로세스의 네트워크 연결 이상 징후 분석

문자열 검색 예:

```powershell
type listdlls.txt | findstr / "command line"
```

또는 텍스트 파일을 열어 직접 검색

***

## SANS PDF

***

## TCPview.exe

* netstat 명령어의 GUI 버전

## tcpvcon64

* 연결 확인 툴

***

## 타임라인 분석

* analyzeMFT (GitHub): https://github.com/rowingdude/analyzeMFT

예시 명령:

```bash
python analyzeMFT.py -f C:\forecopy_handy\mft\$MFT -l -o MFT.csv
```

* Python 3.x 환경 / pip로 analyzeMFT 설치 후 실행
* Eric Zimmerman's 도구 모음: https://ericzimmerman.github.io/#!index.md

***

## Prefetch 분석

* NirSoft Win Prefetch View: https://www.nirsoft.net/utils/win\_prefetch\_view.html
* 특정 프로그램을 실행하기 위해 함께 실행되는 DLL 파일들 중 메모리에 이미 적재된 파일들을 확인할 수 있음

***

과제

* 윈도우 시스템 침해사고 분석 스크립트 작성(.bat / .ps1)

***

관련 문서

* [윈도우 취약점 분석](/broken/pages/ec37a3b0f30c7cbb885a10ef1401a8c5d54f96dd)
* [리눅스 침해사항 분석](/broken/pages/c1a53e504c0d0277d45c7cdaded4d2ae81e9cf1a)
* [메모리 점검](file:///2237607/cs_basics/MemoryCheck.md)
