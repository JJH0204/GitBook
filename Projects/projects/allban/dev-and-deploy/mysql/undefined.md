# 실시간 출력 지연 문제

<pre class="language-dart"><code class="lang-dart">// server_service.dart
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
    for (int i = 3; i &#x3C;= 7; i++) {
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
    for (int i = 3; i &#x3C;= 7; i++) {
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

Future&#x3C;void> _startSniffer() async {
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
<strong>      ['-u', scriptPath, adapterGuid], // -u 옵션 유지
</strong>      runInShell: false, // 쉘을 거치지 않고 직접 실행
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
</code></pre>
