# old 6

{% code title="index.php" %}
```php
<?php  
include "../../config.php";  
if($_GET['view_source']) view_source();  
if(!$_COOKIE['user']){  $val_id="guest";  $val_pw="123qwe";  
  for($i=0;$i<20;$i++){    $val_id=base64_encode($val_id);    $val_pw=base64_encode($val_pw);  
  }  $val_id=str_replace("1","!",$val_id);  $val_id=str_replace("2","@",$val_id);  $val_id=str_replace("3","$",$val_id);  $val_id=str_replace("4","^",$val_id);  $val_id=str_replace("5","&",$val_id);  $val_id=str_replace("6","*",$val_id);  $val_id=str_replace("7","(",$val_id);  $val_id=str_replace("8",")",$val_id);  $val_pw=str_replace("1","!",$val_pw);  $val_pw=str_replace("2","@",$val_pw);  $val_pw=str_replace("3","$",$val_pw);  $val_pw=str_replace("4","^",$val_pw);  $val_pw=str_replace("5","&",$val_pw);  $val_pw=str_replace("6","*",$val_pw);  $val_pw=str_replace("7","(",$val_pw);  $val_pw=str_replace("8",")",$val_pw);  Setcookie("user",$val_id,time()+86400,"/challenge/web-06/");  Setcookie("password",$val_pw,time()+86400,"/challenge/web-06/");  
  echo("<meta http-equiv=refresh content=0>");  
  exit;  
}  
?>  
<html>  
<head>  
<title>Challenge 6</title>  
<style type="text/css">  
body { background:black; color:white; font-size:10pt; }  
</style>  
</head>  
<body>  
<?php  
$decode_id=$_COOKIE['user'];  
$decode_pw=$_COOKIE['password'];  
  
$decode_id=str_replace("!","1",$decode_id);  
$decode_id=str_replace("@","2",$decode_id);  
$decode_id=str_replace("$","3",$decode_id);  
$decode_id=str_replace("^","4",$decode_id);  
$decode_id=str_replace("&","5",$decode_id);  
$decode_id=str_replace("*","6",$decode_id);  
$decode_id=str_replace("(","7",$decode_id);  
$decode_id=str_replace(")","8",$decode_id);  
  
$decode_pw=str_replace("!","1",$decode_pw);  
$decode_pw=str_replace("@","2",$decode_pw);  
$decode_pw=str_replace("$","3",$decode_pw);  
$decode_pw=str_replace("^","4",$decode_pw);  
$decode_pw=str_replace("&","5",$decode_pw);  
$decode_pw=str_replace("*","6",$decode_pw);  
$decode_pw=str_replace("(","7",$decode_pw);  
$decode_pw=str_replace(")","8",$decode_pw);  
  
for($i=0;$i<20;$i++){  $decode_id=base64_decode($decode_id);  $decode_pw=base64_decode($decode_pw);  
}  
  
echo("<hr><a href=./?view_source=1 style=color:yellow;>view-source</a><br><br>");  
echo("ID : $decode_id<br>PW : $decode_pw<hr>");  
  
if($decode_id=="admin" && $decode_pw=="nimda"){  solve(6);  
}  
?>  
</body>  
</html>
```
{% endcode %}

The page encodes the default credentials into cookies by:

* Repeatedly base64-encoding the string 20 times.
* Replacing digits 1–8 with special characters: 1→!, 2→@, 3→$, 4→^, 5→&, 6→\*, 7→(, 8→).

To become the admin user, you need to set the cookies such that after reversing those operations on the server (replace specials back to digits, then base64-decode 20 times) you get ID = "admin" and PW = "nimda".

Python helper to produce the encoded cookie value:

{% code title="encode.py" %}
```python
import base64

def multi_base64_encode(input_string, times=20):
    encoded = input_string.encode()
    for _ in range(times):
        encoded = base64.b64encode(encoded)
    return encoded.decode()

def replace_special_characters(encoded_string):
    replacements = {
        "1": "!",
        "2": "@",
        "3": "$",
        "4": "^",
        "5": "&",
        "6": "*",
        "7": "(",
        "8": ")"
    }
    for key, value in replacements.items():
        encoded_string = encoded_string.replace(key, value)
    return encoded_string

# 입력 받기
input_string = input()

# 20번 base64 인코딩하기
result = multi_base64_encode(input_string)

# 특수문자로 치환하기
result = replace_special_characters(result)

# 결과 출력
print("20번 인코딩된 결과:")
print(result)
```
{% endcode %}

{% stepper %}
{% step %}
### Encode credentials

Run the Python script and enter the credential strings:

* For the ID: enter `admin`
* For the PW: enter `nimda`

The script outputs the transformed value to use in the cookie.
{% endstep %}

{% step %}
### Set cookies

Use your browser dev tools (Application / Storage → Cookies) or an HTTP client to set the following cookies for path /challenge/web-06/:

* Cookie name: `user` → value: (output for `admin`)
* Cookie name: `password` → value: (output for `nimda`)
{% endstep %}

{% step %}
### Refresh

Refresh the page. If decoding yields ID "admin" and PW "nimda", the script calls solve(6) and you complete the challenge.
{% endstep %}
{% endstepper %}
