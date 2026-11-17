# 스니퍼 실시간 출력 지연 해결

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-009-TS |
| 유형 | TS (문제 해결) |
| 목적 | 파이썬 스니퍼의 로그가 Dart 대시보드에 실시간으로 나오지 않는 증상을 해결한다 |
| 적용 환경 | Windows, Dart(Flutter) 서버가 파이썬 스니퍼를 자식 프로세스로 실행하는 구조 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 증상

- 파이썬 `print()` 로그가 Dart 대시보드에 바로 나오지 않는다.
- 로그가 멈춰 있다가 프로세스가 종료될 때 한꺼번에 나온다.

## 2. 가능 원인

| 번호 | 원인 | 근거 |
|---|---|---|
| 1 | 파이썬 표준 출력 버퍼링 | 파이프로 연결된 파이썬 출력은 버퍼가 찰 때까지 내보내지 않는다 |
| 2 | Dart 스트림 리스너와의 동기화 문제 | 파편화된 데이터가 줄 단위로 복원되지 않는다 |
| 3 | `runInShell: true`로 인한 쉘(CMD) 간섭 | 임베디드 파이썬의 실행 경로가 꼬인다 ([프로세스 통합 및 생명주기 관리 (Dart-Python)](../dart-python.md), PRJ-ALB-011-DO 참조) |

## 3. 격리 절차

1. 파이썬을 `-u` 없이 실행해 출력이 종료 시점에 몰리는지 확인한다. → 결과: 몰리면 원인 1이다.
2. 파이썬에 `-u`를 추가한다. 그래도 로그가 깨지거나 합쳐지면 Dart 쪽 스트림 처리를 확인한다. → 원인 2다.
3. `runInShell`을 `false`로 바꿔 실행 경로 오류가 사라지는지 확인한다. → 원인 3이다.

## 4. 시정 조치

파이썬 실행 인자에 `-u`를 추가하고, Dart에서 `utf8.decoder`와 `LineSplitter`로 줄 단위 로그를 복원한다. 쉘을 거치지 않고(`runInShell: false`) 절대 경로로 직접 실행한다.

```dart
// server_service.dart
String get _pythonPath {
  if (Platform.isWindows) {
    // Platform.resolvedExecutable (Release exe) 기준 python_assets/python/python.exe 사용
    final embedPath = p.join(
      _executableDir,
      'python_assets',
      'python',
      'python.exe',
    );
    if (File(embedPath).existsSync()) return p.normalize(embedPath);

    // 개발 환경에서의 Fallback (프로젝트 루트의 python_runtime 폴더)
    for (int i = 3; i <= 7; i++) {
      final segments = List.filled(i, '..');
      final devPath = p.normalize(
        p.joinAll([
          _executableDir,
          ...segments,
          'python_runtime',
          'python.exe',
        ]),
      );
      if (File(devPath).existsSync()) return devPath;
    }

    // 기본값
    return 'python_runtime\\python.exe';
  }
  return 'python3';
}

String get _scriptPath {
  if (Platform.isWindows) {
    // 1. 배포 환경 (python_assets/main.py)
    final deployPath = p.join(_executableDir, 'python_assets', 'main.py');
    if (File(deployPath).existsSync()) return deployPath;

    // 2. 개발 환경 (python_packetSnip/main.py)
    for (int i = 3; i <= 7; i++) {
      final segments = List.filled(i, '..');
      final devPath = p.normalize(
        p.joinAll([
          _executableDir,
          ...segments,
          'python_packetSnip',
          'main.py',
        ]),
      );
      if (File(devPath).existsSync()) return devPath;
    }

    return 'python_packetSnip\\main.py';
  }
  return 'main.py';
}

Future<void> _startSniffer() async {
  try {
    final adapterGuid = await _findLoopbackAdapter();
    final pythonPath = _pythonPath;
    final scriptPath = _scriptPath;

    // 1. 실행 파일 존재 여부 선제적 확인
    if (!await File(pythonPath).exists()) {
      throw "파이썬 엔진을 찾을 수 없습니다: $pythonPath";
    }

    _log("INFO", "MySQL 스니퍼 실행 시도...");

    // 2. 프로세스 실행 (runInShell: false 권장)
    _snifferProcess = await Process.start(
      pythonPath,
      ['-u', scriptPath, adapterGuid], // -u 옵션 유지
      runInShell: false, // 쉘을 거치지 않고 직접 실행
      workingDirectory: _executableDir, // 작업 디렉토리 명시
    );

    // 3. LineSplitter를 통한 안정적인 로그 수집
    _snifferProcess!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _log("STDOUT", line); // 이미 스니퍼에서 형식이 지정되어 있으므로 직접 출력
        });

    _snifferProcess!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _log("STDERR", line); // 스니퍼의 에러 로그 직접 출력
        });

    // 4. 즉각적인 종료 감지
    _snifferProcess!.exitCode.then((code) {
      _log("INFO", "스니퍼 프로세스 종료됨 (Exit Code: $code)");
    });
  } catch (e) {
    _log("ERROR", "스니퍼 실행 실패: $e");
  }
}
```

원본 코드의 강조 줄은 `['-u', scriptPath, adapterGuid]`(`-u` 옵션 유지)이다.

{% hint style="info" %}
NOTE: 코드는 발췌본이다. `_executableDir`, `_findLoopbackAdapter()`, `_log()`, `p`(path 패키지)는 이 문서에 정의가 없다. 실행 파일 위치와 파이썬 위치(`python_assets/python/python.exe`)는 다른 문서의 `python_runtime/python.exe` 서술과 다르다. 최종 배포 폴더 구조는 확인이 필요하다.
{% endhint %}

## 5. 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 스니퍼를 실행하고 주문 이벤트를 발생시킨다 | 대시보드에 로그가 즉시 나온다 | 이벤트 발생 후 몇 초 안에 표시된다 (기준 시간은 원본에 없음, 확인 필요) |
| 2 | 스니퍼 프로세스를 종료한다 | `스니퍼 프로세스 종료됨 (Exit Code: ...)` 로그가 나온다 | 종료 로그가 표시된다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 파이썬 출력 버퍼링이 파이프에서 문제가 되는 이유를 내 말로 설명하면?
- [ ] 같은 증상이 다른 언어의 자식 프로세스에서 나면 어떻게 확인하겠는가?
