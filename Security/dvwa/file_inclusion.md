# File\_Inclusion

"파일 실행 공격"

* [LFI](/broken/pages/b9577e57827eb9a9c6c16e03cd2efef57c0a93dd) (Local FI)
* [RFI](/broken/pages/5000a694e9b2e2fb54ed55a20e505c8920398c1b) (Remote FI)
* 값의 확인 없이 바로 실행
* /에 대한 공백 처리가 없어 LFI 공격이 가능하다
* http://, https:// 덕분에 RFI 공격이 불가능해졌다.
* HTML / 브라우저의 취약점으로 공략 가능
  * Http, httP, HTTP 모두 http로 인식
* file에 저장된 값이 리스트에 포함되어 있는지 검사
* file로 시작하고 include.php가 아닌 경우 대응 필요
* file로 시작하는 프로토콜은 해결 못함
* 실행되는 파일만 지정했다.
