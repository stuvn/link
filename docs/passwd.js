var password=document.getElementById("password");

function genPassword() {
    var chars = "23456789abcdefghkmnpqrstwxyzABCDEFGHKMNPRSTWXYZ+@#$";
    var passwordLength = 18;
    var password = "";
    for (var i = 1; i <= passwordLength; i++) {
        var randomNumber = Math.floor(Math.random() * chars.length);
        password += chars.substring(randomNumber, randomNumber +1);
    }
    document.getElementById("password").value = password;
}

function copyPassword() {
    var copyText = document.getElementById("password");
    copyText.select();
    copyText.setSelectionRange(0, 999);
    document.execCommand("copy");
}

function getid() {
	var url = "https://www.sop.pw/app/id.json"            				// 申明一个XMLHttpRequest
	var request = new XMLHttpRequest();             		// 设置请求方法与路径
	request.open("get", url);	                		// 不发送数据到服务器
	request.send(null);						//XHR对象获取到返回信息后执行
	request.onload = function () {                  		// 返回状态为200，即为数据获取成功
		if (request.status == 200) {
			var data = JSON.parse(request.responseText);
			console.log(data);                    		//获取jsonTip的div
			var $jsontip = $("#jsonTip");          		//存储数据的变量 
			var strHtml = "";                       	//清空内容 
			$jsontip.empty();                       	//将获取到的json格式数据遍历到div中

                        strHtml += "账号: " + data[0].id + "<br><br>";
                        strHtml += "密码: " + data[0].pwd + "<br><br>";  
			strHtml += '登录时，不要开启"双重认证" [<a href=https://www.sop.pw/app/id.html target="_blank">备用账号</a>]'; 

			$jsontip.html(strHtml);
		}
	}
}
