# 03 HDC 连接与调试

[返回首页](../README.md) · [下一步：CAN 部署](04_CAN驱动部署与验证.md)

## 电脑端准备 HDC

使用 `toolchains-linux-x64-6.1.0.31-Release.zip`，来源见[资源表](10_外部资源与版本说明.md)。解压后找到实际 `hdc` 所在目录，将其加入 PATH：

```sh
export PATH="$PATH:<HDC所在目录>"
hdc -v
hdc --help
```

## 板端启用调试连接

在串口进入板端命令行，执行：

```sh
param set persist.hdc.mode.tcp enable
```

电脑与主控接入同一调试网络，通过路由器确认实际 IP。

## 电脑端连接

以下变量仅在当前电脑终端有效；新开终端需要重新设置。后续章节沿用 `TARGET`。

```sh
export DEVICE_IP='<板子实际IP>'
export TARGET="${DEVICE_IP}:55555"
hdc tconn "$TARGET"
hdc list targets
hdc -t "$TARGET" shell
```

最后一条命令进入板端 shell；执行 `exit` 返回电脑。指定 `-t` 可避免连接多块板子时选错目标。

## 文件传输

电脑端：

```sh
hdc -t "$TARGET" file send <电脑文件路径> /data/local/tmp/
hdc -t "$TARGET" file recv /data/local/tmp/<文件名> ./
```
