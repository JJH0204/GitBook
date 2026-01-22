# flare

{% stepper %}
{% step %}
### 초기 준비

* 실시간 보안 끄기
* 설치 파일 다운로드 후 압축 해제하고 install 파일 확인

<br>

* 관리자 권한으로 실행

\
&#x20;

* 설치 완료 후 스크린샷 / 상태 확인

<br>
{% endstep %}

{% step %}
### 추가 도구 및 설정

* gpedit.msc에서 안되면 아래 사이트에서 파일 설치\
  Bitdefender 설치: https://www.bitdefender.com/
* 암호 설정
* ollydbg.vm 추가
* PracticalMalwareAnalysis-Labs git 설치
* 윈도우 자동 업데이트 끄기
{% endstep %}

{% step %}
### 사용 가능한 도구

정적 분석 도구:

* PEID / EXEINFO PE / BinText / PEView / Strings / Dependency Walker

동적 분석 도구:

* Process Explorer / Process Monitor / Autoruns / Wireshark / IDA DisAssembler / ollyDBG (Sysinternals로 한번에 설치 가능) / HxD
* git에서 설치하면 됨
{% endstep %}

{% step %}
### 분석 시 확인 항목 (예시)

* 컴파일 시점
* 패킹 여부
* 코드 내 함수 실행(Import)
* 호스트 기반 증거
* 네트워크 기반 증거
* 목적
* 대응방안
* virustotal.com 등 활용
{% endstep %}
{% endstepper %}

## 정적 분석

패킹(Packing) - 언패킹(Unpacking)\
패커(Packer) = 난독화/압축/암호화 관련 툴

UPS

pe - 실행파일

&#x20; \= PE Header\
&#x20;\= PE Body

: 도스 호환을 위해 현재까지 사용 중인 헤더\
, mz = 실행파일이다\
시그니처 = 매직넘버 (참고): https://gist.github.com/leommoore/f9e57ba2aa4bf197ebc5

\
Signature는 위와 다름\
&#x20;(파일의 속성값) 컴파일 시간을 알 수 있다.<br>

### 도구별 스냅샷 / 비고

PEID<br>

* 패킹 여부 확인이 안됨

EXEINFO PE<br>

* 편집기 / 컴파일 시간 확인 가능
* 패킹 여부를 확인할 수 있다.

OLLYDBG<br>

* 실행파일의 어셈블리 코드를 확인할 수 있다.
* 악성코드의 공격 방식을 대략적으로 확인할 수 있다.<br>
* 함수의 내용이 중요

HxD<br>

* 상세한 헥사 코드 분석
* kernel32.dll의 영향으로 시간 값이 바뀌는 것을 예상할 수 있다

BinText<br>

* 모든 텍스트 문자열을 읽기 쉽게 정리

## 동적 분석

동적 분석은 스냅샷을 찍어서 프로그램의 실행 전과 후를 비교할 수 있도록 한다.

* 스크린샷 찍어두고 악성코드 실행

## 샘플 분석 예시 (요약)

* 컴파일 시점: 10년10월4일
* 패킹 여부: 안함
* 코드 내 함수 실행(Import): Kernel32.dll -> Kerne132.dll로 복제
* 호스트 기반 증거: Kerne132.dll
* 네트워크 기반 증거: Lab01-01.dll (WS2\_32.dll 실행/127.26.152.13)
* 목적: Kerne132.dll를 생성 → 시스템을 지연 → 악성프로그램 탐지 방지 → 공격자 시스템으로 백도어 설정
* 대응방안: 불필요한 프로세스 중지 및 기존 서비스 내용 확인, 백신 프로그램 설치

DLL 파일에 대한 사전 정보:\
https://learn.microsoft.com/ko-kr/cpp/build/kinds-of-dlls?view=msvc-170

## 관련 실습 자료

* [Lab03-01](/broken/pages/6b36ba692c21a31e37e31942a829772a06296597)
* [Lab05](/broken/pages/8f5cea869353c75c17c9eb5f7c342f12906aa125)
* [Lab06](/broken/pages/b4c6ed4bc160d23aba7e866e6283b2d07c75127b)
* [Lab07](/broken/pages/c6e517620e2197a574fde8dbf1fc6ed5591855d2)
* [Lab09](/broken/pages/be6c560cb8b06a6edcc94eb404a4e19ccb07e7ab)
