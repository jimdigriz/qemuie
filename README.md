Microsoft IE and Edge VMs for QEMU.

## Related Links

 * [Microsoft - Dev tools for the modern web - Virtual Machines](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
 * [cardi/qemu-windows-10](https://github.com/cardi/qemu-windows-10)

# Preflight

 * coreutils (for `nice`) and `util-linux` (for `ionice`)
 * [cURL](https://curl.haxx.se)
 * [jq](https://stedolan.github.io/jq/)
 * [Make](https://www.gnu.org/software/make/)
 * [OVMF](http://www.tianocore.org)
 * [unzip](http://www.info-zip.org/UnZip.html)
 * [QEMU](https://www.qemu.org)

## Debian

    apt-get -yy install --no-install-recommends \
	coreutils \
    	curl \
    	jq \
    	make \
    	ovmf \
    	unzip \
	util-linux \
    	qemu-kvm \
    	qemu-system-x86 \
    	qemu-utils

# Usage

    make msedge

Available targets are:

 * `ie{8,9,10,11}`: Internet Explorer
 * `msedge`: Edge
