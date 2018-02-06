# Arch Linux - Network Tools

## `usb-gadget`

Configures USB OTG port as composite gadget. There are two configurations.
First configuration is designed for Windows hosts and exposes one RNDIS network interface.
Second configuration is designed for Linux hosts and exposes one serial port and one network interface.

Both network interfaces from first and second configuration are bound to `br-gdg` network bridge.

This is platform-agnostic package ([bash script](usb-gadget/usb-gadget.sh)).

### Installation

- Build and install `usb-gadget` package.
- Reboot.
- Optionally edit [`/etc/conf.d/usb-gadget`](usb-gadget/env) configuration file.
- Optionally install [`usb-gadget-dhcp-server`](usb-gadget/50-br-gdg-dhcp-server.network) or
  [`usb-gadget-dhcp-client`](usb-gadget/50-br-gdg-dhcp-client.network) package to configure `br-gdg` bridge
  to act as (very simple) DHCP server or DHCP client.
- Start and/or enable [`usb-gadget`](usb-gadget/usb-gadget.service) service.

### Confirmed to work on:

- Raspberry Pi Zero,
- Wandboard Q,
- A10/A20 oLinuXino Lime,
- Orange Pi Zero (Plus),
- NanoPi Neo/Neo2.

## `mirror-port`

Installs `mirror-port@` service template which to mirror trafic from specific network interface.
Destination network interface is specified in configuration file.
By default destination interface is defined as `br-mrr` bridge (also installed by `mirror-port` package).

This is platform-agnostic package ([bash script](mirror-port/mirror-port.sh)).

### Installation

- Build and install `mirror-port` package.
- Reboot.
- Optionally edit [`/etc/conf.d/mirror-port`](mirror-port/env)
  configuration file to specify destination network infterface.
- Start and/or enable [`mirror-port@iface`](mirror-port/mirror-port@.service) service
  where `iface` is a network interface you want to mirror traffic from. For example:
  `systemctl start mirror-port@eth0`
- Watch mirrored packets on destination network interface: `tcpdump -e -v -n -i br-mrr`
