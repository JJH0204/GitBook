# uml dependency

보여주신 건 페이지 제목뿐이라서 원본 웹페이지의 전체 내용을 가져와 GitBook용 Markdown으로 변환하려면 원문(또는 URL)이 필요합니다.

도움을 드리기 위해 가능한 작업 방식과 결과 예시(샘플 구조)를 간단히 안내드립니다. 실제 변환을 원하시면 원문 텍스트나 페이지 URL을 보내주세요.

변환 시 처리 방식 (예시)

* 페이지 구조와 의미는 유지합니다.
* 내비게이션, 사이트 로고, "On this page" 같은 불필요한 항목은 제거합니다.
* 설치/설치 명령 등에 npm/yarn/pnpm 목록이 있을 경우, 각 패키지 매니저별 탭으로 변환합니다.
* 순차적 단계(1., 2., 3. ...가 많은 내용일 때)는 stepper(스텝)로 변환합니다.
* FAQ는 확장(accordion) 블록으로 변환합니다.
* 관련 코드 블록은 GitBook의 코드 블록/타이틀 형식으로 변환합니다.
* 힌트(주의/참고)는 hint 블록으로 변환합니다.
* 이미지(특히 base64)는 그대로 둡니다.

간단한 샘플(출력 예시)

* 제목: UML 의존관계(UML Dependency)
* 본문: (원문 내용이 들어감)
* 만약 설치 명령 3개가 있으면:

{% tabs %}
{% tab title="npm" %}
```bash
npm install ...
```
{% endtab %}

{% tab title="yarn" %}
```bash
yarn add ...
```
{% endtab %}

{% tab title="pnpm" %}
```bash
pnpm add ...
```
{% endtab %}
{% endtabs %}

* 만약 단계가 있으면 stepper 사용:

{% stepper %}
{% step %}
### 첫 번째 단계

내용...
{% endstep %}
{% endstepper %}

보내주실 내용

* 웹페이지 URL (가능하면) 또는 원문 텍스트
* 변환 시 특별히 원하는 포맷(예: 코드 블록에 파일명 표기, 이미지 분리 등)

원문을 보내주시면 바로 GitBook 최적화된 Markdown으로 변환해 드리겠습니다.
