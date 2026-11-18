---
description: 접근 제어 목록(ACL) 개념
---

# 접근 제어 보안

접근 제어와 관련된 문서를 모은 그룹이다. 문서 번호(Task ID)는 `LNX-LAS-<번호>-<유형>` 형식이다. 이 그룹 번호 `LAS`는 `linux_admin`의 `security`, `services`, `system_mgmt` 세 폴더가 함께 쓴다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-LAS-001-DO | 개념 | [라우터 접근 제어 목록 (ACL)](acl.md) | 라우터 ACL의 종류, 적용 위치, 평가 순서를 이해한다 |

{% hint style="info" %}
NOTE: 이 그룹의 ACL 문서는 라우터의 트래픽 필터를 다룬다. 리눅스 파일 ACL(`setfacl`, `getfacl`)은 아직 문서가 없다(작성 예정). 파일 권한의 기본은 [파일 및 디렉터리 접근 권한](../../../accounts-permissions/permission.md)(LNX-ACC-008-DO)을 따른다.
{% endhint %}
