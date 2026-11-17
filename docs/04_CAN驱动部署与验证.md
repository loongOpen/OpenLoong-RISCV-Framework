# 04 CAN 驱动部署与验证

[返回首页](../README.md) · [下一步：USB 串口](05_USB串口驱动编译与部署.md)

## 所需文件

镜像未附带所需 CAN 模块。记录使用厂商包 `can_tools_k3_oh61_6.18.3_20260929.tar.gz`，包含 `can.ko`、`can-dev.ko`、`can-raw.ko`、`flexcan.ko` 和 CAN 工具。

## 电脑端推送

按[连接章节](03_HDC连接与调试.md)设置 `TARGET`。先在电脑解压厂商包，确认内部目录，再设置 `CAN_TOOLS_DIR` 为其中 `can_tools` 目录：

```sh
export CAN_TOOLS_DIR='<解压后的can_tools绝对路径>'
hdc -t "$TARGET" shell 'mkdir -p /data/apps/drivers/modules /data/apps/can_tools'
hdc -t "$TARGET" file send "$CAN_TOOLS_DIR/modules" /data/apps/drivers/
hdc -t "$TARGET" file send "$CAN_TOOLS_DIR/bin" /data/apps/can_tools/
hdc -t "$TARGET" shell
```

若只有一个设备，`-t "$TARGET"`可省略。

## 板端加载

确认模块来自当前镜像配套包后执行：

```sh
insmod /data/apps/drivers/modules/can.ko
insmod /data/apps/drivers/modules/can-dev.ko
insmod /data/apps/drivers/modules/can-raw.ko
insmod /data/apps/drivers/modules/flexcan.ko
chmod 755 /data/apps/can_tools/bin/*
export PATH=/data/apps/can_tools/bin:$PATH
ls /sys/class/net
```

已加载的模块无需重复 `insmod`。原记录可见 `can0` 至 `can5`，实际接口数量以板卡和镜像为准。

## 板端接口配置

先停止使用该接口的应用；以下命令会改变 `can0` 状态。根据总线上全部设备支持的模式、速率和接线选择一种。

经典 CAN 示例：

```sh
ip link set can0 down
ip link set can0 type can bitrate 1000000 
ip link set can0 up
```

CAN FD 示例，仲裁段 1 Mbps、数据段 5 Mbps：

```sh
ip link set can0 down
ip link set can0 type can bitrate 1000000 dbitrate 5000000 fd on 
ip link set can0 up
```
