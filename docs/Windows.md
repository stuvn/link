## Clash for Windows

* 支持 Windows 10+

* 点击下载 <a href="media/win/clash.exe" target="_blank">Clash</a> 或 <a href="https://github.com/Fndroid/clash_for_windows_pkg" target="_blank">备用下载</a> 运行`clash.exe`安装，打开`Clash`-->`常规`-->开启`系统代理/开机启动[建议]`

![win](media/win/cfw_1.jpg ':size=720')

* 登入您购买`SS节点`的网站-->进入`账号页面`-->点击`续费链接`右侧的`订阅链接`-->选择`clash`-->`复制链接`

![win](media/win/cfw_2.jpg ':size=720')

* 打开`Clash`-->`配置`-->把复制的`订阅链接`粘贴到顶部的`从URL下载`-->然后点`下载`-->选择添加的`订阅`

![win](media/win/cfw_3.jpg ':size=720')

* 打开`Clash`代理设置-->选择`规则`模式-->根据情况手动`选择节点`[不建议选`自动选优`，因为会`自动跳IP`]

![win](media/win/cfw_4.jpg ':size=720')

!> 首次安装`可能需要重启`才能用，`代理软件`通常是`相互冲突`的，请`卸载`其他的`代理软件！`

## v2rayN (上网/游戏通用) 

* 支持Windows 7+ （要求 [.NET 6.0](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-desktop-6.0.19-windows-x64-installer) 以上版本）

* 点击下载 <a href="media/win/v2rayN.zip" target="_blank">v2rayN.zip</a> ，解压后运行`v2rayN`文件夹里的`v2rayN.exe`

![netch](media/win/v2n_1.jpg ':size=720')

* 登入您购买`SS节点`的网站，复制节点的`二维码链接`（每个节点都对应一个`二维码`和`二维码链接`）

![netch](media/win/v2n_2.jpg ':size=720')


!> 常见问题

`[1]` 如何`更新订阅？`

打开 -->`订阅分组` -->`更新全部订阅`(不通过代理)

`[2]` 按教程设置后仍连不上？

打开 -->系统代理: `清除系统代理` -->`重启服务` -->系统代理: `自动配置系统代理`

**⚠️ 不要同时安装其他VPN软件，并卸载`360`、`电脑管家`等国产软件（以前能用不代表它没有监控你）[参考资料](https://github.com/2dust/v2rayN/wiki/%E7%B3%BB%E7%BB%9F%E4%BB%A3%E7%90%86%E5%92%8C%E8%B7%AF%E7%94%B1)**

## Shadowsocks (小飞机)

* 支持 Windows 7+ （要求 [.NET 4.6.2](https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe) 以上版本）

* 点击下载 <a href="media/win/win.zip" target="_blank">Shadowsocks</a> ，解压后运行`win`文件夹里的小飞机。如提示`.NET`版本过低，请下载 [.NET 4.6.2 ](https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe)

![win](media/win/ss_1.jpg ':size=720')

* 登入您购买`SS`服务的`机场网站`-->左侧`使用文档`-->`第三方App订阅地址(及ss://链接)`-->`复制ss://链接`

![win](media/win/ss_2.jpg ':size=720')

* 导入节点。右下角任务栏上的<img scr="./shadowsocks.png" width=16>-->`鼠标右键`-->`服务器`-->`从剪贴板导入URL`(`可复制多条ss://链接导入`)

![win](media/win/ss_3.jpg ':size=720')

* 选择服务器-->选择系统代理模式-->`PAC模式`（推荐用`PAC模式`，遇到无法打开的网站请参考 [浏览器扩展](switchyomega) ）

![win](media/win/ss_4.jpg ':size=720')

!> 常见问题

`[1]` `Shadowsocks`错误:端口已被占用！

说明`重复运行`客户端，请关掉客户端重启系统后再试！

`[2]` 非预期***无法加载DLL`"libsscrypto.dll"`

请下载安装 [Visual C++ 2015 (x86)](https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x86.exe) 如仍不能用，请将`win`文件夹移到某磁盘根目录下，比如`D:\win\`

`[3]` 确认设置没问题，但还是不能用！

卸载`360、电脑管家`等国产软件，重启系统！如仍不能用请参考 [浏览器扩展](switchyomega) 教程，配合`SwitchyOmega`使用！
