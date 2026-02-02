---
description: Windows 환경에서 127.0.0.1(Loopback) 패킷을 안정적으로 가로채는 환경 구축.
---

# get\_tshark\_interfaces()

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
와이어샤크 라이브러리(tshark)는 와이어샤크를 윈도우 서버에 설치해야 사용가능함으로 scapy 라이브러리로 전환함
{% endhint %}

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
