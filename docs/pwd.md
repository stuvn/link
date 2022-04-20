!> 研究表明`纯数字`的`SS密码`已被证实不安全！具体请参考 <a href="https://www.usenix.org/system/files/sec21summer_len.pdf#page=13" target="_blank">相关论文</a>

!> 改`SS密码`后，请删掉客户端里的路线，重新添加。`如何删除路线？`[点击这里](other?id=删除路线)

## 改SS密码

*  登入您购买`SS节点`的网站，如`账号`的`SS密码`不符合安全要求，请点击`续费`旁的`改SS密码`

![windows](media/win/pwd_1.jpg ':size=640')

*  把`SS密码`改成`数字`和`大小写字母`组合的`复杂密码`，修改后[删掉](other?id=删除路线)客户端里的路线，`重新添加`

![windows](media/win/pwd_2.jpg ':size=640')

!> 理论上`SS密码`越复杂越安全，点击下面的`生成`，然后点`复制`得到一个`随机`的`复杂密码`！

<style type="text/css"> 
.box{
	background-color: white;
}

.box h2{
  margin-bottom: 40px;
  text-align: left;
  font-size: 26px;
  color: #015a96;
  font-family: sans-serif;
}

.box table{
  width: 300px;
  align-items: center;
  border: 0px solid;
}


input {
  padding: 20px;
  user-select: none;
  height: 50px;
  width: 300px;
  border-radius: 6px;
  border: none;
  border: 2px solid rgb(13, 152, 245);
  outline: none;
  font-size: 22px;
}

input::placeholder{
  font-size: 23px;
} 

#button {
	font-family: sans-serif;
	font-size: 15px;
	border: 2px solid rgb(20, 139, 250);
	width: 121px;
	height: 50px;
	text-align: center;
	background-color: #0c81ee;
	display: flex;
	color: rgb(255, 255, 255);
	justify-content: center;
	align-items: center;
	cursor: pointer;
	border-radius: 7px;
}

#button:hover {
	color: white;
	background-color: black;
}
</style> 

<div class="box">
<h2>随机密码生成器</h2>
<input type="text" name="" placeholder=" 随机密码" id="password" readonly><br /><br />
<table>
 <tr style="border: none;">
   <th style="border: none;"><div id="button" class="btn1" onclick="genPassword()">生成</div></th>
   <th style="border: none;"><div id="button" class="btn2" onclick="copyPassword()">复制</div></th>
 </tr>
</table>
</div>