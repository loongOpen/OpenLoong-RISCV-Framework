# 07 SSH 配置与文件传输

[返回首页](../README.md) · [下一步：应用部署](08_交叉编译与应用部署.md)

## 前置条件

HDC 已可用，板端镜像包含 `/system/bin/sshd` 和 `ssh-keygen`。SSH 是用户态服务，本节使用独立主机密钥和公钥认证模板，不依赖原手册中的 root 密码登录配置。

本节手动前台启动，暂不附加 SSH 自启动服务及大范围 capabilities。基础登录验证通过后，管理员再按所用镜像的权限要求配置服务。

## 电脑端传输

先在板端创建 `/data/openssh` 并设为 700。已有配置和授权列表应先备份；以下复制命令用于新配置：

```sh
hdc -t "$TARGET" shell 'mkdir -p /data/openssh; chmod 700 /data/openssh'
hdc -t "$TARGET" file send configs/sshd_config.example /data/openssh/sshd_config
hdc -t "$TARGET" file send scripts/start-sshd.sh /data/openssh/start-sshd.sh
```

准备电脑上的 SSH 公钥（例如 `~/.ssh/id_ed25519.pub`），仅将公钥传到新板。已有 `authorized_keys` 时先取回并合并，不覆盖其他人的授权：

```sh
hdc -t "$TARGET" file send ~/.ssh/id_ed25519.pub /data/openssh/authorized_keys
```

## 板端初始化

仅当该路径没有已有主机密钥时执行生成命令；已有密钥保持不变：

```sh
ssh-keygen -t ed25519 -N '' -f /data/openssh/ssh_host_ed25519_key
chmod 600 /data/openssh/ssh_host_ed25519_key /data/openssh/authorized_keys /data/openssh/sshd_config
chmod 755 /data/openssh/start-sshd.sh
chown -R root:root /data/openssh
/system/bin/sshd -t -f /data/openssh/sshd_config
/system/bin/sshd -T -f /data/openssh/sshd_config
```

检查有效配置：密码和空密码认证关闭、公钥认证开启、主机密钥和授权文件路径正确。配置中的监听地址为所有 IPv4 接口，可按实际管理网络改为板端指定地址。

## 启动与验证

先检查是否已有 sshd 监听 22 端口，避免重复服务。通过 HDC shell 前台启动：

```sh
sh /data/openssh/start-sshd.sh
```

另开电脑终端，设置实际 `DEVICE_IP` 后连接：

```sh
ssh -i ~/.ssh/id_ed25519 root@"$DEVICE_IP"
sftp -i ~/.ssh/id_ed25519 root@"$DEVICE_IP"
```

首次连接应核对板端主机公钥指纹。主机密钥变化时先确认是否重刷或换板，不跳过检查。登录成功后再验证所需操作权限；SSH 会话不一定拥有 HDC 的全部能力。
