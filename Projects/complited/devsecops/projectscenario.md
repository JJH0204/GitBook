# ProjectScenario

## Excalidraw Data

### Text Elements

정재호 ^lAHyChok

네트워크 ^dm547gli

블루팀(보안) ^R6SpL2sa

레드팀(모의해킹) ^tsNDdh11

블루팀 주 업무

{% stepper %}
{% step %}
### 스크립트 작성

보안스크립트, 칼리 공격자 스크립트
{% endstep %}

{% step %}
### 악성코드 분석

(내용 그대로)
{% endstep %}

{% step %}
### IDS 구축, 관리

관리용 스크립트 작성 ^J6bRUWAT
{% endstep %}
{% endstepper %}

장진영 ^QOJIwFG7

태경 ^LMFZTTlF

지홍 ^CE1MP1eM

김범준 ^8lZOE0zY

진우 ^8sLtarSC

준성 ^p1koBrUa

정훈 ^yNBNrBDB

지윤정 ^01aPRSmt

광혁 ^Q55vNsPo

민제 ^6T1iXhon

윤서 ^EqItJUm9

혜영 ^cckpT4V2

주원 ^ghiMVSxp

레드팀(모의해킹) ^tsNDdh11

레드팀 주 업무

{% stepper %}
{% step %}
### 취약한 웹 서버 구축

취약점 시나리오 설계
{% endstep %}

{% step %}
### 모의해킹

모의해킹 결과보고서
{% endstep %}

{% step %}
### 블루팀 협업

(협업) ^FsBQ0C9W
{% endstep %}
{% endstepper %}

스크립트로 DDos 탐지하고 (동일한 소스 IP에서 분당 n회 요청이 들어오는 패킷을) ^s2AdBLlt

네트워크팀 주 업무

{% stepper %}
{% step %}
### GNS3 네트워크 토폴로지 구성
{% endstep %}

{% step %}
### 방화벽 설정 / 네트워크 보안 업무

관리용 스크립트 작성 ^cWDyBN8d
{% endstep %}
{% endstepper %}

서버실 ^CoqMVDzd

출입 관리 시스템 ^Ko9cr69u

서버팀 사무실 ^LbKN84Qj

기획/디자인팀 사무실 ^HmxQQiux

클라이언트팀 사무실 ^geHv8R16

인사팀 사무실 ^G9e3CoUz

휴식공간 ^ExPQW6mq

B1 ^dBiGubW0

1F ^Wso9GwrA

2F ^NRAomAKv

3F ^NoZFLV5o

4F ^IiLKsIYX

5F ^orSgopuS

6-7F ^yt3KgpOD

WAN ^aVxh3DVE

VPN ^7f4X1uxj

재택 ^4VwcTMVl

팀 DevSecOps 에 외주 의뢰가 도착했다.

KoreaIT 그룹을 모회사로 두고 있는 신생 게임회사 G.G.M에서 온 의뢰이다. 모회사의 사옥에서 별도의 사옥으로 이전하면서 필요한 내부 인프라 구축을 요청받았다.

우리 DevSecOps 는 어떤 서비스를 이 게임회사에 제공할 수 있을까? ^99y4Zhb3

요청 사항 1 ^vzbLht07

도심에 7층 규모의 작은 빌딩 전체를 사용할 계획이다. 각 층별로 용도에 맞게 사용할 게획이라고 한다. ^Y8GurVqd

## 1

인터넷은 통신사에서 제공하는 지하에 매설된 WAN 선을 통해서 들어온다. 58.149.46.252 IP 를 통신사에서 할당 받았다. 대표는 회사 복지로 자율근무형태(내근, 재택 선택)를 운영하려고 한다. 그래서 회사 내부 네트워크에 접속할 때 보안을 위해 VPN 설치를 희망한다. ^xc9tFenU

## 2

각 층별로 서로 통신을 허용할 필요는 없으나, 지하의 서버실에서 운영되는 웹 서비스에는 접속이 가능해야 한다.

지하의 서버실에 보안 설비를 추가하고 사내 PC에 보안 솔루션이 적용되어 점검 및 관제가 되어야 한다. ^gfhDcKm1

2차 시나리오 ^xYUxD9bx

