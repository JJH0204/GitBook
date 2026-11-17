# 애플리케이션 배포 단위

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARC-002-DO |
| 유형 | D&O (개념) |
| 목적 | 애플리케이션 배포 단위(실행 파일, 라이브러리, 패키지, 컨테이너, VM 이미지, 서버리스 함수, 모바일 앱 패키지)의 특징과 선택 기준을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이전 PR에서 정정한 사실을 유지했다. Linux 실행 파일은 ELF(확장자 없음), AMI는 리전 내 이미지 ID, Docker 이미지는 레이어 묶음(tar는 `docker save` 형식), Kubernetes Pod는 오케스트레이션 단위다. 비교 표의 "Kubernetes Pod"와 `.ami`는 이 정정과 모순되어 고쳤다. 모바일 앱 패키지는 원본에 없어 새로 추가했다. 이 문서는 컴퓨터 구조보다 실행 파일·링크 주제에 가깝다(위치 이동은 확인 필요).
{% endhint %}

## 1. 목적

애플리케이션은 여러 방식으로 배포된다. 환경과 기술에 따라 배포 단위가 달라진다. 이 문서는 대표적인 배포 단위를 비교한다.

## 2. 구성 요소

### 2.1 단위별 설명

| 배포 단위 | 설명 | 예 |
|---|---|---|
| 실행 파일 (Executable) | 프로그램이 하나의 실행 가능한 바이너리 파일로 패키징된다 | Windows `.exe`(PE), Linux ELF 실행 파일(보통 확장자 없음, `.bin`은 설치 스크립트 관례) |
| 라이브러리·모듈 (Library / Module) | 기능 일부만 포함하며 다른 프로그램이 참조한다. 독립 실행되지 않고 주로 API나 SDK 형태로 제공된다 | `.dll`(Windows), `.so`(Linux shared object), `.jar`(Java archive), `.whl`(Python wheel) |
| 패키지 (Package) | 여러 파일과 라이브러리를 묶어 배포한다. 운영체제나 플랫폼에서 실행하기 쉽게 만든 형태다 | Java `.jar`, `.war`, `.ear` / Python `.whl`, `.egg` / Node.js npm 패키지(`package.json`) / Linux `.deb`, `.rpm` |
| 컨테이너 (Container) | 애플리케이션과 실행 환경(라이브러리, 의존성)을 함께 패키징한다. 어디서나 같은 환경에서 실행되도록 한다 | Docker Image(레이어로 이루어진 이미지. `docker save`로 내보내면 tar 형식) |
| 가상 머신 이미지 (VM Image) | 운영체제와 애플리케이션을 포함한 전체 시스템을 배포한다. 하이퍼바이저에서 실행된다 | `.vmdk`(VMware), `.vdi`(VirtualBox), AMI(AWS. 파일이 아니라 리전에 저장된 이미지 ID) |
| 서버리스 함수 (Serverless Function) | 이벤트가 발생할 때 실행된다. 인프라 관리 없이 클라우드에서 실행되는 코드 단위다 | AWS Lambda(`.zip` 또는 컨테이너 이미지), Google Cloud Functions, Azure Functions |
| 모바일 앱 패키지 | 모바일 운영체제용 설치 패키지 | Android `.apk`, `.aab`(Play 스토어 게시용 번들), iOS `.ipa` |

{% hint style="info" %}
NOTE: Kubernetes Pod는 컨테이너 배포 단위가 아니라 여러 컨테이너를 묶어 실행하는 오케스트레이션 단위다. `.jar`는 라이브러리와 패키지 양쪽 예로 쓰인다. `.egg`는 오래된 Python 형식이다. `.aab`는 기기에 직접 설치하지 않고 스토어가 기기별 APK를 만든다. 모바일 항목은 확인 필요.
{% endhint %}

### 2.2 배포 단위 비교

| 배포 단위 | 특징 | 예 |
|---|---|---|
| 실행 파일 | 독립적인 실행 파일 | `.exe`, ELF(확장자 없음) |
| 라이브러리·모듈 | 다른 프로그램에서 참조하는 코드 | `.dll`, `.so`, `.jar`, `.whl` |
| 패키지 | 여러 파일을 묶어 배포 | `.jar`, `.war`, `.deb`, `.rpm` |
| 컨테이너 | 애플리케이션 + 실행 환경 포함 | Docker Image(레이어 묶음) |
| VM 이미지 | OS + 애플리케이션 포함 | `.vmdk`, AMI(리전 내 이미지 ID) |
| 서버리스 함수 | 이벤트 기반 실행 | AWS Lambda, Google Cloud Functions |
| 모바일 앱 패키지 | 모바일 OS용 설치 패키지 | `.apk`, `.aab`, `.ipa` |

## 3. 동작 원리: 배포 단위 선택 기준

{% stepper %}
{% step %}
### 애플리케이션의 특성

* 단순한 실행 파일인가?
* 또는 복잡한 환경이 필요한가?
{% endstep %}

{% step %}
### 배포 및 유지보수 용이성

* 배포할 때 여러 의존성을 함께 포함해야 하는가?
* 업데이트가 쉬운가?
{% endstep %}

{% step %}
### 운영 환경

* 클라우드 환경인가? 온프레미스 환경인가?
* 컨테이너나 서버리스 환경에서 실행할 것인가?
{% endstep %}

{% step %}
### 확장성 및 관리

* 여러 서버에서 확장할 필요가 있는가?
* 단일 파일로 배포할 것인가?
{% endstep %}
{% endstepper %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ELF | Executable and Linkable Format. Linux 실행 파일 형식 |
| PE | Portable Executable. Windows 실행 파일 형식 |
| AMI | Amazon Machine Image. AWS 가상 머신 이미지 |
| VM | Virtual Machine. 가상 머신 |
| APK / AAB / IPA | Android Package / Android App Bundle / iOS App Store Package |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [elf.md](../os_memory/executables-and-linking/elf.md) | | ELF |
| [dll.md](../os_memory/executables-and-linking/dll.md) | | DLL |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내가 만든 프로그램(또는 게임)을 친구에게 주려면 어떤 배포 단위를 고를까? 이유를 적어 본다.
- [ ] 컨테이너와 VM 이미지의 차이를 내 말로 설명해 본다.
