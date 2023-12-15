## Clash for Windows

* 打开`终端`，复制下面的命令到`终端`里执行！完成后会自动打开<img src="./clash.png" />`主页`-->`开机启动！`

```
wget 'https://github.com/stuvn/link/releases/download/v0.20.21/clash.tar.gz' && tar zxvf clash.tar.gz && \
chmod -R +x ~/clash/cfw ~/clash/resources/static/files/linux/x64/* && \
echo 'export http_proxy=http://127.0.0.1:7890'>> ~/.profile && \
echo 'export https_proxy=http://127.0.0.1:7890'>> ~/.profile && \
source ~/.profile && rm -f ~/clash.tar.gz && ~/clash/cfw
``` 

![Clash](media/linux/cfw_3.jpg ':size=720')

* 登入您购买`SS`服务的`机场网站`-->点击`一键订阅`-->点击`复制订阅地址`

![Clash](media/linux/sub.jpg ':size=720')

* 打开<img src="./clash.png" />`配置`-->把复制的`订阅链接`粘贴到顶部的`从URL下载`-->然后点`下载`-->选择`配置(订阅)`

![Clash](media/linux/cfw_1.jpg ':size=720')

* 打开<img src="./clash.png" />`代理`-->选择`规则`模式-->根据情况`手动选择节点`(首次安装使用，可能需要`重启系统`)

![Clash](media/linux/cfw_2.jpg ':size=720')

!> 常见问题

`[1]` 退出或弃用<img src="./clash.png" />后无法正常上网？

打开`终端`执行下面的命令，`解除代理绑定`(`需重启系统才能生效`)

```
sed -i "s/^export http.*//g" ~/.profile

```

`[2]` 如果想重新用<img src="./clash.png" />，怎么重新绑定代理？

打开`终端`执行下面的命令，`重新绑定代理！`(`需重启系统才能生效`)

```
echo 'export http_proxy=http://127.0.0.1:7890'>> ~/.profile && \
echo 'export https_proxy=http://127.0.0.1:7890'>> ~/.profile && \
~/clash/cfw
```

## Shadowsocks-libev 

**Ubuntu/Debian** - 安装`Shadowsocks-libev`

```
sudo apt update && sudo apt install shadowsocks-libev simple-obfs -y
```

**ArchLinux/Manjaro** - 安装`Shadowsocks-libev`

```
sudo pacman -Sy && yes | sudo pacman -S shadowsocks-libev simple-obfs
```

* 登入您购买`SS`服务的`机场网站`-->左侧`使用文档`-->`第三方App订阅地址(及ss://链接)`-->`复制ss://链接`

![linux](media/linux/libev_1.jpg ':size=720')

* 打开`终端`，安装解释和执行脚本，执行后按提示粘贴`ss://链接` (保持前台运行，可`最小化`窗口，但`不能关闭`)

```
# 下载脚本，只需首次安装即可
wget https://raw.githubusercontent.com/stuvn/link/master/ss.sh && chmod +x ss.sh 
# 每次连接，都要重新执行脚本
bash ss.sh
```

![linux](media/linux/linux_2.jpg ':size=720')

* 执行`脚本命令`会创建一个本地`sock5代理`服务，然后配合`SwitchyOmega`使用。具体参考 [浏览器扩展](switchyomega)

![linux](media/linux/linux_3.jpg ':size=720')

!> 常见问题

`[1]` 必须配合`SwitchyOmega`吗？

是的，`Shadowsocks-libev`必须配合`SwitchyOmega`使用，具体请参考 [浏览器扩展](switchyomega)

`[2]` 如何切换至不同的`路线/节点`？

关闭`终端`窗口后重新打开，然后复制您要使用的`SS节点`对应的`ss://链接`，重新`bash ss.sh`

`[3]` 如何设置开机后`自动开启`代理？

把其中一个`SS节点`对应的`连接命令`添加到系统的`启动项`里。<a href="./media/linux/ubuntu_auto.jpg" target="_blank">Ubuntu 参考</a> 或 <a href="./media/linux/arch_auto.jpg" target="_blank">ArchLinux 参考</a>