의뢰 업체는 웹 서비스 2종을 서버실에서 구동하려고 한다. (1) 회사 인트라넷과 (2) 회사 홈 페이지 를 구동하는 것을 목표로 한다. 두 서비스가 자체 로컬 환경에서 구동되는 만큼 로컬 서버의 보안 솔루션 최적화가 필요하다. ^R71hIhyj

(2) 홈 페이지 ^OZfbqO5f

토폴로지 - 1차 ^X8iBNzKq

snort 를 서비스가 동작하는 같은 머신에 설치해야 공격/그 외 패킷 탐지가 가능함 wazuh는 다른 머신에 설치해도 탐지에 문제 없음 ^ORhia7Ds

snort 는 웹 서비스만 탐지 ^bVg65OsK

Wazuh는 Agent 등록으로 작업자 PC들을 보안 관리 ^dHKNQ7LZ

가상머신으로 구동한 Windows 에는 agent 등록이 가능한 것 확인 ^hF5a1ESn

ISP ^nQd8clSk

WWW ^JO5HLpMs

재택 ^VIMDT3wh

cisco ASAv ^0vOkwUjX

Main Router ^MihNrzCh

L3 Switch ^CXVcE3nr

L2-Server ^GdJmZtka

1\~7F-Switch ^2uiw0k1h

대구광역시 00구 000-00 에 위치한 상업용 빌딩에서 게임, 소프트웨어 개발 업종의 신생 기업 G.G.M에서 외주 의뢰가 도착했습니다.

최근 모기업 Korea IT 로 부터 독립하여 새로운 프로젝트를 진행하고자 사옥 이전을 하였습니다. 해당 업체의 요청사항은 다음과 같습니다. ^VCTyw0bC

1. 첫째도 보안 둘째도 보안

* 프로젝트에 대한 정보가 외부로 유출되는 것을 극도로 신경쓰는 상황입니다.
* 회사 내에서 외부로 반출되는 모든 데이터를 점검하고 관리하고자 합니다.
* 또한, 사내에 운영되는 모든 앤드포인트 장치에 대하여 관리를 하고자 합니다.

2. 재택근무의 양면성에 대한 우려

* 업체는 지역 회사임으로 타 지역의 인제를 수용하기 위해 100% 재택근무제도를 시행하려고 합니다.
* 정보 유출을 우려하는 업체 특성을 반영해 효과적인 VPN 시스템이 구축되어야 할 것입니다.
* 그 외에도 외부 네트워크에서 들어오는 요청에 대해서 안정하게 방어하고 관리할 수 있는 시스템 구축을 요청합니다.

3. 자체 서버실 운영

* 해당 업체에는 이미 지하에 서버실과 웹 서비스가 구동중입니다.
* 기존의 서버실에 소프트웨어 개발 서버와 보안 서버 구축을 요청하였습니다.

4. 서비스 중인 웹 서비스에 대한 보안점검

* 모 회사 Korea IT의 자회사일 때 구축한 웹 서버, 서비스로 보안 취약점 점검 의뢰를 추가하였습니다.
* 모의해킹 결과 보고서 1종과 점검/관리 스크립트 제작을 의뢰했습니다.

5. DDoS 공격 방어

* 최근 게임/IT 업계 보안 이슈로 자주 언급되는 요소입니다.
* 업체에서는 과거 게임 서버와 웹 서버에 가해진 DoS 공격을 경험한 사례가 있습니다.
* 사옥을 이전하며 DDoS 공격에 대한 최소한의 방어 대책을 적용하고자 합니다. ^B33c4pFX

VPN ^vII3ZtR2

### Embedded Files

4ccb1eaf495e5f4b6d04094464183d1377f5da22: \[\[topics/assets/images/Pasted Image 20250116121743\_271.png]]

5e20170b60c11e945446edd164fe20c5df7578c0: \[\[topics/assets/images/Pasted Image 20250117092824\_335.png]]

09a5b4b603664dcd17c2b5b35214aad523f26450: \[\[topics/assets/images/Pasted Image 20250120112121\_173.png]]

0b4a13cb795996ad6182ae49688319ca7d329d27: \[\[topics/assets/images/Pasted Image 20250120112406\_566.png]]

154eab04fb26b763eaec76442dceb982b7e41a80: \[\[topics/assets/images/Pasted Image 20250121201438\_918.png]]

