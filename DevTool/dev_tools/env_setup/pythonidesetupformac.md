# PythonIDESetupForMac

{% stepper %}
{% step %}
### 버전 확인 방법: --version

명령어:

{% code title="명령어" %}
```
```
{% endcode %}

```bash
python3 --version
python --version
```

출력 예:

```bash
(base) admin@adminui-MacBookAir ~ % python --version
Python 3.9.6

(base) admin@adminui-MacBookAir ~ % python3 --version
Python 3.11.7
```

{% hint style="info" %}
파이썬이 두 개 설치된 것처럼 보입니다.
{% endhint %}
{% endstep %}

{% step %}
### 설치 경로 확인: which

명령어:

{% code title="명령어" %}
```
```
{% endcode %}

```bash
which python
which python3
```

출력 예:

```bash
(base) admin@adminui-MacBookAir ~ % which python
python: aliased to /usr/bin/python3

(base) admin@adminui-MacBookAir ~ % which python3
/opt/anaconda3/bin/python3
```

{% hint style="info" %}
python3의 경우 아나콘다(Anaconda) 설치를 통해 함께 설치된 것처럼 보입니다.
{% endhint %}
{% endstep %}

{% step %}
### 라이브러리 설치: pip, pip3

명령어:

{% code title="명령어" %}
```bash
pip install requests
pip3 install requests
python -m pip install requests
```
{% endcode %}

{% hint style="warning" %}
사용하는 파이썬 버전에 해당하는 pip가 무엇인지 모를 경우, python -m pip 형식(-m 옵션)을 사용하면 현재 사용 중인 파이썬 인터프리터와 연결된 pip를 실행하므로 안전합니다.
{% endhint %}
{% endstep %}
{% endstepper %}
