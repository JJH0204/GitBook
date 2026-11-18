# Python 개발 환경 및 문법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-002-REF |
| 유형 | REF (링크·문법 참조) |
| 목적 | Python 개발 환경 설정 문서, 프로젝트 목록, 클래스 문법을 한 곳에서 찾는다 |
| 확인 상태 | 미검증 (링크 대상 내용을 이 환경에서 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

태그: `#python` `#개발` `#개발환경`

## 1. 개발 환경 설정 문서

| 환경 | 문서 |
|---|---|
| macOS | 아래 3절 참조 링크 |
| Windows | [Python IDE 설정 (for windows)](https://krjaeh0.gitbook.io/j-log/devtool/env-setup/pythonsettingwin) |
| 가상환경과 커널 | [가상환경 및 커널이란](https://krjaeh0.gitbook.io/j-log/linux/guide/operations/linux_admin/commands/aboutvirtualenvandkernel) |
| 패키지 관리 | [poetry](https://krjaeh0.gitbook.io/j-log/devtool/env-setup/poetry) |
| 암호화·복호화 | [암호화 및 복호화](https://krjaeh0.gitbook.io/j-log/security/security/fundamentals/theory/encryptionndeencryption) |

## 2. 프로젝트 목록

| 번호 | 프로젝트 | 문서 |
|---|---|---|
| 1 | 가상화폐 트레이딩 | 링크 없음 |
| 2 | 셀레니움을 활용한 인터파크 티켓팅 자동화 | 링크 없음 |
| 3 | 우주비행(게임) - 플래피 버드 응용 | 링크 없음 |

## 3. 참조

* [파이썬 설치부터 가상환경 설정까지](https://dailyheumsi.tistory.com/214) (macOS)
* [맥에서 pyenv 사용하기](https://leesh90.github.io/environment/2021/04/03/python-install/) (macOS)
* [터미널 사용이 익숙하지 않을 때 환경 변수 설정 방법](https://itvillage.tistory.com/47)
* [환경변수 설정 (Windows)](https://kodorricoding.tistory.com/16)

## 4. 클래스 문법

```python
class 클래스이름:
    # 초기화 메서드(생성자 역할)
    def __init__(self, 속성1, 속성2):
        self.속성1 = 속성1
        self.속성2 = 속성2

    # 메서드 정의
    def 메서드이름(self):
        # 메서드 내용
        pass
```

사용 예는 다음과 같다.

```python
class Dog:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def bark(self):
        print(f"{self.name}: 멍멍")

d = Dog("보리", 3)
d.bark()   # 보리: 멍멍
```

| 요소 | 설명 |
|---|---|
| `__init__` | 객체를 만든 직후 호출되는 초기화 메서드. 엄밀히는 객체를 만드는 `__new__` 다음에 호출된다 |
| `self` | 호출된 객체 자신. 인스턴스 메서드의 첫 매개변수로 항상 적는다 |
| `pass` | 아무 동작도 하지 않는 자리 표시 문 |

{% hint style="info" %}
NOTE: Python 3는 한글 식별자를 허용하지만 관례상 클래스는 `CamelCase`, 함수·변수는 `snake_case` 영문 이름을 쓴다. 위 첫 예제의 한글 이름은 구조를 보이기 위한 의사 템플릿이다.
{% endhint %}
