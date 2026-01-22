# 어플리케이션 배포 단위

어플리케이션은 다양한 방식으로 배포될 수 있다. 환경과 기술에 따라 배포 단위가 달라질 수 있다. 다음은 대표적인 배포 단위들을 설명한 것이다.

***

## 1. 실행 파일 (Executable)

* 프로그램이 하나의 실행 가능한 바이너리 파일(.exe, .bin)로 패키징되어 배포된다.
* windows = .exe , Linux = .bin

***

## 2. 라이브러리 및 모듈 (Library / Module)

* 소프트웨어의 일부 기능만 포함하는 배포 단위로, 다른 프로그램에서 참조하여 사용된다.
* 독립적으로 실행되지 않으며, 주로 API나 SDK 형태로 제공된다.
* **대표적인 예시:**
  * .dll (windows dynamic link library)
  * .so (linux shared object)
  * .jar (java archive)
  * .whl (python wheel package)

***

## 3. 패키지 (Package)

* 여러 개의 파일과 라이브러리를 하나로 묶어 배포하는 단위
* 운영체제나 특정 플랫폼에서 실행하기 쉽게 만들어진 형태
* **대표적인 예시:**
  * java: .jar, .war, .ear
  * Python: .whl, .egg
  * Node.js: npm 패키지 (package.json)
  * Linux: .deb, .rpm

***

## 4. 컨테이너 (Container)

* 애플리케이션과 그 실행 환경(라이브러리, 의존성 등)을 함께 패키징하여 배포하는 단위
* 어디서나 동일한 환경에서 실행될 수 있도록 보장
* **대표적인 예시:**
  * Docker Image: .tar
  * Kubernetes Pod: 여러 개의 컨테이너를 포함

***

## 5. 가상 머신 이미지 (VM Image)

* 운영체제(OS)와 애플리케이션을 포함한 전체 시스템을 배포하는 단위.
* 하이퍼바이저(VMware, VirualBox, AWS EC2 등)에서 실행된다.
* **대표적인 예시:**
  * .vmdk (VMware)
  * .vdi (VirtualBox)
  * .ami (AWS)

***

## 6. 서버리스 함수 (Serverless Function)

* 특정 이벤트가 발생할 때 실행되는 배포 단위
* 클라우드 환경에서 인프라 관리 없이 실행 가능한 코드 단위로 배포된다.
* **대표적인 예시:**
  * AWS Lambda (.zip)
  * Google Cloud Functions
  * Azure Functions

***

## 어플리케이션 배포 단위별 비교

| 배포 단위    | 특징                | 예시                                 |
| -------- | ----------------- | ---------------------------------- |
| 실행파일     | 독립적인 실행 파일        | .exe, .bin                         |
| 파이브러리/모듈 | 다른 프로그램에서 참조하는 코드 | .dll, .so, .jar, .whl              |
| 패키지      | 여러 파일을 묶어 배포      | .jar, .war, .deb, .rpm             |
| 컨테이너     | 애플리케이션 + 실행 환경 포함 | Docker Image, Kubernetes Pod       |
| VM 이미지   | OS + 애플리케이션 포함    | .vmdk, .ami                        |
| 서버리스 함수  | 이벤트 기반 실행         | AWS Lambda, Google Cloud Functions |

***

## 어플리케이션 배포 단위 선택 기준

1. **애플리케이션의 특성**
   * 단순한 실행 파일인가?
   * 또는 복잡한 환경이 필요한가?
2. **배포 및 유지보수 용이성**
   * 배포할 때 여러 의존성을 함께 포함해야 하는가?
   * 업데이트가 쉬운가?
3. **운영 환경**
   * 클라우드 환경인가? 온프레미스 환경인가?
   * 컨테이너나 서버리스 환경에서 실행할 것인가?
4. **확장성 및 관리**
   * 여러 서버에서 확장할 필요가 있는가?
   * 단일 파일로 배포할 것인가?
