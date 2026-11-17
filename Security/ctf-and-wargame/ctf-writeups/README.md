# CTF 풀이 모음 (CTF Writeups)

CTF 풀이와 메모를 모은 그룹이다. 문서 번호(Task ID)는 `SEC-WUP-<번호>-<유형>` 형식이다. 풀이 문서는 모두 TS(문제 해결형)이며, 개요와 설계 문서는 D&O(개념)이다.

{% hint style="danger" %}
WARNING: 이 그룹의 풀이는 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 VM)에서만 재현한다. 허가받지 않은 시스템에 같은 절차를 수행하는 것은 불법이다. 문서에는 플래그 값과 문제 계정 정보를 적지 않았다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 내용 |
|---|---|---|---|
| SEC-WUP-001-DO | 개념 | [CTF 개요 (CTF)](ctf.md) | CTF의 정의, 특징, 풀이 문서 목록 |
| SEC-WUP-002-DO | 개념 | [CTF 커스텀 시나리오 설계](ctf-custom.md) | 자체 제작 CTF 시나리오의 구성 |
| - | 원본 유지 | [CTF: Earth (1)](ctf_1.md) | Earth 풀이 전체 흐름 |
| - | 원본 유지 | [CTF: Earth (2)](ctf_earth.md) | Earth 초기 정보 수집(단편) |
| - | 원본 유지 | [CTF: Account 1](ctf_account_1.md) | 권한 파라미터 변조와 확장자 우회 |
| - | 원본 유지 | [CTF: Account 2](ctf_account_2.md) | 정보 수정 권한 검증 부재와 확장자 우회 |
| - | 원본 유지 | [CTF: Cookie01](ctf_cookie01.md) | 쿠키 값이 파일 이름이 되는 업로드(미완성) |
| - | 원본 유지 | [CTF: Funbox 10](ctf_funbox_10.md) | 기록 없음 |
| - | 원본 유지 | [CTF: HF2019](ctf_hf2019.md) | WordPress 플러그인 SQL 인젝션 |
| - | 원본 유지 | [CTF: Kioptrix Level 1.2](ctf_kioptrix_level_1.2.md) | 정보 수집 단계까지(단편) |
| - | 원본 유지 | [CTF: Pwned](ctf_pwned.md) | 웹 주석의 계정, FTP, docker 권한 상승 |
| - | 원본 유지 | [CTF: Mercury](ctf_mercury.md) | URL 경로 SQL 인젝션, sudo 스크립트 권한 상승 |
| - | 원본 유지 | [CTF: TechSupport](ctf_techsupport.md) | 인증 없는 Samba 공유(단편) |
| - | 원본 유지 | [CTF: Venus](ctf_venus.md) | 인코딩된 쿠키, SUID 탐색(단편) |
| - | 원본 유지 | [CTF: Quaoar](ctf_quaoar.md) | WordPress 로그인 무차별 대입, 플러그인 취약점(단편) |
| - | 원본 유지 | [CTF: WordPress](ctf_wordpress.md) | 로그인 무차별 대입, 플러그인 편집 웹 셸 |
| - | 원본 유지 | [CTF: Cybersploit 2](ctf_cybersploit2.md) | ROT47 계정 정보, docker 그룹 권한 상승 |
| - | 원본 유지 | [CTF: Cybersploit 1](ctf_cybersploit.md) | 인코딩 단서, 커널 권한 상승 |

{% hint style="info" %}
NOTE: `원본 유지` 항목은 AMM 형식으로 다시 쓰지 않았다. 풀이 절차가 공격 실행 단계(스캔, 무차별 대입, 원격 셸, 권한 상승)로 이루어져 있어 사용자 판단 후에 처리한다.
{% endhint %}

항목이 많으므로 이름으로 찾는다.
