# VMware 기반 프라이빗 클라우드 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-PVC-001-DO |
| 유형 | D&O (개념) |
| 목적 | VMware vSphere 기반 프라이빗 클라우드의 구성 요소(ESXi, vCenter Server, VM, vSwitch, VMFS)와 구축 순서를 설명한다 |
| 확인 상태 | 미검증 (원본은 조각난 메모였다. VMware 공개 개념으로 보충했으며 실제 설치로 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 "나중에 직접 작업해보고 기록을 남기자 (VMware 오류로 진도를 못따라감)"라는 메모가 있었다. 원본에 설치 명령과 화면 절차가 없어 절차(MP) 문서는 만들지 않았다. 직접 실습한 뒤 별도 MP 문서로 추가한다.
{% endhint %}

## 1. 목적

프라이빗 클라우드는 한 조직 안에서만 쓰는 클라우드 환경이다. VMware vSphere는 서버 가상화로 여러 물리 서버를 하나의 자원 풀처럼 관리하는 제품군이다. 이 문서는 그 구성 요소와 역할, 구축 순서를 정리한다.

## 2. 구성 요소

### 2.1 vSphere 구성 요소

| 번호 | 구성 요소 | 위치 | 역할 | 비고 |
|---|---|---|---|---|
| 1 | ESXi | 물리 서버(호스트) | 물리 서버에 직접 설치하는 하이퍼바이저(Hypervisor)다. VM을 실행한다 | 원본의 ESXi HOST |
| 2 | VM | ESXi 위 | 가상 머신이다. 운영체제를 올려 쓴다 | 원본 예: Ubuntu, Windows Server, Windows 10 |
| 3 | vCenter Server | 별도 VM 또는 어플라이언스 | 여러 ESXi 호스트를 한 곳에서 관리한다 | 원본의 "ESXi HOST 관리" |
| 4 | vSphere | 전체 | ESXi와 vCenter Server 등을 묶은 제품군 이름이다 | 원본의 `ESXi + vCenter` |
| 5 | vSwitch(가상 스위치) | ESXi 호스트 안 | VM과 물리 네트워크를 연결하는 가상 네트워크 장치다 | |
| 6 | VMFS | 데이터스토어 | VM의 디스크 파일을 저장하는 VMware 전용 파일 시스템이다 | 원본: "VM 시스템에서 파일을 인식하기 위한 시스템" |

### 2.2 구조 관계

| 번호 | 관계 | 설명 |
|---|---|---|
| 1 | 물리 서버 1대에 ESXi 1개 | ESXi 위에 VM 여러 개가 실행된다 |
| 2 | ESXi 여러 개에 vCenter Server 1개 | vCenter Server가 호스트 여러 대를 통합 관리한다 |
| 3 | ESXi 단독 사용 | vCenter Server 없이도 ESXi 호스트 하나를 직접 관리할 수 있다. 호스트 간 기능(여러 호스트를 묶는 기능)은 vCenter Server가 필요하다 |

## 3. 동작 원리

### 3.1 구축 순서

원본의 "설치 시나리오"를 순서로 정리했다.

1. ESXi 호스트를 설치한다.
2. vCenter Server를 설치하고 ESXi 호스트를 등록한다.
3. 가상 스위치(vSwitch)로 네트워크를 구성한다.
4. 데이터스토어(VMFS)를 준비한다.
5. VM을 생성하고 운영체제를 설치한다.

### 3.2 시나리오 예시 (원본 메모)

원본은 아래 단어만 나열했다. 의미는 정확히 확인하지 못했다.

| 번호 | 원본 단어 | 해석 | 확인 |
|---|---|---|---|
| 1 | 교육부, 운영부 | 부서별로 VM과 네트워크를 나누는 시나리오 예시로 보인다 | 확인 필요 |
| 2 | ubuntu, win ser, win10 | 시나리오에 쓰는 VM의 운영체제로 보인다 | 확인 필요 |

## 4. 약어·용어

| 용어 | 풀이 |
|---|---|
| ESXi | VMware의 베어메탈 하이퍼바이저 |
| vCenter Server | 여러 ESXi 호스트를 중앙 관리하는 서버 |
| vSphere | VMware 서버 가상화 제품군 |
| VMFS | Virtual Machine File System |
| vSwitch | Virtual Switch, 가상 스위치 |
| 호스트(HOST) | ESXi가 설치된 물리 서버 |

## 5. 참조

외부 참조:

* VMware Hands-on Labs 카탈로그(온라인 실습 사이트): https://labs.hol.vmware.com/HOL/catalog

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] ESXi와 vCenter Server의 역할 차이를 내 말로 설명한다.
- [ ] 프라이빗 클라우드와 AWS 같은 퍼블릭 클라우드의 차이를 내가 겪은 경험과 연결해 적는다.
- [ ] 실습 중 막혔던 오류가 있다면 증상과 원인을 적는다.
