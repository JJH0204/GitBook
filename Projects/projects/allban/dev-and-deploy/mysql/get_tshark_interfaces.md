---
description: Windows 환경에서 127.0.0.1(Loopback) 패킷을 안정적으로 가로채는 환경 구축.
---

# 루프백 어댑터 자동 탐색 구현 (Npcap)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-008-REF |
| 유형 | REF (코드 표) |
| 목적 | Windows에서 Npcap 루프백 어댑터를 런타임에 찾는 함수 두 가지를 찾아 쓴다 |
| 적용 환경 | Windows, Npcap |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구현 비교

| 구현 | 라이브러리 | 탐색 방법 | 조건 |
|---|---|---|---|
| A | scapy | 인터페이스 설명에 "Npcap Loopback Adapter"가 있거나 이름에 "Loopback"이 있는 항목의 `name` | Wireshark 설치가 필요 없다 |
| B | pyshark(tshark) | `\Device\NPF_Loopback` 문자열을 우선 찾고, 없으면 "loopback"이 들어간 행의 둘째 항목 | Wireshark(tshark)를 Windows 서버에 설치해야 한다 |

## 2. 구현 A: scapy

```python
// scapy 라이브러리 사용 버전
def find_loopback_adapter():
    """'Npcap Loopback Adapter'를 자동으로 찾습니다."""
    for iface in get_windows_if_list():
        desc = iface.get('description', '')
        name = iface.get('name', '')
        if "Npcap Loopback Adapter" in desc or "Loopback" in name:
            return iface['name']
    return None
```

{% hint style="info" %}
NOTE: tshark는 Wireshark를 Windows 서버에 설치해야 쓸 수 있어서 scapy로 전환했다.
{% endhint %}

## 3. 구현 B: tshark

```python
// tshark 라이브러리 사용 버전
def find_loopback_adapter():
    """NPF_Loopback 어댑터를 자동으로 찾습니다."""
    try:
        interfaces = pyshark.tshark.tshark.get_tshark_interfaces()
        for line in interfaces:
            if r"\Device\NPF_Loopback" in line:
                return r"\Device\NPF_Loopback"
        for line in interfaces:
            if "loopback" in line.lower():
                parts = line.split()
                if len(parts) >= 2:
                    return parts[1]
    except Exception as e:
        log("ERROR", f"Adapter search failed: {e}\n{traceback.format_exc()}")
    return r'\Device\NPF_Loopback'
```

{% hint style="warning" %}
CAUTION: 두 코드 블록의 첫 줄 `//` 주석은 Python 문법이 아니다. 그대로 실행하면 문법 오류가 난다. 쓸 때는 `#`로 바꾼다.
{% endhint %}

## 4. 확인 필요

- 원본은 scapy로 전환했다고 적었지만, [네트워크 패킷 분석 및 MySQL 디코딩](README.md)(PRJ-ALB-007-DO)과 [임베디드 파이썬 환경 구축 (Python)](../embeddable-python.md)(PRJ-ALB-010-DO)은 pyshark/tshark를 계속 쓰는 것으로 읽힌다. 최종 채택은 확인이 필요하다.
- 구현 B가 반환하는 `parts[1]`의 형식(번호인지 장치 경로인지)은 원본에 없다.
