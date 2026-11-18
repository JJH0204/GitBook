# 실습. ufw로 옆자리 막기

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-012-MP |
| 목적 | Ubuntu VM에 ufw를 22번 먼저 열고 켠 뒤, 웹서버 포트(8000)가 막히는 것과 열리는 것, 특정 PC에게만 열리는 것을 옆자리 PC에서 확인한다 |
| 적용 대상 | Ubuntu(9일차 VM, 브릿지 어댑터), ufw, Python 3, 옆자리 Windows PC |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-6.md](lesson-6.md) | LEC-N2-11-011-DO | 6. 리눅스 방화벽 ufw |
| [lesson-3-lab-exposure.md](lesson-3-lab-exposure.md) | LEC-N2-11-006-MP | 옆자리에서 내 서버 두드리기 (이 실습의 1단계) |
| [lesson-8-lab-closing.md](lesson-8-lab-closing.md) | LEC-N2-11-016-MP | 마무리: 12일차로 넘길 상태 만들기 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu VM | 브릿지 어댑터, `ufw`, `python3` | 내 서버 |
| 2 | 옆자리 Windows PC | 같은 교실 망 | 브라우저 사용 |
| 3 | 내 Windows | 같은 교실 망 | 4단계에서 사용 |
| 4 | 터미널 2개 | VM 콘솔 또는 SSH 창 | 웹서버가 한 창을 점유한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 순서를 지킨다. `sudo ufw allow 22/tcp`를 먼저 입력하고 `sudo ufw enable`을 나중에 입력한다. 순서를 바꾸면 새 SSH 접속이 막힌다.
{% endhint %}

{% hint style="info" %}
NOTE: 복구 경로를 미리 확인한다. VirtualBox 창(콘솔)으로 로그인한 뒤 `sudo ufw disable`을 입력한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `sudo ufw reset`은 규칙을 전부 지운다. 의도하지 않았다면 입력하지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM의 IP를 확인한다: `ip a` | `192.168.x.x`가 보인다 |
| 2 | 옆자리와 서로의 IP를 칠판에 적는다 | 칠판에 적혀 있다 |
| 3 | 방화벽 상태를 확인한다: `sudo ufw status` | `Status: inactive`다 |

## 5. 절차

### A. 막히지 않는 것을 먼저 본다

1. (5-A-01) 옆자리 Windows에서 `ping 192.168.x.x`를 입력한다(내 서버 주소). → 결과: 응답이 온다.
2. (5-A-02) 옆자리에서 `ssh student@192.168.x.x`를 입력한다. → 결과: 로그인 프롬프트가 뜬다(로그인하지 않는다).

### B. 방화벽 켜기: 22번 먼저

1. (5-B-01) VM에서 `sudo ufw status`를 입력한다. → 결과: `inactive`다.
2. (5-B-02) `sudo ufw allow 22/tcp`를 입력한다. → 결과: `Rules updated`가 나온다.
3. (5-B-03) `sudo ufw enable`을 입력한다. → 결과: `Proceed with operation (y|n)?`가 나온다. `y`를 입력한다. 현재 SSH 창은 끊기지 않는다.
4. (5-B-04) `sudo ufw status verbose`를 입력한다. → 결과: `Default: deny (incoming)`이 보인다.

### C. 웹서버를 올리고 막히는 것을 본다

1. (5-C-01) VM에서 `python3 -m http.server 8000`을 입력한다. → 결과: 이 창은 서버가 점유한다.
2. (5-C-02) 옆자리 브라우저에서 `http://192.168.x.x:8000`을 연다. → 결과: 열리지 않는다. 한참 기다리다 타임아웃이 난다. ufw가 막았다.

### D. 8000번 열기

1. (5-D-01) 새 SSH 창(또는 새 터미널)에서 `sudo ufw allow 8000/tcp`를 입력한다. → 결과: `Rules updated`.
2. (5-D-02) `sudo ufw status numbered`를 입력한다. → 결과: 22번과 8000번 규칙이 번호와 함께 보인다.
3. (5-D-03) 옆자리 브라우저에서 `http://192.168.x.x:8000`을 다시 연다. → 결과: 열린다.

### E. 특정 PC에게만 열기: 확장 ACL과 같은 일

1. (5-E-01) `sudo ufw status numbered`로 8000번 규칙의 번호를 확인한다. → 결과: 번호가 보인다.
2. (5-E-02) `sudo ufw delete <번호>`를 입력한다. → 결과: 전체 개방 규칙이 삭제된다.
3. (5-E-03) `sudo ufw allow from <내 Windows IP> to any port 8000`을 입력한다. → 결과: `Rules updated`.
4. (5-E-04) `sudo ufw status numbered`를 입력한다. → 결과: 8000번 규칙의 From이 내 Windows IP로 표시된다.
5. (5-E-05) 내 Windows에서 `http://192.168.x.x:8000`을 연다. → 결과: 열린다.
6. (5-E-06) 옆자리에서 같은 주소를 연다. → 결과: 열리지 않는다. 확장 ACL로 한 일을 서버 혼자서 해냈다.

### F. (시간이 남으면) 로그로 증거 보기

1. (5-F-01) `sudo ufw logging on`을 입력한다. → 결과: `Logging enabled`.
2. (5-F-02) `sudo tail -f /var/log/ufw.log`를 입력한다. → 결과: 막힌 접속이 `[UFW BLOCK]` 줄로 찍히고 출발지와 포트가 보인다. 끝내려면 `Ctrl+C`를 누른다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo ufw status verbose` | `Status: active`, `Default: deny (incoming)` | 두 값이 보인다 |
| 2 | 내 Windows에서 `:8000` | 열린다 | 페이지 표시 |
| 3 | 옆자리에서 `:8000` | 열리지 않는다 | 타임아웃 |

## 7. 복구

1. (7-01) 웹서버 창에서 `Ctrl+C`를 눌러 서버를 끈다. → 결과: 프롬프트로 돌아온다.
2. (7-02) 상태를 확인한다: `sudo ufw status numbered` → 결과: 규칙 목록이 보인다.
3. (7-03) 수업용으로 일단 끄려면 `sudo ufw disable`을 입력한다. 이 경우 12일차 전에 [LEC-N2-11-016-MP](lesson-8-lab-closing.md)로 다시 켠다.

{% hint style="info" %}
NOTE: 12일차를 위해 방화벽을 켜 둔 채로 가는 쪽을 권한다. 서버를 세울 때마다 `ufw allow`가 필요해지고, 그것이 12일차 6단계의 5번째 개방 단계다. 끄고 가면 그 단계가 실감 나지 않는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-6.md`의 실습 절과 `commands.md`의 STEP 6을 AMM 형식 MP로 분리 |
