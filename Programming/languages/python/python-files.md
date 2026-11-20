# [생성형 AI] Python 파일 입출력 (File I/O)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-009-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | open, with 문, 텍스트 모드와 인코딩, 줄 단위 읽기를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

`open(경로, 모드, encoding=...)`은 파일 객체를 돌려준다. `with` 문과 함께 쓰면 블록이 끝날 때(예외가 나도) 파일이 자동으로 닫힌다.

## 2. 모드

| 모드 | 의미 |
|---|---|
| `"r"` | 읽기(기본값). 파일이 없으면 `FileNotFoundError` |
| `"w"` | 쓰기. 파일이 있으면 내용을 지우고 새로 쓴다 |
| `"a"` | 덧붙이기. 파일 끝에 쓴다 |
| `"b"`를 붙임 | 바이너리 모드(`"rb"`, `"wb"`). 인코딩을 지정하지 않는다 |

## 3. 예제 코드

임시 폴더에 파일을 만들어 쓰고 읽는다.

{% code title="files.py" %}
```python
import os
import tempfile

path = os.path.join(tempfile.mkdtemp(), "sample.txt")

with open(path, "w", encoding="utf-8") as f:
    f.write("첫째 줄\n")
    f.writelines(["둘째 줄\n", "셋째 줄\n"])

with open(path, encoding="utf-8") as f:
    for line in f:                       # 한 줄씩 읽는다
        print(line.rstrip("\n"))

with open(path, "a", encoding="utf-8") as f:
    f.write("넷째 줄\n")

with open(path, encoding="utf-8") as f:
    lines = f.read().splitlines()
print(len(lines), lines[-1])
print(f.closed)
```
{% endcode %}

실행 결과:

```
첫째 줄
둘째 줄
셋째 줄
4 넷째 줄
True
```

| 위치 | 설명 |
|---|---|
| `encoding="utf-8"` | 텍스트 모드의 기본 인코딩은 환경마다 다르므로 명시한다 |
| `for line in f` | 파일을 한 줄씩 읽어 메모리를 적게 쓴다 |
| `read().splitlines()` | 전체를 읽고 줄 목록으로 나눈다. 큰 파일에는 쓰지 않는다 |
| `f.closed` | `with` 블록을 벗어나면 `True`다 |

## 4. 한계와 주의

* `"w"` 모드는 기존 내용을 즉시 지운다. 덮어써도 되는 파일에만 쓴다.
* `with` 없이 `open`만 쓰면 `close()`를 잊을 때 자원이 남고 쓴 내용이 디스크에 반영되지 않을 수 있다.
* 경로 조합은 문자열 연결 대신 `os.path.join`이나 `pathlib.Path`를 쓴다.
* 사용자 입력으로 경로를 받을 때는 허용된 폴더 밖을 가리키지 않는지 검사한다.

## 관련 문서

* [예외 처리 (Exceptions)](python-exceptions.md)
* [이터레이터와 제너레이터 (Generators)](python-generators.md)
* [Python 컬렉션 (list, tuple, dict, set)](python-collections.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `"w"`와 `"a"` 모드의 차이를 설명한다.
- [ ] `with` 문이 예외가 나도 파일을 닫는 원리를 적는다.
- [ ] 인코딩을 지정하지 않았을 때 생길 수 있는 문제를 찾아 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
