# install\_Linux

## Platforms

* PC
* Windows
* Virtualbox
* Linux

## 시스템 구조

하나의 PC (정확히는 하나의 저장소)에는 하나의 운영체제만 설치되는 원칙이 있다.

{% stepper %}
{% step %}
### 선택지

* Windows 또는 Linux 중 한 가지 선택
{% endstep %}

{% step %}
### 가상화 옵션

* Windows에서 가상화 프로그램(Virtualbox 등)을 활용해 Windows 내부에서 다른 OS를 구동할 수 있다.
{% endstep %}
{% endstepper %}

Virtualbox Download (https://www.virtualbox.org/)

## Virtualbox 실행 및 스크린샷

!\[Virtualbox 실행화면]\(\[\[Pasted Image 20240723105510\_213.png]])

처음 설치했다면 아무것도 없을 것이다. (이전에 설치한 OS 들이 표시되는 중)

여러 리눅스 버전들 중 centOS Linux 를 설치하려 했지만 정식 지원이 되지 않았다.

시험 출제 기준이 RHEL / Rocky Linux 8, Ubuntu 18.04 이상 이라고 하기에 이중 마음에 드는 Linux를 설치한다.

* 4가지 Linux 중 실기 시험에 반영되는 Linux인 Rocky Linux 8로 결정

버전을 선택(8.9가 없어서 8.10으로)하고 Minimal ISO 로 설치를 진행

* X-Window 설치 안되는 최소화 버전

## 가상 머신 생성 — 설치 흐름

{% stepper %}
{% step %}
### 새 가상 머신 생성

* 새로 만들기 버튼 클릭
* virtualbox 설치
* 새 가상 머신 생성
{% endstep %}

{% step %}
### OS 설치 준비

* 이전에 다운로드 받은 iso 파일 선택 (Rocky Linux 8.10 minimal iso)
* 이후 실행 버튼 누르면 Linux 설치 진행하며 가상 머신이 구동된다.
  * 설치은 첫 실행에만 진행된다.
{% endstep %}

{% step %}
### 설치 진행 중 주요 설정

* 언어 선택
* 환경 설정
* 빨갛게 강조 되는 것들은 모두 설정하면 설치 시작 버튼이 활성화 된다.
* 호스트 이름은 변경할 필요는 없다.
{% endstep %}

{% step %}
### 설치 마무리

* 설치 완료까지 기다리기
* 완료되면 재시작 버튼을 누른다.
{% endstep %}

{% step %}
### 가상 머신 사용 팁

* 가상 머신 안에 갇힌 마우스를 꺼내는 단축키를 편한 키로 변경해주면 좋다.
{% endstep %}
{% endstepper %}

{% hint style="info" %}
TIP
{% endhint %}

## 네트워크 및 서비스

* ssh
* 인터넷
* 포트를 열어서 서비스 가능하도록 설정한다.

가상 머신 복사 본을 더 만들 때 내보내기 사용

## 원격 접속 (Putty)

* Putty 설치 가이드
* 앞서 열어둔 포트 번호와 IP를 활용해 가상 머신에 구동중인 Linux를 서버로, Putty를 클라이언트로 삼아 외부에서 접속하여 제어하는 방식으로 진행

## 스크린샷 모음

* \[\[Pasted Image 20240723105855\_248.png]]
* \[\[Pasted Image 20240723110149\_270.png]]
* \[\[Pasted Image 20240723111846\_349.png]]
* \[\[Pasted Image 20240723112250\_395.png]]
* \[\[Pasted Image 20240723113103\_467.png]]
* \[\[Pasted Image 20240723113207\_489.png]]
* \[\[Pasted Image 20240723113253\_499.png]]
* \[\[Pasted Image 20240723113330\_349.png]]
* \[\[Pasted Image 20240723113423\_511.png]]
* \[\[Pasted Image 20240723113635\_304.png]]
* \[\[Pasted Image 20240723113712\_534.png]]
* \[\[Pasted Image 20240723114129\_626.png]]
* \[\[Pasted Image 20240723114315\_641.png]]
* \[\[Pasted Image 20240723114832\_657.png]]
* \[\[Pasted Image 20240723114847\_663.png]]
* \[\[Pasted Image 20240723115152\_690.png]]
* \[\[Pasted Image 20240723115402\_712.png]]
* \[\[Pasted Image 20240723115517\_716.png]]
* \[\[Pasted Image 20240723115718\_731.png]]
* \[\[Pasted Image 20240723115919\_745.png]]
* \[\[Pasted Image 20240723120050\_760.png]]
* \[\[Pasted Image 20240723120422\_782.png]]
* \[\[Pasted Image 20240723124427\_440.png]]
* \[\[Pasted Image 20240723124452\_940.png]]
* \[\[Pasted Image 20240723124452\_956.png]]
* \[\[Pasted Image 20240723124552\_949.png]]
* \[\[Pasted Image 20240723125003\_976.png]]
* \[\[Pasted Image 20240723130603\_392.png"]]

(상단의 각 항목은 문서에 임베드된 이미지 파일을 가리킵니다.)
