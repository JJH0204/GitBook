# 마무리. 12일차로 넘길 상태 만들기

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-016-MP |
| 목적 | 11일차를 마치기 전에 SSH(22번)가 열려 있고 방화벽이 켜진 상태인지 확인하고, 서버 IP를 기록한 뒤 VM을 종료한다 |
| 적용 대상 | Ubuntu(9일차 VM), ufw |
| 소요 시간 | 약 5분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-8.md](lesson-8.md) | LEC-N2-11-015-TS | 8. 오늘 정리 · 안 될 때 점검 |
| [lesson-6-lab-ufw.md](lesson-6-lab-ufw.md) | LEC-N2-11-012-MP | 실습. ufw로 옆자리 막기 |
| [12일차 공통 문법](../day-12/lesson-1.md) | - | 12일차 6단계 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu VM | ufw 설치됨 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 2번 단계(22번 열기)를 빠뜨리면 다음 수업에 아무도 서버에 들어올 수 없다. 전원을 끄기 전에 `sudo ufw status numbered`에 22번 규칙이 있는지 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM 터미널에 로그인한다 | 프롬프트가 보인다 |

## 5. 절차

### A. 상태 정리와 종료

1. (5-A-01) `sudo ufw status numbered`를 입력한다. → 결과: 지금 규칙이 보인다.
2. (5-A-02) `sudo ufw allow 22/tcp`를 입력한다. → 결과: `Rule added` 또는 `Skipping adding existing rule`이 나온다.
3. (5-A-03) `sudo ufw status verbose`를 입력한다. → 결과: `Status: active`다.
4. (5-A-04) `ip a`를 입력하고 서버 IP를 적어 둔다. → 결과: `192.168.x.x`가 기록된다.
5. (5-A-05) `sudo poweroff`를 입력한다. → 결과: VM이 종료된다.

{% hint style="info" %}
NOTE: 방화벽은 켜 둔 채로 간다. 12일차에 서버를 여섯 개 세우는데, 그 6단계 중 5번째 개방(`ufw allow`)이 이 방화벽 때문에 필요해진다. 꺼 두면 그 단계가 실감 나지 않는다. → [12일차 공통 문법](../day-12/lesson-1.md)
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo ufw status numbered` | 22번 `ALLOW IN` 규칙이 있다 | 규칙 존재 |
| 2 | `sudo ufw status verbose` | `Status: active` | 활성 |
| 3 | 서버 IP 기록 | 종이 또는 메모에 적혀 있다 | 기록 있음 |

## 7. 복구

1. (7-01) 22번 규칙이 없다면 콘솔에서 `sudo ufw allow 22/tcp`를 입력한다.
2. (7-02) 방화벽 때문에 접속이 막혔다면 VirtualBox 창으로 로그인해 `sudo ufw disable`을 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-8.md`와 `commands.md`의 마무리 절을 AMM 형식 MP로 분리 |
