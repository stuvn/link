## ClashX (🐱小蓝猫)

* 支持 macOS 10.6+ 系统

* 点击下载 <a href="media/mac/ClashX.dmg" target="_blank">ClashX Pro</a> 下载后双击运行`ClashX.dmg`，按照提示安装！[`如提示权限，请输入macOS密码`]

![ClashX](media/mac/clx_1.jpg ':size=720')

* 登入您购买`SS服务`的机场网站-->点击`一键订阅`-->`导入到ClashX`(`如导入失败，复制订阅地址，手动添加`)

![ClashX](media/mac/clx_2.jpg ':size=720')

* 点击右上角`ClashX`，将`出站模式`设置为`规则`-->根据需要手动`选择节点`-->然后开启`设置为系统代理`

![ClashX](media/mac/clx_3.jpg ':size=720')

!> 常见问题

`[1]` 按教程设置后却不能用？

`VPN软件`都是`相互冲突`的，请`卸载`其他`VPN软件`并重启`macOS`

`[2]` 无法联网，卸载客户端后重启也不行？打开`macOS`终端执行以下命令`(需要输入macOS密码)`

```
sudo find /Library/Preferences/SystemConfiguration/ -type f ! -name "com.apple.Boot.*" -delete && rm -r ~/.config
```

## ShadowsocksX-NG

* 支持 macOS 10.12+ 系统

* 点击下载 <a href="media/mac/ShadowsocksX-NG.dmg" target="_blank">ShadowsocksX-NG</a>，下载后双击运行`ShadowsocksX-NG.dmg`，按照提示安装！[`如提示权限，请输入macOS密码`]

![ShadowsocksX-NG](media/mac/sec.jpg ':size=720')

* 登入您购买`SS节点`的网站，复制节点的`二维码链接`[每个节点都对应一个`二维码`和`二维码链接`]

![ShadowsocksX-NG](media/mac/sx_2.jpg ':size=720')

* 导入节点。点击右上角状态栏的`小飞机`-->`导入服务器 URL`[`重复操作`添加`其他节点`到客户端]

![ShadowsocksX-NG](media/mac/sx_3.jpg ':size=720')

* 根据需求`选择节点`-->`开启代理`[默认已开启]-->选择`代理模式`-->推荐用`PAC自动模式`[默认模式]

![ShadowsocksX-NG](media/mac/sx_4.jpg ':size=720')

!> 常见问题

`[1]` 设置没有错误，但是连不上外网！

请换个 [浏览器](down) 试一试！或配合`SwitchyOmega`使用，参考 [火狐扩展](firefox)

`[2]` 可以上`Google、Youtube、Twitter`等常用网站，但是打不开`某些`网站？

请添加`PAC用户自定规则`，参考 [PAC 规则](pac)。或配合`SwitchyOmega`使用，参考 [火狐扩展](firefox)。
