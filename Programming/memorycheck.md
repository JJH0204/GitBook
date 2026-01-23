# MemoryCheck

[volatility](https://www.google.com/search?q=volatility\&oq=volatility\&gs_lcrp=EgZjaHJvbWUyDAgAEEUYORixAxiABDIHCAEQABiABDIHCAIQABiABDIHCAMQABiABDIHCAQQABiABDIHCAUQABiABDIHCAYQABiABDIHCAcQABiABDIHCAgQABiABDIHCAkQABiABNIBCTEwMTA0ajBqN6gCCLACAQ\&sourceid=chrome\&ie=UTF-8)

## 설치 과정

{% stepper %}
{% step %}
### 파이썬 설치 여부 확인

* powershell 관리자 권한으로 실행
{% endstep %}

{% step %}
### 빌드 툴 설치

https://visualstudio.microsoft.com/ko/visual-cpp-build-tools/
{% endstep %}

{% step %}
### snappy 설치

https://pypi.org/project/python-snappy/
{% endstep %}

{% step %}
### 소스 다운

https://github.com/volatilityfoundation/volatility3
{% endstep %}

{% step %}
### 설치 확인
{% endstep %}
{% endstepper %}

## 테스트

다음 명령으로 테스트합니다:

{% code title="테스트 명령" %}
```bash
python vol.py windows.info.Info
```
{% endcode %}

[윈도우 시스템 파일](/broken/pages/c9e2efa1dfb18dc91a56fc6cfb98315704579015)

메모리 파일을 지정하여 시스템 정보를 출력하는 예:

{% code title="시스템 정보 출력" %}
```bash
python vol.py -f memory.mem windows.info.Info
```
{% endcode %}

다음은 주요 플러그인들(예시)입니다:

* windows.pstree.PsTree: 프로세스 계층 구조
* windows.psscan.PsScan: 숨겨진 프로세스 목록
* windows.netstat.NetStat: 네트워크 정보
* windows.netscan.NetScan: 저장된 메모리 데이터 출력
* windows.cmdline.CmdLine: CMD 명령어 정보 출력
* windows.malfind.Malfind: 메모리에 상주하는 악성 프로그램 찾는다
* windows.filescan.FileScan
