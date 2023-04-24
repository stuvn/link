## Clash for Windows

* 支持 Windows 10+

* 点击下载 <a href="media/win/clash_cn.exe" target="_blank">Clash</a> 或 <a href="media/win/clash.exe" target="_blank">备用下载</a> 运行`clash.exe`安装，打开`Clash`-->`常规`-->开启`系统代理/开机启动[建议]`

![win](media/win/cfw_1.jpg ':size=720')

* 登入您购买`SS节点`的网站-->进入`账号页面`-->点击`续费链接`右侧的`订阅链接`-->选择`clash`-->`复制链接`

![win](media/win/cfw_2.jpg ':size=720')

* 打开`Clash`-->`配置`-->把复制的`订阅链接`粘贴到顶部的`从URL下载`-->然后点`下载`-->选择添加的`订阅`

![win](media/win/cfw_3.jpg ':size=720')

* 打开`Clash`代理设置-->选择`规则`模式-->根据情况手动`选择节点`[不建议选`自动选优`，因为会`自动跳IP`]

![win](media/win/cfw_4.jpg ':size=720')

!> 首次安装`可能需要重启`才能用，`代理软件`通常是`相互冲突`的，请`卸载`其他的`代理软件！`

## Shadowsocks (小飞机)

* 支持 Windows 7+ （要求 [.NET 4.6.2](https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe) 以上版本）

* 点击下载 <a href="media/win/win.zip" target="_blank">Shadowsocks</a> ，解压后运行`win`文件夹里的小飞机。如提示`.NET`版本过低，请下载 [.NET 4.6.2 ](https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe)

![win](media/win/ss_1.jpg ':size=720')

* 登入您购买`SS节点`的网站，复制节点的`二维码链接`（每个节点都对应一个`二维码`和`二维码链接`）

![win](media/win/ss_2.jpg ':size=720')

* 导入服务器。任务栏上的小飞机-->鼠标右键-->服务器-->从剪贴板导入URL（`重复操作`添加其他节点）

![win](media/win/ss_3.jpg ':size=720')

* 选择服务器和系统代理模式-->`PAC模式`（平时代理请用`PAC模式`，遇到无法打开的网站请参考 [PAC 规则](pac) ）

![win](media/win/ss_4.jpg ':size=720')

!> 常见问题

`[1]` Shadowsocks 错误:端口已被占用！

说明`重复运行`客户端，请关掉客户端重启系统后再试！

`[2]` 非预期***无法加载DLL "libsscrypto.dll"

请下载安装 [Visual C++ 2015 (x86)](https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x86.exe) 如仍不能用，请将`win`文件夹移到某磁盘根目录下，比如`D:\win\`

`[3]` 确认设置没问题，但还是不能用！

卸载`360、电脑管家`等国产软件，重启系统！如仍不能用，请参考 [火狐扩展](firefox) 教程，配合`SwitchyOmega`使用！

## Netch (上网/游戏通用) 

* 支持Windows 7+ （要求 [.NET 4.8](https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe) 以上版本）

* 点击下载 <a href="media/win/netch.zip" target="_blank">Netch</a> ，解压后运行`Netch`文件夹里的`Netch`。如提示`.NET`版本过低，请下载 [.NET 4.8 ](https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe)

![netch](media/win/nc_1.jpg ':size=720')

* 登入您购买`SS节点`的网站，复制节点的`二维码链接`（每个节点都对应一个`二维码`和`二维码链接`）

![netch](media/win/nc_2.jpg ':size=720')

* 导入二维码链接。打开`Netch`-->服务器-->从剪贴板导入服务器（`重复操作`添加其他节点到客户端）

![netch](media/win/nc_3.jpg ':size=720')

* 只代理上网选`[4][网页代理]绕过***和中国大陆`，代理国外软件、游戏选`[3][TUN/TAP]绕过***和中国大陆`

![netch](media/win/nc_4.jpg ':size=720')

!> 常见问题

`[1]` 代理类软件都是`相互冲突`的！

若使用`Netch`客户端，请退出小飞机（删掉`win`文件夹）

`[2]` `Netch`无法配合`火狐扩展`使用！

`Netch`可实现`TUN/TAP`层代理，不需要配合`火狐扩展`使用！
