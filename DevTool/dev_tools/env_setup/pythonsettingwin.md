# PythonSettingWin

참조: [pyenv-win.git](https://github.com/pyenv-win/pyenv-win/blob/master/README.md#installation)

## A. pyenv 설치

* 윈도우용 pyenv 설치는 macOS에 비해 복잡하지만 의외로 쉽다.
* 아래 순서대로 pyenv 설치 및 환경 변수 설정까지 마치면 개발환경(IDE) 관리가 쉬워진다.

{% stepper %}
{% step %}
### 관리자 권한으로 PowerShell 실행

* "win" 키 > "PowerShell" 검색 > 우클릭 후 관리자 권한으로 실행 선택
{% endstep %}

{% step %}
### pyenv-win 설치

* 아래 명령어 복사·붙여넣기 후 실행:

{% code title="PowerShell (관리자)" %}
```shell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```
{% endcode %}
{% endstep %}

{% step %}
### PowerShell 다시 시작

* 설치 후 PowerShell을 재시작한다.
{% endstep %}

{% step %}
### 설치 확인

* 아래 명령어로 설치 여부를 확인:

```
```
{% endstep %}

{% step %}
### 환경 변수 설정

* "win" 키 > "시스템 환경 변수 편집" 검색 > 창 하단 "환경 변수" 선택 > 시스템 변수 "새로 만들기" 선택
* 아래 두 가지를 추가한다. (사용자ID는 본인 계정명으로 변경)
  * 변수 이름: `PYENV`\
    변수 값: `C:\Users\사용자ID\.pyenv\pyenv-win\bin`
  * 변수 이름: `PYENV_HOME`\
    변수 값: `C:\Users\사용자ID\.pyenv\pyenv-win\`
* 환경 변수가 이미 설정되어 있다면 건드릴 필요 없다.
{% endstep %}

{% step %}
### 설치 확인 (버전 및 경로)

* 아래 명령어 실행:

```
```

pyenv version

```
- pyenv 버전과 설치 경로가 출력되면 성공
{% endstep %}
{% endstepper %}

---

## B. Python 설치
- 앞서 설치한 pyenv를 활용해 가상환경까지 만드는 것을 목표로 한다.
- 여러 파이썬 버전과 라이브러리를 설치/제거할 때 가상 환경을 통해 관리하면 편하다.

{% stepper %}
{% step %}
## 터미널 실행

- CMD 또는 PowerShell 실행
{% endstep %}

{% step %}
## 설치 가능한 파이썬 리스트 확인

- 아래 명령어로 설치 가능한 모든 Python 버전 목록을 확인:
{% code %}
pyenv install -l
```

* pyenv 설치 이후 파이썬 설치 시 한 번은 실행해 보는 것을 권장
{% endstep %}

{% step %}
### 원하는 Python 버전 설치

* 원하는 버전으로 설치:

```
```

pyenv install "version"

```
- 예: 파이썬 3.9.9을 설치하려면:
{% code %}
pyenv install 3.9.9
```
{% endstep %}

{% step %}
### 전역 Python 버전 설정

* 설치한 여러 버전 중 전역으로 사용할 버전을 설정:

```
```

pyenv global "version"

```
- 이렇게 설정하면 가상환경 생성 시 기본 Python 버전으로 사용된다.
{% endstep %}

{% step %}
## Python 작동 확인

- 아래로 실행하여 파이썬 실행파일 경로 확인:
{% code %}
python -c "import sys; print(sys.executable)"
```

* pyenv 설치 경로와 python 설치 경로가 잘 표시되면 성공
{% endstep %}
{% endstepper %}

***

## C. 가상환경 세팅하기

* macOS에서는 pyenv 설치 시 `pyenv-virtualenv`가 함께 설치되어 가상환경 관리가 쉬우나, Windows에서는 지원이 제한적이므로 여기선 Python의 내장 모듈 `venv`로 가상환경을 관리한다. (참고: [pyenv-virtualenv 설치관련 정보](https://github.com/pyenv/pyenv-virtualenv))

{% hint style="info" %}
Windows 환경에서는 `pyenv-virtualenv` 사용이 어렵기 때문에 이 가이드에서는 Python 내장 `venv` 사용 방법을 안내합니다.
{% endhint %}

{% stepper %}
{% step %}
### 프로젝트 디렉토리로 이동 및 가상환경 생성

* 터미널에서 프로젝트 디렉토리로 이동한 후 아래 명령어 실행:

```
```

python -m venv "가상환경 디렉토리 이름"

```
- 관행적으로 `.venv`를 디렉토리 이름으로 사용하는 것이 일반적이다.
{% endstep %}

{% step %}
## .gitignore 추가 (선택)

- 가상환경 디렉토리를 Git 저장소에 포함시키지 않으려면 `.gitignore`에 추가한다.
- 버전 관리 필요시에는 포함해도 된다.
{% endstep %}

{% step %}
## 가상환경 활성화

- 터미널에서 활성화:
{% code %}
.가상환경이름\Scripts\activate.bat
```

* 활성화 여부 확인 예:

```
```

where python

## 예시 출력:

## E:...\project.venv\Scripts\python.exe # 프로젝트 디렉토리의 python 확인 가능

```
{% endstep %}

{% step %}
## 가상환경 파이썬 버전 변경 (선택)

- 가상환경에서 다른 파이썬 버전을 사용하려면 해당 파이썬 버전이 설치되어 있어야 한다.
- 사용하고자 하는 프로젝트 디렉토리에서 아래 명령어 실행:
{% code %}
pyenv local 사용할버전
```

* 그러면 해당 디렉토리에서 기본으로 사용할 파이썬 버전이 변경된다.
{% endstep %}

{% step %}
### venv에 대한 자세한 정보

* 공식 문서: https://docs.python.org/ko/3/library/venv.html
{% endstep %}
{% endstepper %}

***

## D. 가상환경 세팅 일련의 과정 정리

```sh
E:\Document\GitHub\LearnPy> cd project\AutoTicketing                            # 프로젝트 디렉토리로 이동
E:\Document\GitHub\LearnPy\project\AutoTicketing> python -m venv .venv          # .venv 라는 이름의 가상환경 생성
E:\Document\GitHub\LearnPy\project\AutoTicketing> cmd /c pyenv local 3.9.9      # 디렉토리 파이썬 버전 설정
E:\Document\GitHub\LearnPy\project\AutoTicketing> .venv\Scripts\activate.bat    # 가상환경 활성화
(.venv) E:\Document\GitHub\LearnPy\project\AutoTicketing> where python          # 가상환경 활성화 확인
E:\Document\GitHub\LearnPy\project\AutoTicketing\.venv\Scripts\python.exe
C:\Users\jhjy5\.pyenv\pyenv-win\shims\python
C:\Users\jhjy5\.pyenv\pyenv-win\shims\python.bat
C:\Users\jhjy5\AppData\Local\Microsoft\WindowsApps\python.exe

(.venv) E:\Document\GitHub\LearnPy\project\AutoTicketing>deactivate.bat         # 가상환경 비활성화
E:\Document\GitHub\LearnPy\project\AutoTicketing>
```

***

## 추가 자료

<details>

<summary>파이썬 자동완성 기능 사용 (참고)</summary>

* https://newstroyblog.tistory.com/283

</details>
