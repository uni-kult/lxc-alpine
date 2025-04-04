# lxc-alpine


## Setup new LXC

- use template `alpine-3.21-default_20241217_amd64.tar.xz`
- **1GB** SSD on `local-lvm`
- **512MB** RAM
- Network example:
  - IP: `10.200.5.10/24`
  - Gateway: `10.200.5.1`
  - IPv6: `SLAAC`
  - VLAN: `50`
  - DNS Server: `10.200.5.1`
- run:
```sh
wget https://raw.githubusercontent.com/uni-kult/lxc-alpine/refs/heads/main/init.sh && sh init.sh && rm init.sh
```
