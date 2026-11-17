# 05 USB 串口驱动编译与部署

[返回首页](../README.md) · [下一步：自启动](06_驱动开机自启动.md)

## 适用条件和验证范围

镜像选择 `CONFIG_USB_SERIAL=m`、`CONFIG_USB_SERIAL_FTDI_SIO=m`，但缺少对应模块。需要 `usbserial.ko` 和 `ftdi_sio.ko`。优先使用镜像配套模块或厂商完整匹配的内核构建环境。

公开源码分支为 `k3-br-v1.0.y`，Makefile 为 6.18.3。

## 获取构建材料

[资源表](10_外部资源与版本说明.md)列出公开源码入口。记录实际提交哈希，保留板端配置、厂商补丁、工具链版本及构建输出（包括适用的符号版本表）。在板端导出配置，电脑端接收：

板端：

```sh
zcat /proc/config.gz > /data/local/tmp/board.config
```

电脑端：

```sh
hdc -t "$TARGET" file recv /data/local/tmp/board.config ./board.config
```

## 电脑端编译流程

以下为内核模块定向构建流程。变量分别指向匹配源码、独立输出目录和已确认的交叉编译器前缀：

```sh
export SRC='<匹配内核源码绝对路径>'
export OUT='<独立构建输出绝对路径>'
export CROSS_COMPILE='<RISC-V交叉编译器前缀>'
mkdir -p "$OUT"
cp board.config "$OUT/.config"
make -C "$SRC" O="$OUT" ARCH=riscv CROSS_COMPILE="$CROSS_COMPILE" olddefconfig
make -C "$SRC" O="$OUT" ARCH=riscv CROSS_COMPILE="$CROSS_COMPILE" modules_prepare
make -C "$SRC" O="$OUT" ARCH=riscv CROSS_COMPILE="$CROSS_COMPILE" -j4 drivers/usb/serial/usbserial.ko drivers/usb/serial/ftdi_sio.ko
```

## 电脑端推送

```sh
hdc -t "$TARGET" shell 'mkdir -p /data/apps/drivers/modules'
hdc -t "$TARGET" file send "$OUT/drivers/usb/serial/usbserial.ko" /data/apps/drivers/modules/usbserial.ko
hdc -t "$TARGET" file send "$OUT/drivers/usb/serial/ftdi_sio.ko" /data/apps/drivers/modules/ftdi_sio.ko
```

## 板端加载与验证

```sh
insmod /data/apps/drivers/modules/usbserial.ko
insmod /data/apps/drivers/modules/ftdi_sio.ko
cat /proc/modules
ls -l /dev/ttyUSB*
dmesg | tail -40
```

已加载时跳过对应 `insmod`。接入支持的 FTDI 设备后应看到串口绑定日志；节点编号可能改变，按实际 USB 设备确认映射。

