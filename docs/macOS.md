## ClashX Pro

* 支持`macOS 10.6+`系统

* 点击下载 <a href="media/mac/ClashX.dmg" target="_blank">ClashX Pro</a> 下载后双击运行`ClashX.dmg`，按照提示安装！[`如提示权限，请输入macOS密码`]

![ClashX](media/mac/clx_1.jpg ':size=720')

* 登入您购买`SS`服务的`机场网站`-->点击`一键订阅`-->`导入到ClashX`(`如导入失败，复制订阅地址，手动添加`)

![ClashX](media/mac/clx_2.jpg ':size=720')

* 点击右上角 <img src="./clasx.png" />，将`出站模式`设置为`规则`-->根据需要手动`选择节点`-->然后开启`设置为系统代理`

![ClashX](media/mac/clx_3.jpg ':size=720')

!> 常见问题

`[1]` 如何`更新订阅？`

点击右上角 <img src="./clasx.png" />-->关掉`设置为系统代理`-->`配置`(选择订阅)-->`托管配置`-->`更新`

`[2]` 按教程设置后却不能用？

`VPN软件`都是`相互冲突`的，请`卸载`其他`VPN软件`并重启`macOS`

`[3]` `无法联网` 卸载客户端也不行？打开`终端`执行以下命令`(需输入macOS密码,然后重启)`

```
sudo find /Library/Preferences/SystemConfiguration/ -type f ! -name "com.apple.Boot.*" -delete && rm -r ~/.config
```

## ShadowsocksX-NG

* 支持`macOS 10.12+`系统

* 下载安装 <a href="media/mac/ShadowsocksX-NG.dmg" target="_blank">ShadowsocksX-NG</a>，打开系统设置 -->`隐私与安全性` -->`已阻止使用"Sha…"`-->`仍要打开`

![ShadowsocksX-NG](media/mac/sec.jpg ':size=720')

* 登入您购买`SS`服务的`机场网站`-->左侧`使用文档`-->`第三方App订阅地址(及ss://链接)`-->`复制ss://链接`

![ShadowsocksX-NG](media/mac/ssx_1.jpg ':size=720')

* 导入节点。点击右上角状态栏的`小飞机`-->`导入服务器URL` (`复制多条ss://链接,可导入多个节点`)

![ShadowsocksX-NG](media/mac/ssx_2.jpg ':size=720')

* 根据需求`选择节点`-->`开启代理`[默认已开启]-->选择`代理模式`-->推荐用`PAC自动模式`[默认模式]

![ShadowsocksX-NG](media/mac/ssx_3.jpg ':size=720')

!> 常见问题

`[1]` 如何`更新订阅？`

不支持在线更新，只能删掉节点重新添加！[具体参考](delete?id=macos)

`[2]` `无法翻墙`或打不开`部分特定`网站？

推荐配合`SwitchyOmega`使用，具体请参考 [浏览器扩展](switchyomega)
