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

- Raspberry Pi Zero,
- Wandboard Q,
- A10/A20 oLinuXino Lime,
- Orange Pi Zero (Plus),
- NanoPi Neo/Neo2.

## RouterOS (MikroTik) configuration:

Required options to make USB dadget visible by RouterOS (as `lte*` device):

* `VID=12d1`
* `PID=14db`
* `GADGET_2ND_CONFIG=0`
* `GADGET_NET_IFACE_TYPE=ecm`
