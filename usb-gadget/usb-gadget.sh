#!/bin/bash -e

# command line parameters
command="$1" # "up" or "down"

# UDC
udc_device=$(ls /sys/class/udc)

g="/sys/kernel/config/usb_gadget/${udc_device}-conf"

gadget_up() {
    usb_ver='0x0200' # USB 2.0
    dev_class='2'    # Communications

    attr='0xC0' # Self powered
    pwr='1'     # 2mA

    cfg1='CDC & Serial'
    cfg2='RNDIS'

    ms_vendor_code='0xcd'     # Microsoft
    ms_qw_sign='MSFT100'      # also Microsoft
    ms_compat_id='RNDIS'      # matches Windows RNDIS Drivers
    ms_subcompat_id='5162001' # matches Windows RNDIS 6.0+ Driver

    if [ -d ${g} ]; then
        if [ "$(cat ${g}/UDC)" != "" ]; then
            echo "Gadget is already up."
            exit 1
        fi
        echo 'Cleaning up old directory'
        gadget_down
    fi

    # Create a new gadget

    mkdir ${g}
    echo "${usb_ver}" > ${g}/bcdUSB
    echo "${dev_class}" > ${g}/bDeviceClass

    # Linux Foundation - Multifunction composite gadget
    echo "0x${VID:-1d6b}" > ${g}/idVendor
    echo "0x${PID:-0104}" > ${g}/idProduct
    echo "0x${DEVICE_RELEASE:-0100}" > ${g}/bcdDevice
    mkdir ${g}/strings/0x409
    echo "${MANUFACTURER:-Unknown manufacturer}" > ${g}/strings/0x409/manufacturer
    echo "${PRODUCT:-Unknown USB gadget}" > ${g}/strings/0x409/product
    echo "${SERIAL:-fedcba9876543210}" > ${g}/strings/0x409/serialnumber

    # function - serial
    if [ ${GADGET_SERIAL:-0} -eq 1 ]; then
        mkdir ${g}/functions/acm.usb0
    fi

    # function - network - Linux
    mkdir ${g}/functions/${GADGET_NET_IFACE_TYPE:-ncm}.usb0
    echo "${GDG1_HOST_ADDR:-6e:10:dc:5e:85:cc}" > ${g}/functions/${GADGET_NET_IFACE_TYPE:-ncm}.usb0/host_addr

    # function - network - RNDIS (Windows)
    if [ ${GADGET_2ND_CONFIG:-1} -eq 1 ]; then
        mkdir ${g}/functions/rndis.usb0
        echo "${GDG2_HOST_ADDR:-02:3e:9e:20:61:45}" > ${g}/functions/rndis.usb0/host_addr
        echo "${ms_compat_id}" > ${g}/functions/rndis.usb0/os_desc/interface.rndis/compatible_id
        echo "${ms_subcompat_id}" > ${g}/functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id
    fi

    # config 1
    mkdir ${g}/configs/c.1
    echo "${attr}" > ${g}/configs/c.1/bmAttributes
    echo "${pwr}" > ${g}/configs/c.1/MaxPower
    mkdir ${g}/configs/c.1/strings/0x409
    echo "${cfg1}" > ${g}/configs/c.1/strings/0x409/configuration

    # config 2
    if [ ${GADGET_2ND_CONFIG:-1} -eq 1 ]; then
        mkdir ${g}/configs/c.2
        echo "${attr}" > ${g}/configs/c.2/bmAttributes
        echo "${pwr}" > ${g}/configs/c.2/MaxPower
        mkdir ${g}/configs/c.2/strings/0x409
        echo "${cfg2}" > ${g}/configs/c.2/strings/0x409/configuration

        # On Windows 7 and later, the RNDIS 5.1 driver would be used by default,
        # but it does not work very well. The RNDIS 6.0 driver works better. In
        # order to get this driver to load automatically, we have to use a
        # Microsoft-specific extension of USB.

        echo '1' > ${g}/os_desc/use
        echo "${ms_vendor_code}" > ${g}/os_desc/b_vendor_code
        echo "${ms_qw_sign}" > ${g}/os_desc/qw_sign
    fi

    # Link everything
    [ -d ${g}/functions/acm.usb0 ] && ln -s ${g}/functions/acm.usb0 ${g}/configs/c.1
    ln -s ${g}/functions/${GADGET_NET_IFACE_TYPE:-ncm}.usb0 ${g}/configs/c.1
    if [ -d ${g}/configs/c.2 ]; then
        ln -s ${g}/functions/rndis.usb0 ${g}/configs/c.2
        ln -s ${g}/configs/c.2 ${g}/os_desc
    fi

    # Bind USB device    
    echo "${udc_device}" > ${g}/UDC
}

gadget_down() {
    if [ ! -d ${g} ]; then
        echo "Gadget is already down."
        exit 1
    fi

    # Have to unlink and remove directories in reverse order.
    # Checks allow to finish takedown after error.

    if [ "$(cat ${g}/UDC)" != "" ]; then
        echo '' > ${g}/UDC
    fi

    [ -d ${g}/configs/c.1  ] && find ${g}/configs/c.1 -maxdepth 1 -name *.usb0 -type l -exec rm -f {} +

    if [ -d ${g}/os_desc/c.2 ]; then
        rm -f ${g}/os_desc/c.2
	find ${g}/configs/c.2 -maxdepth 1 -name *.usb0 -type l -exec rm -f {} +
    fi

    find ${g}/functions -maxdepth 1 -name *.usb0 -type d -exec rmdir {} +

    [ -d ${g}/configs/c.2/strings/0x409 ] && rmdir ${g}/configs/c.2/strings/0x409
    [ -d ${g}/configs/c.2 ] && rmdir ${g}/configs/c.2

    [ -d ${g}/configs/c.1/strings/0x409 ] && rmdir ${g}/configs/c.1/strings/0x409
    [ -d ${g}/configs/c.1 ] && rmdir ${g}/configs/c.1

    [ -d ${g}/strings/0x409 ] && rmdir ${g}/strings/0x409

    rmdir ${g}
}

case ${command} in

up)
    gadget_up
    ;;
down)
    gadget_down
    ;;
*)
    echo "Usage: usb-gadget.sh up|down"
    exit 1
    ;;
esac

