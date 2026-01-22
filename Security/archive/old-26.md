# old 26

```php
<?php  include "../../config.php";  
  if($_GET['view_source']) view_source();  
?><html>  
<head>  
<title>Challenge 26</title>  
<style type="text/css">  
body { background:black; color:white; font-size:10pt; }     
a { color:lightgreen; }  
</style>  
</head>  
<body>  
<?php  if(preg_match("/admin/",$_GET['id'])) { echo"no!"; exit(); }  $_GET['id'] = urldecode($_GET['id']);  
  if($_GET['id'] == "admin"){    solve(26);  
  }  
?>  
<br><br>  
<a href=?view_source=1>view-source</a>  
</body>  
</html>
```

Link to challenge: https://webhacking.kr/challenge/web-11/?id=admin

Encoded strings:

```
%22%61%64%6D%69%6E%22
%2522%2561%2564%256D%2569%256E%2522
```
