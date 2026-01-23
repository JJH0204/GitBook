# about\_Linux

## Text Elements

* Linux
* 1991.09.17 리눅스 토르발스에 의해 개발
* Kernel(커널) 기반 Open-source
* 96.4% 서버 운영체제 점유율
* 누구나 자유롭게 제작/배포 가능
* GNU GPL 등 개발 라이선스/철학에 따라 상업(또는 비상업)적 이용 및 수정, 배포가 가능

배포판

* 데비안, 페도라, 우분투

상용 배포판

* 레드햇 엔터프라이즈 리눅스 (RHEL)

데스크톱 배포판

* X11, 웨이랜드, 그놈, KDE 플라스마

Unix 계열 OS

* 리눅스 커널, 지원 시스템 소프트웨어, 라이브러리 포함
* 리눅스 커널과 GNU 소프트웨어 결합 → GNU/Linux
* 과거에는 어셈블리, 현재는 C 언어로 개발
* 이식성/확장성 우수

Linux는 가성비가 좋다

* 비용 지불 없이 다양한 버전의 Linux 설치 가능
* 부족함이 없는 서버 운영을 위한 소프트웨어 및 라이브러리

Q. 그럼 왜 서버 비용을 지불해야 할까?

<details>

<summary>답변 보기</summary>

A. 높은 숙련도를 가진 서버 관리자 고용 및 유지 보수(업데이트, 컨설팅 등) 비용들이 서버 비용에 포함된다.

</details>

* 다양한 관리 환경 제공 및 시스템 패치 가능
* 풍부한 소프트웨어 개발 환경 제공
* 다양한 네트워크 서비스 툴 및 작업 환경 제공
* 지원하는 하드웨어가 많다
* 모든 프로그래밍 툴 무료 제공
* GNU 소프트웨어 무료 제공

Linux는 개발하기 좋다

* Linux는 안전하다 (뛰어난 안정성/보안성)
* Open-source의 영향

백업 / 복구 / 패치

* RAID 기능 지원
* 로컬/인터넷 백업 지원
* ext3, ext4 등 파일 시스템으로 fsck 등 명령을 통해 시스템 복구 가능
* 빠른 패치가 가능

Linux의 단점

* 텍스트 모드 중심이다.
* 낯설고 복잡함만 극복하면 GUI 방식(대표적으로 windows) 보다 더 편한 경우도 있다.
  * ex1) 다중 작업을 명령어 한번에 해결
  * ex2) 스크립트 파일 작성으로 시스템 자동화

기타

* Linux 기본 디렉토리 설명 모음 (링크는 하단 참조)

***

## 리눅스의 역사 (요약)

* 1969: 켄 톰슨 / 데니스 리치 / 더글러스 매클로이 / 조 오사나 — 유닉스 운영 체제 구현
* 1971: 어셈블리어로 구현된 유닉스 첫 출시
* 1973: 데니스 리치가 일부 하드웨어 및 입출력 루틴을 제외하고 C언어로 재작성 — 이식성 향상
* 1983: 리처드 스톨먼, GNU 프로젝트 시작 (목표: 완전한 유닉스 호환 소프트웨어 시스템 개발)
* 1984: AT\&T 벨 연구소와 분리 — 유닉스의 사유화
* 1985: 자유 소프트웨어 재단(FSF) 설립
* 1987: 미닉스 (Andrew Tanenbaum) — 교육용 유닉스 계열 OS 개발
* 1989: GNU GPL 작성
* 1991: 리눅스 커널 개발 시작 (토르발스, Freax → Linux)
* 1992: 386BSD 개발 — NetBSD/OpenBSD/FreeBSD의 기원
* 1994: 리눅스 커널 1.0 발표
* 1996: 리눅스 커널 2.0 발표
* 2000.04: 미닉스가 자유 소프트웨어로 자리잡지 못함 (라이선스 이슈)

연표(간략)

* 1960s-1990s: Multics, UNIX의 발전, C언어 등장, GNU 및 FSF, Minix, 리눅스의 등장 및 커널 발전

***

## 리눅스 철학 및 라이선스

{% stepper %}
{% step %}
### GNU (GNU is Not UNIX)

* 리처드 스톨먼이 자유 소프트웨어 재단(FSF)에서 진행하며 유지 중인 운영체제 프로젝트
* 1983년 GNU 개발 시작
* 목표: GNU 프로젝트를 통해 개발한 유닉스 계열 컴퓨터 운영체제로 '완전한 유닉스 호환 소프트웨어 시스템'이 되는 것
{% endstep %}

{% step %}
### 자유 소프트웨어 재단 (FSF, Free Software Foundation)

* 1985년 리처드 스톨먼이 설립한 재단
* 소프트웨어 자유 4가지(일반적으로 정의되는 자유)
  * 어떤 목적이든 원하는 대로 프로그램을 실행시킬 수 있는 자유
  * 프로그램 복제물을 무료 또는 유료로 재배포할 수 있는 자유
  * 필요에 따라 프로그램을 개작할 수 있는 자유
  * 공동체 전체가 개선된 이익을 나눌 수 있게 제작한 프로그램을 배포할 수 있는 자유
* 자유는 금전적 측면과 관계가 없으므로 자유 소프트웨어를 유료로 판매해도 문제없음
{% endstep %}

