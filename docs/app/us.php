<?php

$json_string = file_get_contents("id.json");
$data = json_decode($json_string,true);

?>

<html>
<head>
<meta charset="utf-8">
<title>Apple ID</title>
</head>
<body>
<style type="text/css"> 
.box{
	background-color: white;
}

input {
  padding: 10px;
  user-select: none;
  height: 36px;
  width: 200px;
  border-radius: 5px;
  border: none;
  border: 2px solid rgb(13, 152, 245);
  outline: none;
  font-size: 18px;
}
</style> 

<form action="" method="post">
<div  class="box">
账号: <input type='text' name='id' value="<?php echo $data[0]["id"];?>" disabled><br /><br />
密码: <input type='text' name='pwd'><br /><br />
</div>
<input type="submit" value="提交">
</form>
 
</body>
</html>

<?php

if(strlen($_POST["pwd"])<8){
	echo "<font color=red>密码不能为空/长度不能小于8</fonf>";die();
} else {
	$data[0]["pwd"] = $_POST["pwd"];
	$json_string = json_encode($data);
	file_put_contents("id.json",$json_string);
	echo "密码修改成功！";
}
?>
