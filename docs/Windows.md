!> ⚠️ 不要安装多个VPN软件，并卸载`360`、`电脑管家`等国产软件(`以前能用不代表它没有监控你`)

## v2rayN

* 支持`Windows 7+`(要求 [.NET 6.0](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-desktop-6.0.19-windows-x64-installer) 以上版本)

* 点击下载 <a href="media/win/v2rayN.zip" target="_blank">v2rayN.zip</a> ，解压后运行`v2rayN`文件夹里的`v2rayN.exe`

* 登入您购买`SS`服务的`机场网站`-->左侧`使用文档`-->`第三方App订阅地址(及ss://链接)`-->`复制V2rayN订阅`

![v2rayN](media/win/v2n_1.jpg ':size=720')

* 打开 <img src="./v2rayN.png" />-->`订阅分组`(订阅分组设置) -->`添加(订阅)` -->别名:`XX加速器`-->Url:`粘贴复制的v2rayN订阅地址`

![v2rayN](media/win/v2n_2.jpg ':size=720')

* 打开 <img src="./v2rayN.png" />-->`订阅分组`-->`更新全部订阅`-->选择节点`设为活动服务器`-->系统代理设置为:`自动配置系统代理`

![v2rayN](media/win/v2n_3.jpg ':size=720')

!> [常见问题](https://github.com/2dust/v2rayN/wiki/%E7%B3%BB%E7%BB%9F%E4%BB%A3%E7%90%86%E5%92%8C%E8%B7%AF%E7%94%B1)

`[1]` 如何`更新订阅？`

打开 <img src="./v2rayN.png" />-->`订阅分组`-->`更新全部订阅`(不通过代理)

`[2]` 按教程设置后仍连不上？

打开 <img src="./v2rayN.png" />-->系统代理:`清除系统代理`-->`重启服务`-->系统代理:`自动配置系统代理`

## Shadowsocks

* 俗称`小飞机`(`支持Windows 7+`) 要求 [.NET 4.6.2](https://dotnet.microsoft.com/zh-cn/download/dotnet-framework/thank-you/net462-web-installer) 或 [.NET 4.8.1](https://dotnet.microsoft.com/zh-cn/download/dotnet-framework/thank-you/net481-web-installer) 

* 点击下载 <a href="media/win/win.zip" target="_blank">Shadowsocks</a> ，解压后运行`win`文件夹里的 <img src="./shadowsocks.png" /> 如提示`.NET`版本过低，请下载 [.NET 4.6.2 ](https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe)

![shadowsocks](media/win/ssw_1.jpg ':size=720')

* 登入您购买`SS`服务的`机场网站`-->左侧`使用文档`-->`第三方App订阅地址(及ss://链接)`-->`复制ss://链接`

![shadowsocks](media/win/ssw_2.jpg ':size=720')

* 导入节点。右下角任务栏上的 <img src="./shadowsocks.png" />-->`鼠标右键`-->`服务器`-->`从剪贴板导入URL`(`可复制多条ss://链接导入`)

![shadowsocks](media/win/ssw_3.jpg ':size=720')

* 选择`服务器`-->选择`系统代理模式`-->`PAC模式`(推荐用`PAC模式`，遇到无法打开的网站请参考 [浏览器扩展](switchyomega))

![shadowsocks](media/win/ssw_4.jpg ':size=720')

!> 常见问题

`[1]` `Shadowsocks`错误:端口已被占用！

`重复运行`了客户端，`请退出客户端`重启系统！[如何更新节点](delete?id=windows)

`[2]` 非预期***无法加载DLL`"libsscrypto.dll"`

请安装 [Visual C++ 2015 (x86)](https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x86.exe) 如仍不能用，请将`win`文件夹移到某磁盘根目录下，比如`D:\win\`

`[3]` 确认设置没问题，但还是不能用！

卸载`360、电脑管家`等国产软件，重启系统！如仍不能用请参考 [浏览器扩展](switchyomega) 教程，配合`SwitchyOmega`使用！

## Clash for Windows

* 俗称`小蓝猫`(支持`Windows 10+`)

* <a href="media/win/clash.exe" target="_blank">点击下载</a> 运行<img src="./clash.png" />安装，登入您购买`SS`服务的`机场网站`-->点击`一键订阅`-->点击`复制订阅地址`

![win](media/win/sub.jpg ':size=720')

* 打开<img src="./clash.png" />`配置`-->把复制的`订阅链接`粘贴到顶部的`从URL下载`-->然后点`下载`-->选择`配置(订阅)`

![win](media/win/cfw_1.jpg ':size=720')

* 打开<img src="./clash.png" />`代理`-->选择`规则`模式-->根据情况`手动选择节点`(不建议`自动选择`，因为`会自动跳IP`)

![win](media/win/cfw_2.jpg ':size=720')

* 打开<img src="./clash.png" />`主页`-->点击`系统代理`实现`连接/断开`VPN-->如需代理`Telegram/游戏`等请开`TUN模式`

![win](media/win/cfw_3.jpg ':size=720')

`[1]` 如何`更新订阅？`

打开<img src="./clash.png" />`主页`-->关掉`系统代理`-->打开<img src="./clash.png" />`配置`-->选择订阅更新(右侧`↻`)
