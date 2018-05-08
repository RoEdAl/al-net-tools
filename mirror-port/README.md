# mirror-port

Installs `mirror-port@` service template which mirrors trafic from specific network interface.
Destination network interface is specified in configuration file.
By default destination interface is defined as `br-mrr` bridge (also installed by `mirror-port` package).

This is platform-agnostic package ([bash script](mirror-port/mirror-port.sh)).

## Installation

- Build and install `mirror-port` package.
- Reboot.
- Optionally edit [`/etc/conf.d/mirror-port`](mirror-port/env)
  configuration file to specify destination network infterface.
  (Instead of `/etc/conf.d/mirror-port` you can edit interface-specific configuration file
  `/etc/conf.d/mirror-port-<iface>`).
  Alternatively you can bind another network interface to `br-mrr` bridge.
- Start and/or enable [`mirror-port@iface`](mirror-port/mirror-port@.service) service
  where `iface` is a network interface you want to mirror traffic from. For example:
  `systemctl start mirror-port@eth0`.
- Watch mirrored packets on destination network interface: `tcpdump -e -v -n -i br-mrr`.

----

**Tip**: In order to  mirror traffic from e.g. `br-gdg` interface use `systemd-escape` tool:

````
systemctl start mirror-port@$(systemd-escape br-gdg)
````
