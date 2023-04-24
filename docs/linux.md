## Clash (🐱小蓝猫) 

* 打开`终端`，复制下面的命令到`终端`里执行！完成后会自动打开`Clash`的常规设置-->打开`开机启动！`

```
wget 'https://www.sop.pw/media/linux/clash.zip' && unzip clash.zip && \
chmod -R +x ~/clash/cfw ~/clash/resources/static/files/linux/x64/* && \
echo 'export http_proxy=http://127.0.0.1:7890'>> ~/.profile && \
echo 'export https_proxy=http://127.0.0.1:7890'>> ~/.profile && \
source ~/.profile && rm -f ~/clash.zip && ~/clash/cfw
``` 

![Clash](media/linux/cfw_1.jpg ':size=720')

* 登入您购买`SS节点`的网站-->进入`账号页面`-->点击`续费链接`右侧的`订阅链接`-->选`clash`-->`复制链接`

![Clash](media/linux/cfw_2.jpg ':size=720')

* 打开`Clash`-->`配置`-->把复制的`订阅链接`粘贴到顶部的`从URL下载`-->然后点`下载`-->选择添加的`订阅`

![Clash](media/linux/cfw_3.jpg ':size=720')

* 打开`clash`的代理设置-->选择`规则`模式-->再`选择节点`！[`首次安装`的新用户，`需重启系统`才能使用]

![Clash](media/linux/cfw_4.jpg ':size=720')

!> 常见问题

`[1]` 退出或弃用`clash`后无法正常上网？

打开`终端`，执行下面的命令，`解除代理绑定！`[`需重启系统才能生效`]

```
sed -i "s/^export http.*//g" ~/.profile

```

`[2]` 如果想重新用`Clash`，怎么重新绑定代理？

打开`终端`，执行下面的命令，`重新绑定代理！`[`需重启系统才能生效`]

```
echo 'export http_proxy=http://127.0.0.1:7890'>> ~/.profile && \
echo 'export https_proxy=http://127.0.0.1:7890'>> ~/.profile && \
~/clash/cfw
```

## Shadowsocks-libev 

`Ubuntu/Debian`-`安装命令`

```
sudo apt update && sudo apt install shadowsocks-libev simple-obfs -y
```

`ArchLinux/Manjaro`-`安装命令`

```
sudo pacman -Sy && yes | sudo pacman -S shadowsocks-libev simple-obfs
```
* 登入您购买`SS节点`的网站，点击`Linux命令`栏右边的`复制命令`[每个节点都对应一个`Linux命令`]

![linux](media/linux/linux_1.jpg ':size=720')

* 打开`终端`，把复制的`Linux命令`粘贴到`终端`执行 [保持前台运行，可`最小化`窗口，但`不能关闭`]

![linux](media/linux/linux_2.jpg ':size=720')

* 执行`Linux命令`会创建一个本地`sock5代理`服务，然后配合`SwitchyOmega`使用。具体参考 [火狐扩展](firefox)

![linux](media/linux/linux_3.jpg ':size=720')

!> 常见问题

`[1]` 必须配合`SwitchyOmega`吗？

是的，`Shadowsocks-libev`必须配合`SwitchyOmega`使用，具体请参考 [火狐扩展](firefox)

`[2]` 如何切换至不同的`路线/节点`？

关闭`终端`窗口后重新打开，然后复制您要使用的`SS节点`对应的`Linux命令`，重新执行！

`[3]` 如何设置开机后`自动开启`代理？

把其中一个`SS节点`对应的`Linux命令`添加到系统的`启动项`里。<a href="https://www.sop.pw/media/linux/ubuntu_auto.jpg" target="_blank">Ubuntu 参考</a> 或 <a href="https://www.sop.pw/media/linux/arch_auto.jpg" target="_blank">ArchLinux 参考</a>