{% step %}
### 오픈 소스 소프트웨어 (Open-source Software)

* '자유 소프트웨어' 용어가 혼동을 일으켜 대체 용어로 사용되기 시작
{% endstep %}

{% step %}
### GNU GPL (General Public License)

* FSF가 만든 무료 소프트웨어 라이선스
* 1차: 1989, 2차: 1991, 3차: 2007 발표
* GPL 코드를 일부 사용하면 해당 프로그램 전체가 GPL 적용 대상이 됨
* 유료 판매 가능하나 소스 코드 공개가 필수
{% endstep %}

{% step %}
### GNU LGPL (Lesser General Public License)

* GPL보다 완화된 조건의 공개 소프트웨어 라이선스
* LGPL 적용 라이브러리 이용 시 소스 코드 공개 의무 없음(단, 수정·배포 시 파생물 공개 의무 발생)
{% endstep %}

{% step %}
### BSD (Berkeley Software Distribution)

* 자유 소프트웨어 저작권 유형
* 소스코드 공개 의무 없음, 상업적 사용 가능
* GPL과는 달리 파생 소프트웨어에 동일 라이선스 강제 없음
* 예: OpenCV는 BSD 라이선스
{% endstep %}

{% step %}
### 아파치 (Apache)

* 아파치 소프트웨어 재단의 라이선스
* 아파치 2.0: 파생 프로그램 제작 및 저작권 양도/전송 허용
{% endstep %}

{% step %}
### MIT 라이선스

* 적용 소프트웨어 예: X Window System, jQuery, Node.js 등
{% endstep %}

{% step %}
### MPL

* 소스코드와 실행파일의 저작권을 분리한 점이 특징
{% endstep %}
{% endstepper %}

***

## 기타 링크 및 참조 (Element Links)

* Linux 기본 디렉토리 설명: Linux기본\_디렉토리\_설명 (파일: Linux%EA%B8%B0%EB%B3%B8\_%EB%94%94%EB%A0%89%ED%86%A0%EB%A6%AC\_%EC%84%A4%EB%AA%85.md)
* RAID: ../network/RAID.md
* 커널(컴퓨팅) (Wikipedia): https://ko.wikipedia.org/wiki/%EC%BB%A4%EB%84%90\_(%EC%BB%B4%ED%93%A8%ED%8C%85)
* 기타 검색/참고 링크:
  * https://www.google.com/search?q=%EC%98%A4%ED%94%88+%EC%86%8C%EC%8A%A4\&sca\_esv=2a19a3414e05e997\&sca\_upv=1\&sxsrf=ADLYWIIdJcVfetVgtRGl-vtASfTVsVW7og:1721663087101\&ei=b36eZvL1Banl2roPgZeC-A4\&ved=0ahUKEwiy6erl\_rqHAxWpslYBHYGLAO8Q4dUDCA8\&uact=5\&oq=%EC%98%A4%ED%94%88+%EC%86%8C%EC%8A%A4\&gs\_lp=Egxnd3Mtd2l6LXNlcnAiDeyYpO2UiCDshozsiqQyCxAAGIAEGLEDGIMBMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAESNoWUABYvhRwBngBkAECmAGVAaAB3gyqAQQwLjE0uAEDyAEA-AEBmAIMoALSBcICERAuGIAEGLEDGNEDGIMBGMcBwgIIEAAYgAQYsQPCAgQQLhgDwgIKEAAYgAQYQxiKBcICBBAAGAPCAgsQLhiABBjRAxjHAcICBxAAGIAEGArCAgUQIRigAcICBhAAGB4YD8ICCBAAGIAEGKIEwgIGEAAYCBgemAMAkgcDNi42oAfFXQ\&sclient=gws-wiz-serp
  * https://namu.wiki/w/%EB%A6%AC%EB%88%84%EC%8A%A4%20%ED%86%A0%EB%A5%B4%EB%B0%9C%EC%8A%A4
  * https://namu.wiki/w/GNU
  * obsidian://open?vault=MyNote\&file=Spaces%2FHome%2FC%20%EC%96%B8%EC%96%B4

***

## Drawing (원본 압축 데이터)

```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQA2bQAOGjoghH0EDihmbgBtcDBQMBLoeHF0QOwojmVg1JLIRhZ2LjQARnaeAE5+UubWTgA5TjFuTvikgGYAdgBWOfapvshC

DmIsbghcAAYG0sJmABF0qARibgAzAjCViBIto6gANUuAYQBBIQQABSEAFU0ABkPgBVADipH+RlwAHV9pBLoR8PgAMqweoSQQeBEQZhQUhsADWCFhJHU3D4hQEBOJCHRMEx6GxDzuhL8kg44VyHTubDguGwahg4x2Ozu1jqFXF1IgmG4zh4ABYpto5kqdkkle14jx1TMplMkncRWhnFMdjMEsq5obujxOrMkjM7vjCSS3mx8GxSFsAMTtBCBwO4zS

... (생략되지 않은 전체 압축 JSON 데이터는 원본 그대로 유지)
```

(위의 compressed-json 블록은 Excalidraw에 사용된 원본 압축 데이터를 포함합니다. 필요시 원본을 그대로 복원하여 사용하세요.)
