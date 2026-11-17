# 방화벽 장치 유형 (Firewall)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-NSC-005-DO |
| 유형 | D&O (개념) |
| 목적 | 방화벽의 역할과 유형, 대표 방화벽 장치를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 보안 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 대표 장치 링크와 외부 참고 링크만 있었다. 방화벽 정의와 유형 비교는 원본에 없던 내용을 보충한 것이다.
{% endhint %}

## 1. 목적

방화벽(Firewall)은 네트워크 사이를 지나는 트래픽을 규칙에 따라 허용하거나 차단하는 보안 장치 또는 소프트웨어다. 보통 내부망과 외부망(인터넷)의 경계에 둔다.

## 2. 구성 요소

### 2.1 방화벽 유형

| 유형 | 판단 기준 | 특징 |
|---|---|---|
| 패킷 필터링 | 출발지·목적지 IP 주소, 포트, 프로토콜 | 단순하고 빠르다. 연결 상태를 기억하지 않는다 |
| 상태 기반 검사(Stateful) | 위 기준과 연결 상태 | 나가는 요청에 대한 응답 트래픽을 자동으로 허용한다 |
| 애플리케이션(프록시) | 응용 계층 내용 | 응용 프로토콜 내용을 검사한다. 처리 부하가 크다 |
| 차세대 방화벽(NGFW) | 위 기준과 사용자, 응용 식별, 침입 방지 | 여러 기능을 통합한 장비다 |

### 2.2 대표적인 방화벽 장치

| 장치 | 구분 | 설명 | 문서 |
|---|---|---|---|
| pfSense | 소프트웨어(오픈소스) | 방화벽으로 시작해 VPN, 패킷 분석 등 기능을 갖춘 방화벽 배포판 | [pfSense](../../Security/security/tools/toolbox/pfsense.md) |
| Cisco ASAv | 가상 어플라이언스(유료 라이선스) | Cisco 방화벽의 가상화 버전 | [Cisco 가상 방화벽 (ASAv)](asav.md) (NET-NSC-006-DO) |
| ZFW | 라우터 기능 | 일반 라우터를 방화벽처럼 쓰는 Cisco IOS 기능(Zone-Based Policy Firewall) | [ZFW](../../Security/security/defensive-security/defense/zfw.md) |

## 3. 동작 원리

1. 패킷이 방화벽 인터페이스에 도착한다.
2. 방화벽이 위에서부터 규칙을 순서대로 비교한다.
3. 처음으로 일치한 규칙의 동작(허용 또는 차단)을 적용한다.
4. 일치하는 규칙이 없으면 기본 정책(보통 차단)을 적용한다.

{% hint style="info" %}
NOTE: 장비마다 규칙 평가 방식은 다르다. Cisco ASA는 보안 레벨 규칙을 함께 쓴다. 자세한 내용은 NET-NSC-006-DO를 참고한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Stateful | 연결 상태를 추적해 검사하는 방식 |
| NGFW | Next-Generation Firewall. 차세대 방화벽 |
| ZFW | Zone-Based Policy Firewall |
| ACL | Access Control List. 접근 제어 목록 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [asav.md](asav.md) | NET-NSC-006-DO | Cisco 가상 방화벽 (ASAv) |
| [firewalld.md](../../Linux/guide/security/firewalld.md) | LNX-SEC-001-MP | firewalld 방화벽 관리 |
| [방화벽이란 (NordVPN)](https://nordvpn.com/ko/blog/what-is-firewall/) | | 외부 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 패킷 필터링과 상태 기반 방화벽의 차이를 내 말로 설명해 본다.
- [ ] 내가 쓰는 PC나 공유기에 방화벽이 있는지, 어떤 규칙이 적용되는지 확인한 결과를 적는다.
- [ ] 방화벽만으로 막을 수 없는 위협에는 무엇이 있을지 적는다.
