# kubernetes\_in\_windows

{% stepper %}
{% step %}
### Windows에서 Kind 설치 및 설정

#### 필수 요구사항

* Docker Desktop 설치:
  * Windows에 Docker Desktop을 설치하고, WSL2를 활성화해야 Kind를 실행할 수 있어.
  * Docker Desktop 다운로드: https://www.docker.com/products/docker-desktop/
  * Docker Desktop 설치 후 **Kubernetes** 옵션을 비활성화.
{% endstep %}

{% step %}
### Kind 설치

PowerShell에서 Kind를 설치:

{% code title="PowerShell" %}
```
```
{% endcode %}

Kind가 설치되었는지 확인:

{% code title="PowerShell" %}
```
```
{% endcode %}
{% endstep %}

{% step %}
### 클러스터 설정 파일 작성

Kind 클러스터를 구성하기 위해 YAML 설정 파일을 작성. 이 파일에서 Control Plane(또는 Master Node)과 Worker Node 2개를 정의할 수 있어.

`cluster-config.yaml` 파일 작성:

{% code title="cluster-config.yaml" %}
```
```
{% endcode %}
{% endstep %}

{% step %}
### Kind 클러스터 생성

작성한 클러스터 설정 파일을 사용해 Kind 클러스터를 생성:

{% code title="PowerShell" %}
```
```
{% endcode %}

Kind가 클러스터를 생성하면 Docker 컨테이너로 각 노드가 생성돼. 확인하려면:

{% code title="PowerShell" %}
```
```
{% endcode %}

출력 예시:

```
CONTAINER ID   IMAGE                     COMMAND                  STATUS       NAMES
abc123         kindest/node:v1.27.4     "/usr/local/bin/entr…"   Up 2 minutes kind-worker
def456         kindest/node:v1.27.4     "/usr/local/bin/entr…"   Up 2 minutes kind-worker2
ghi789         kindest/node:v1.27.4     "/usr/local/bin/entr…"   Up 2 minutes kind-control-plane
```

여기서 `kind-worker`와 `kind-worker2`는 Worker Node이며, `kind-control-plane`은 Control Plane이야.
{% endstep %}

{% step %}
### 클러스터 상태 확인

클러스터 상태를 확인하여 노드가 제대로 구성되었는지 확인:

{% code title="PowerShell" %}
```
```
{% endcode %}

출력 예시:

```
NAME                     STATUS   ROLES           AGE   VERSION
kind-control-plane       Ready    control-plane   1m    v1.27.4
kind-worker              Ready    <none>          1m    v1.27.4
kind-worker2             Ready    <none>          1m    v1.27.4
```
{% endstep %}

{% step %}
### Worker Node 테스트

Worker Node에서 파드를 실행하여 클러스터가 제대로 작동하는지 확인.

#### 테스트용 Deployment 생성

{% code title="PowerShell" %}
```
```
{% endcode %}

* 삭제

{% code title="PowerShell" %}
```
```
{% endcode %}

#### 파드 확인

{% code title="PowerShell" %}
```
```
{% endcode %}

출력 예시:

```
NAME                     READY   STATUS    NODE           ...
nginx-xxxxxxx-yyyy       1/1     Running   kind-worker    ...
```

여기서 `NODE` 열에 `kind-worker` 또는 `kind-worker2`가 표시되면 파드가 Worker Node에서 정상적으로 실행되고 있다는 의미야.
{% endstep %}

{% step %}
### 클러스터 관리

Kind 클러스터를 삭제하려면:

{% code title="PowerShell" %}
```
```
{% endcode %}
{% endstep %}

{% step %}
### 추가 구성

* Ingress Controller: 외부에서 클러스터에 접근하려면 Ingress를 설치.

{% code title="kubectl" %}
```
```
{% endcode %}

* 스토리지 추가: Persistent Volume과 Persistent Volume Claim을 설정하여 데이터 지속성을 보장.
{% endstep %}
{% endstepper %}
