# mount

{% hint style="info" %}
파일 시스템이나 저장 장치를 특정 디렉터리에 연결하여 그 내용을 접근 가능하게 하는데 사용된다.
{% endhint %}

## mount (마운트)

윈도우의 PnP(Plug and Play) 방식과 달리 리눅스는 장치를 연결한 후 직접 마운트 과정을 거쳐야 사용할 수 있습니다.

* 마운트: 물리적인 장치를 특정한 디렉토리에 연결시켜주는 과정

{% hint style="info" %}
장치 연결 예:

```
mount /dev/cdrom /mnt/dvd
mount [장치 이름] [연결할 디렉토리 이름]
```

장치 해제 예:

```
umount /dev/cdrom
umount [장치 이름]
```

정상적인 장치 연결과 해제를 위해서는 연결할 디렉토리 밖에서 작업을 수행하는 것이 좋습니다. 마운트하는 것으로 기존에 저장된 파일이 삭제되거나 하지 않습니다.
{% endhint %}

## fdisk -l

***

* 연결된 저장 장치를 찾는 방법

### 기본 사용 방법

* 파일 시스템 목록 확인:

{% code title="명령어" %}
```bash
mount
```
{% endcode %}

* 특정 파일 시스템 목록 확인:

{% code title="명령어" %}
```bash
mount -t ext4
```
{% endcode %}

* 파일 시스템 마운트:

{% code title="예시" %}
```bash
sudo mount /dev/sdb1 /mnt/media
```
{% endcode %}

* /etc/fstab 파일을 이용한 마운트:

`/etc/fstab` 파일은 시스템 장치의 마운트 위치와 옵션을 설명하는 라인을 포함합니다. 내부 장치나 네트워크 공유를 정의할 수 있습니다.

형식:

```
<file system> <mount point> <type> <options> <dump> <pass>
```

예시 라인:

```
/dev/sdb1 /mnt/media ext4 defaults 0 0
```

이를 통해 시스템 부팅 시 자동으로 마운트할 수 있습니다.

#### 실용적인 예시

* USB 드라이브 마운트:

{% code title="USB 마운트 예시" %}
```bash
sudo mount /dev/sdX1 /mnt/usb
```
{% endcode %}

* 네트워크 공유(NFS) 마운트:

{% code title="NFS 마운트 예시" %}
```bash
sudo mount -t nfs server:/path/to/share /mnt/nfs
```
{% endcode %}

* 가상 파일 시스템(tmpfs) 마운트:

{% code title="tmpfs 마운트 예시" %}
```bash
sudo mount -t tmpfs tmpfs /mnt/ramdisk
```
{% endcode %}

#### 마운트 해제

파일 시스템을 더 이상 사용할 필요가 없으면 안전하게 해제해야 합니다:

{% code title="umount 예시" %}
```bash
sudo umount /mnt/usb
```
{% endcode %}

#### 주요 옵션

* -t: 파일 시스템 유형 지정 (예: ext4, nfs, iso9660)

```
mount -t ext4 /dev/sda1 /mnt
```

*   -o: 여러 마운트 옵션 지정 (쉼표로 구분)

    * ro: 읽기 전용으로 마운트

    ```
    mount -o ro /dev/sda1 /mnt
    ```

    * rw: 읽기/쓰기로 마운트

    ```
    mount -o rw /dev/sda1 /mnt
    ```

    * noatime: 파일 접근 시간 업데이트 안함 (성능 향상)

    ```
    mount -o noatime /dev/sda1 /mnt
    ```

    * async: 비동기식 동작

    ```
    mount -o async /dev/sda1 /mnt
    ```

    * sync: 동기식 동작

    ```
    mount -o sync /dev/sda1 /mnt
    ```

    * remount: 이미 마운트된 파일 시스템의 옵션 변경

    ```
    mount -o remount,rw /mnt
    ```

    * loop: ISO 파일 같은 디스크 이미지 파일 마운트

    ```
    mount -o loop image.iso /mnt
    ```
* -a: `/etc/fstab`에 정의된 모든 파일 시스템을 마운트

```
mount -a
```

* -r: 읽기 전용 마운트 (`-o ro`와 동일)

```
mount -r /dev/sda1 /mnt
```

* -n: `/etc/mtab` 파일을 업데이트하지 않고 마운트

```
mount -n /dev/sda1 /mnt
```

* -v: 마운트 작업 중 상세 정보 출력

```
mount -v /dev/sda1 /mnt
```

* -L: 볼륨 라벨을 사용하여 마운트할 장치 지정

```
mount -L mylabel /mnt
```

#### 예시 명령어 모음

* USB 드라이브 마운트:

```
sudo mount -o rw,async /dev/sdb1 /mnt/usb
```

* NFS 공유 마운트:

```
sudo mount -t nfs -o rw,vers=4 server:/shared /mnt/nfs
```

* ISO 파일 마운트:

```
sudo mount -o loop image.iso /mnt/iso
```

이렇게 `mount` 명령어는 리눅스에서 파일 시스템을 효율적으로 관리하고, 다양한 저장 장치와 네트워크 리소스를 통합하는 데 필수적인 도구입니다.
