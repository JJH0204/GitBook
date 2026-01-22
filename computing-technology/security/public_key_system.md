# 공용키

공용키 (public key)는 비대칭 암호화(Asymmetric Encryption) 방식에서 사용하는 두 개의 키(공개키와 개인키) 중 하나로, 누구나 접근할 수 있도록 공개된 키를 의미한다.

***

### 비대칭 암호화의 핵심 원리

두 개의 키(키 쌍, key pair)를 이용하여 데이터를 암호화하고 복호화하는 방식

* 공용키(public key): 누구나 접근 가능하며, 데이터를 암호화하는 데 사용됨.
* 개인키(private key): 소유자만 알고 있으며, 공용키로 암호화된 데이터를 복호화하는 데 사용됨.

#### 기본적인 암호화 과정

1. 데이터를 암호화할 때 공용키(public key)를 사용한다.
2. 암호화된 데이터는 오직 개인키(private key)로만 복호화할 수 있다.
3. 개인키는 절대 노출되지 않으며, 이를 통해 보안성을 높인다.

***

### 공용키 암호화 시스템의 특징

1. 보안성이 높음
2. 키 관리가 용이함
3. 전자서명(Digital Signature) 지원

***

### 공용키 암호화의 대표적인 알고리즘

<table><thead><tr><th width="163">알고리즘</th><th>특징</th></tr></thead><tbody><tr><td>RSA</td><td>가장 널리 사용되는 비대칭 암호화 알고리즘</td></tr><tr><td>ECC</td><td>RSA보다 짧은 키 길이로 같은 수준의 보안을 제공하는 알고리즘</td></tr><tr><td>DSA</td><td>전자서명에 최적화된 알고리즘</td></tr><tr><td>Diffie-Hellman</td><td>보안 키 교환(Key Exchange) 알고리즘</td></tr></tbody></table>

***

### 활용 예시

* 웹사이트 HTTPS(SSL/TLS)
* 전자서명 및 인증서