2c67f8b0a9eda956b46109ac9da2e1de5fa807a5: \[\[topics/assets/images/Pasted Image 20250121201447\_897.png]]

09d3331806a6dbf14a97b1e41eb9f84e3e75b362: \[\[topics/assets/images/Pasted Image 20250121201456\_799.png]]

257cacf2817baa8c7865a629a11f05a8181d6bd8: \[\[topics/assets/images/Pasted Image 20250121201505\_132.png]]

fa95f760218e592e4853638098aaf47cb452c86a: \[\[topics/assets/images/Pasted Image 20250121202733\_394.png]]

043c8464498f0a1798d65736f9579d792f4bf06a: \[\[topics/assets/images/Pasted Image 20250121202919\_765.png]]

0fe73de1c124d2c798308653d99c760f56383ddd: \[\[topics/assets/images/Pasted Image 20250121202950\_155.png]]

ece39638fc9962b4923f661b917077314880d729: \[\[topics/assets/images/Pasted Image 20250121203417\_245.png]]

5a69529ef16720d670329bd2b5eeeaa8e6879082: \[\[topics/assets/images/Pasted Image 20250121203808\_355.png]]

bcfd49a9f7a191749605928a1cbdd418e7d676c6: \[\[topics/assets/images/Pasted Image 20250121203914\_576.png]]

ff274a3aed98ce9b0008ae6003418491ae9eea0e: \[\[topics/assets/images/Pasted Image 20250121204234\_980.png]]

5590df90cd390b4b2e30b9eb5dfec27aa85db405: \[\[topics/assets/images/Pasted Image 20250121204819\_050.png]]

2ea94674cccfaf26ccf51b2b70b08c8bf0c113ca: \[\[topics/assets/images/Pasted Image 20250121204847\_605.png]]

88bea137b0941d56b84e76c0b27c3d49fa148cc6: \[\[topics/assets/images/Pasted Image 20250121204933\_520.png]]

f0604b1c8d333d7bfb0ecf431443614716cba007: \[\[topics/assets/images/Pasted Image 20250121205034\_890.png]]

e556710335ecd996efa8a97b028d15e11419a124: \[\[topics/assets/images/Pasted Image 20250121205049\_988.png]]

bb43b6f32704664e0e3d7d9213afa7a954946f4e: \[\[topics/assets/images/Pasted Image 20250121205637\_097.png]]

7ec247e64a6c0243bbd6088812836c3d21e00b6c: \[\[topics/assets/images/Pasted Image 20250121205706\_294.png]]

7f8fa3f47caecc50744ec757d891a7f3f4f138fd: \[\[topics/assets/images/Pasted Image 20250121205750\_574.png]]

683a3f1e8d756fec8d88e08d423fcd5fc74c9770: \[\[topics/assets/images/Pasted Image 20250121205902\_962.png]]

a8a8cef1bc90e323c2a652c392fd0275ea0dc123: \[\[topics/assets/images/Pasted Image 20250121210557\_021.png]]

4178c84a168249916c9ca5b241cacba7d3e2ec39: \[\[topics/assets/images/Pasted Image 20250121213628\_531.png]]

e60121af9df1f900ed4e72c23e299e2e28364c27: \[\[topics/assets/images/Pasted Image 20250121213907\_881.png]]

1b3f129da18d34e8f8234676568ba3599b7283f3: \[\[topics/assets/images/Pasted Image 20250121214106\_489.png]]

### Drawing

