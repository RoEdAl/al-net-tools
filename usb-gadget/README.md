# usb-gadget

Configures USB OTG port as composite gadget.
There are two USB configurations:
- First configuration is designed for *Linux* hosts and exposes one serial port and one network interface.
  It is possible to login through exposed serial port.
- Second configuration is designed for *Windows* hosts and exposes one RNDIS network interface.

Both network interfaces from first and second configuration are bound to `br-gdg` network bridge.

This is platform-agnostic package ([bash script](usb-gadget.sh)).

## Installation

- Build and install `usb-gadget` package.
  - Optionally install [`usb-gadget-dhcp-server`](50-br-gdg-dhcp-server.network) or
    [`usb-gadget-dhcp-client`](50-br-gdg-dhcp-client.network) package to configure `br-gdg` bridge
    to act as (very simple) DHCP server or DHCP client.
- Reboot.
- Optionally edit [`/etc/conf.d/usb-gadget`](env) configuration file.
- Enable and/or start [`usb-gadget`](usb-gadget.service) service.

## Confirmed to work on:

- Raspberry Pi Zero/4B,
- Wandboard Q,
- A10/A20 oLinuXino Lime,
- Orange Pi Zero (Plus),
- NanoPi Neo/Neo2.

## RouterOS (MikroTik) configuration:

Required configuration to make USB dadget visible by *RouterOS*:

* `VID=12d1`,
* `PID=14db`,
* `GADGET_2ND_CONFIG=0`,
* `GADGET_NET_IFACE_TYPE=ecm`.

USB 12d1:14db = *Huawei E8372*.\
Helpful package: [`usb-gadget-dhcp-server-bare`](50-br-gdg-dhcp-server-bare.network).\
Also consider adding `lte*` device to **LAN** interface list.

See also:

* [MikroTik forum: Raspberry PI Zero and RouterOS, usb interface, lte](https://forum.mikrotik.com/viewtopic.php?t=131188),
* [MikroTik documentation: Manual:Peripherals](https://wiki.mikrotik.com/wiki/Manual:Peripherals).

```
[admin@xxx] > /system resource usb print detail 
 0 device="1-0" vendor="Linux 3.3.5 ehci_hcd" name="RB400 EHCI" serial-number="rb400_usb" vendor-id="0x1d6b" device-id="0x0002" speed="480" ports=1 usb-version=" 2.00" 
 1 device="1-1" vendor="Wandboard" name="Q4" serial-number="20210515075651" vendor-id="0x12d1" device-id="0x14db" speed="480" usb-version=" 2.00" 

[admin@xxx] > /interface lte print detail 
Flags: X - disabled, R - running 
 0  R name="lte1" mtu=1500 mac-address=6E:10:DC:5E:85:CC
```

# Additional information

* [ev3-systemd](https://github.com/ev3dev/ev3-systemd)
* [Raspberry Pi Zero as Multiple USB Gadgets](https://irq5.io/2016/12/22/raspberry-pi-zero-as-multiple-usb-gadgets/)
* Modern USB gadget on Linux & how to integrate it with systemd - [Part 1](https://www.collabora.com/news-and-blog/blog/2019/02/18/modern-usb-gadget-on-linux-and-how-to-integrate-it-with-systemd-part-1/), [Part 2](https://www.collabora.com/news-and-blog/blog/2019/03/27/modern-usb-gadget-on-linux-and-how-to-integrate-it-with-systemd-part-2/)
