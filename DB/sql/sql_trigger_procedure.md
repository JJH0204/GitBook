# [생성형 AI] 트리거와 저장 프로시저

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-016-DO |
| 유형 | D&O (개념) |
| 목적 | DBMS 안에 저장해 두고 실행하는 트리거와 저장 프로시저의 차이와 쓰임을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 부분 검증 (트리거 동작은 SQLite 3.46.1, Python sqlite3, 2026-11-19에서 실행해 확인했다. MariaDB의 `DELIMITER`, `CREATE PROCEDURE`, `FOR EACH ROW` 문법은 문서 지식이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

응용 프로그램 대신 DBMS 서버가 실행하는 코드가 두 종류 있다. 트리거는 데이터 변경에 자동으로 반응하고, 저장 프로시저는 이름을 불러 호출한다.

## 2. 구성 요소

| 항목 | 트리거 (TRIGGER) | 저장 프로시저 (PROCEDURE) |
|---|---|---|
| 실행 시점 | 테이블에 `INSERT`/`UPDATE`/`DELETE`가 일어날 때 자동 | `CALL <이름>(<인수>)`로 호출할 때 |
| 인수 | 없음. 변경 전후 행을 `OLD`, `NEW`로 읽는다 | `IN`, `OUT`, `INOUT` 인수 |
| 주 용도 | 변경 이력 기록, 값 검증, 파생 값 갱신 | 여러 문장으로 된 업무 로직을 묶어 재사용 |
| 반환 | 없음 | `OUT` 인수 또는 결과 집합 |

### 2.1 트리거 예제와 결과

SQLite 문법이다. 계좌 잔액이 바뀔 때 이력 테이블에 한 줄을 남긴다.

```sql
CREATE TABLE acct(id INT PRIMARY KEY, bal INT);
CREATE TABLE log(id INTEGER PRIMARY KEY AUTOINCREMENT, acct INT, old INT, new INT);
INSERT INTO acct VALUES (1, 100);
CREATE TRIGGER t AFTER UPDATE OF bal ON acct
BEGIN
  INSERT INTO log(acct, old, new) VALUES (OLD.id, OLD.bal, NEW.bal);
END;
UPDATE acct SET bal = 150 WHERE id = 1;
SELECT * FROM log;   -- (1, 1, 100, 150)
```

`UPDATE` 한 번에 `log`에 한 행이 자동으로 생겼다. MariaDB는 `CREATE TRIGGER <이름> AFTER UPDATE ON <테이블> FOR EACH ROW <본문>` 형태이고(미실행), 본문이 여러 문장이면 `BEGIN ... END`로 묶는다. 문장 구분자 충돌을 피하려고 `mysql` 클라이언트에서 `DELIMITER //`로 구분자를 바꿔 입력한다.

### 2.2 MariaDB 저장 프로시저 형태 (미실행)

```sql
DELIMITER //
CREATE PROCEDURE add_bonus(IN p_id INT, IN p_amount INT)
BEGIN
  UPDATE emp SET salary = salary + p_amount WHERE id = p_id;
END //
DELIMITER ;
CALL add_bonus(1, 100);
```

## 3. 동작 원리와 주의

| 항목 | 내용 |
|---|---|
| 트리거 시점 | `BEFORE`는 변경 전(값 검증·보정), `AFTER`는 변경 후(이력 기록)에 실행한다 |
| 트랜잭션 | 트리거는 변경을 일으킨 문장과 같은 트랜잭션에서 실행된다. 롤백하면 트리거가 만든 변경도 취소된다(DB-SQL-005-REF) |
| 보이지 않는 동작 | 호출 코드에 드러나지 않아 디버깅이 어렵다. 트리거가 다른 트리거를 연쇄로 부르면 추적이 더 어렵다 |
| 권한 | 생성에는 별도 권한이 필요하다(DB-SQL-004-REF) |
| 이식성 | 문법이 DBMS마다 달라 다른 DBMS로 옮길 때 다시 써야 한다 |

{% hint style="warning" %}
CAUTION: 트리거에 업무 규칙을 많이 넣으면 동작이 코드에서 보이지 않게 된다. 단순한 값 검증은 제약 조건(DB-REL-001-DO)을 먼저 쓰고, 이력 기록처럼 꼭 필요한 곳에만 트리거를 쓴다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| `OLD`/`NEW` | 트리거 안에서 변경 전·후 행의 값을 가리키는 이름 |
| 저장 루틴 | 저장 프로시저와 저장 함수를 합친 말 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 변경 이력을 응용 프로그램이 아니라 트리거로 남길 때의 장단점을 적어 보자.
- [ ] 트리거와 저장 프로시저를 호출 방식으로 구별해 설명해 보자.
- [ ] 내가 만든 테이블에서 자동으로 기록하고 싶은 변경이 있는지 골라 보자.