```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQB2bQBWGjoghH0EDihmbgBtcDBQMBKIEm4IAH1mAAkABkkADk1iXAAzAEYeSWwAISFiRrqAaRrUkshYRArCfWikflLMbgAW

ePiATm06xpWdpKSNnkauxcgYVY2AZiTtDY6kuvi6rrqN3bOIChJ1bkakjrJf48ABsVxeIIBIMan0kCEIymk3BBHTqySOK1BIM2jRBG3in2symC3Dqn2YUFIbAA1ggAMJsfBsUgVSnWZhwXCBbLjUqaXDYanKKlCDjEBlMlkSNkcDlcrJQXmQNqEfD4ADKsBJEmwVOYzGcklwUGwkiVEApVNpAHUfma0CtyZSaQhNTBtehBB5zSLERxwrk0GTCpA2

JzsGoLmhUcGJhBhcI4ABJYiB1AFCaQOn0ABybTqbQAigAZACq1oASkkVpUAOI53CaABiHAAGhAQwBdT5tciZFPcDhCNWfQhirAVABaRh9wjF/v1g+H+HJCAQxG4qLBjR4HTWBJDDCYrE4fwOn0YLHYHBznDE3B4dRe+LqN1HzAAIukoOvuG0CGEnyaHOxAAKLBJk2RphmEzFJmZQbhIk4AIIbKQziFgAmgAVh0fiYKB2EwAAUnU+DDKWIJKqUUzi

OgXJUlQIZgAAvl2nxCHArQ/ohqAdPEVzxCsIJPP8dQiZ8RAcNSS4joeTKCr+aD/vggGHhSxpCGmECIGKY7KOaKrBAOEgIAc2KolcNwINgxAbBsIIIP+jS4Pimh1McxAPAgHR7h0Gy4F0Kzmsw7h0TBJQdGcYAdOxh66mGsn4IULGLHBkDlBIMD0PQpCYQAsphtbqrW2CTpgkiYcQ9BwL0uCFuatEVIE2BRBwxILIeyzRvc2jCc8PBXPcSTxJCgmf

FGqDOFcInaNi4IdCJoL+YJSSfN8xC/GgPBHHNVzHF0a2HnCCJImgQzaL5+0nDwR1xkSHqxqUlouhKzIVAAxB0Pk/ea/KCgmorioy73SuQsqctyio9qqGpanRFqMuUTpWggtqbfavAoy6boeoj3qfL6kgLmmUWHmGAqRpuT6fIDyapvk3aHr2uD9rxEC4Fc2G1r0dQAGqEOqpDEch6rWkYyFCL0mAfta5pjsQE4SLgdSzkDJPcOlkzwHRVwhql6lr

rxi3rPZIJrDCh6XieXDbRJVvHtet4cPeaD2XsGwHDwfCHoQn7fkpqAqWpcbAUD4EZAq0HMVr2vTNKWDQ8xGXs/gyE1DAdKSDSHaZgbmaxwhFTKJUAAKSYACpwPl1JVxXSS5rgmC9L0HT4Bu0VxwjDFsExefRYXmXoMRpfMBwKzqsWTbqhQfOi0Ykh1BQk7xL0mjUV3FQ933Ez57BydFxIlQfshk5XKX+iTk+1qaAA8hXpZXPohCkPlfMb9AOtb6Q

jG57vcVxk4txQO/EZr2ROPEIYSRLZxikjJNAQ45KwLYIpXiwcEApTSr7VO6dM7Zxkp8JqCdMBJzjN1VAVxUTaFulcFYQ0UT+TeGsCa3BppWUuotVaexfLXHiHdUoG0tqoAONsQ47xfJPHiL5TYsJ4SIkVNtfhkAHp0SegIZ0tI3pSnQF9H630/oCiFCKMUWjWTgzlFDQysNcYIy9MjdSGi0Z2gfNjWkNiKh2I7oeImGtoyfAphGWA1M1HxhFPTaC

TM4wszZlvLmPN+aC2FqLcWktpay3luOchHM6i1jVvOAMSVVwgJWHuY4dDcQXkdqeaMOxKlXk4M7V2fEVhJFoZQxoRx3xfmCDxP8AEEBARAhHSCORGYcS4saEBAkBKUJ2vce4kkxzwNQIglc8kUG0jQf0whicKiAFQJwANeOAA41n0lAK67IkIck5PZOBQHVIQIwdFHw3OyE2VmqpJpKOgInZCRBlC23QGIbITBzSXigOYAgvyEQAogM/YgxASSfD

0NkXAY4mAmXQNlXKBUiolTKhVKqNU6oNX8aQBEY4CDnJIfs455pcBCCgGwCs4QHl0UpEIAZ8k0U1DkWdPi1CkiYMKOlQ+6Bj6n3Ppfa+d8H5Pxfm/RqX9lY/17uachVlEjQjaRCEaY1HSHkms4HgfDkiHAEvuFEvCvmCMxmiE4Xs6HVmrO8a4+q4wnXkZuG4dw8QohGgCJIoJWmEnao9Vx9IQbaIgLo76+igKGMBiYyNZj2SQwVFYtU7iJCeJCo4

9GQi3XPUcVmz0SMvFxh8QU7a/jwxUxqSEumKYIk9j7AgDFHM4m8wFkLEWYsJZSxlnLUcmSt51DgHk4gviVnLiKcbRozxBJHFoXUm23AZoghXU7O8dEpFDTqK0q4XSA5bNUpy0OQyIJRzGYeIBkzjbTOEvtEEkJISLOkoU9ZqC+mns+HANgY5RloAimAYDYA1ElDqMxSJExQPgbANiO4uwhiQL4aNfa8QoPRVA84O1DxA2OpaSsF1y7k4IfeCsZD8

7dXocw8xbDuGHU3EI8RwtEwOjeocg5B4fCHhBr1pmTsADSj4FCFABk+hn4yHXKXf9PIEEzocVyKAvQFb6U1sxDAl7sjtqxXlQqxVSrlUqtVWq9VqIQDaCgrSpJthPi1S018SRzY7EaKtaK8ZcDjrQEo5UhBMDSdkwo9Myc0REYctA41FHdybCc53QE4keAlMWolxajwnyNCg/rT4WRiAqb0u1dT8F0gjPbVcAAjpISckhhgcA6MMbAt98ptGpCCR

A9Bhh0h4OZyz2BrNoBw7Z8SrmHM3Gc40VzfD3PKE89wHzFm/MBYA/kELfUzYRaEjufinsN3JwGwlpLIIUuQifE8WhmXd5OiU8hFVFA4S4F4qs7LYpruMTuw9hTcYgjAQoIHdlGCSh7xFUPCAPB8ykHoHzCgww+bZUqEmScDL8r6DaPDxV8d6I3bVaw/yWxzK7khBsDySWWH9dacka6mxngtKCrddazjvOJCYbiFE3t907XErI06QXuPol2Ncfd/k

iOHsPCo0k4bTESBjb9eNANjHA0lCmiG8oeQw0zfDDxZbc2o3zZjVjFpi3q+zZrwmwg/RVqxuTWtQT620zCU269UTW3ts5tzLtiTe0pIHek4disskq3oBOqdj3DZTL4eN3cqJN3VL4tAqPN5t3cE9psPYwbfb+x6YHdBgzw5acA+maDkBb29OjA+sEWInMHlgUsj9yCv3KW2YeP9AHo6Zlg53SDAmsMhbiyNXnQuBcbCF7R1vyde9M+fV0R8gbCc7

czDFXvhw+fggBIP6452SgF4gCJik4nJM8Rk0t+TSCi1Kby44AraAtaacjtp9m+gOC30wMhBAwwKulmwqXW0+VmDUigOH7rVmaYaIkII0i0RwO4/UQkPs8E02Xmwi7mKo/mxAB+cmwWc+aI/Eu4JSrS0Co0LO42cW2wh2B2R2aWOw6+rET2uWqmF+qAV+xWCo7arYuAoEHQNQGwpYqo2A0Iyg+gvQjQxAmA9ANQFYABvWQBtmO0hwdCdQLS86DwYI

r6GmsBs2CBC2yBgWy2c+e2g0rSh2XQrq/w86dC7eq2wIHkuw6w4kmIPAFBe86iV2N2b2NepQOWL2vczhR+ayn2+A32v2pAHKQqJQQO7M9AxY8QpAdIhAoEtYhY2EFcyEmgRg1It8ZWUAygFYBkhCSqGOv8nw5CNCl0VO+0wk42hwtSBqrCRGfUo0E26wwk2I3sdOGMqwiQQUlCh2eIOBUinOnqaAVwuw2w6G/k8Qj4QkKweuouQY4uyakusa0uh4

/0RiIEEu6AMoFi6aqucM7otixuDi2u9OqAeuL0bihupaBM3ipuxM5u0BpQASdafENMh4jaDMQGm+0Sba7MLu8S3aSSfaqSg6GSvuo6FwJu6s5uwecYYQICOwT4OOz6cem4TRDs9S8eLsdEmIBwaWu4R6GeJ6IcfIF6N+eeeQm+ReUygkj65e2Ib6yykJwmGymeDecYTeUEWhMG3eIWw+HJ6BncAxKwQxxqIxYxExKw3JJQoGawl0iWHRoInsNwPR
```
