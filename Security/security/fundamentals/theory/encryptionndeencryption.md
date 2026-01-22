# EncryptionNDeencryption

* 아스키코드를 활용해서 암호화를 할 수 있다.
* 문자열의 문자 하나하나 약속된 특정 값을 대입해 변환시키면 암호화가 가능하다.
* 약속된 특정 값을 활용해 암호화된 비밀번호를 복구할 수 있다.

```python
# 암호화 예제

print(chr(ord('A') * 9))

pw = "q1w2e3r4"

en_pw = ""

for i in pw:
    en_pw += chr(ord(i) * 9)

print("기존 비밀번호: %s" %pw)
print("암호화된 비밀번호: {pw}".format(pw=en_pw))

# 복호화 예제

de_pw = ""

for i in en_pw:
    de_pw += chr(ord(i) // 9) # // : 몫 연산자

print("암호화 해제된 비밀번호: {pw}".format(pw=de_pw))
```

출력 예시:

```
기존 비밀번호: q1w2e3r4
암호화된 비밀번호: ϹƹЯǂ΍ǋЂǔ
암호화 해제된 비밀번호: q1w2e3r4
```

```python
# 입력 함수: input("출력할 메시지")

inputData = input("비밀번호: ")

temp = ""

for i in inputData:
    temp += chr(ord(i) * 3 + 1)

print("현재 비밀번호: {pw}\n암호화 후: {en_pw}".format(pw = inputData, en_pw = temp))
```
