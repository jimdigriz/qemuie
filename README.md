Microsoft IE and Edge VMs for QEMU.

## Related Links

 * [modern.IE](http://modern.ie)
     * [Microsoft Development Virtual Machines](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
 * [cardi/qemu-windows-10](https://github.com/cardi/qemu-windows-10)

https://pve.proxmox.com/wiki/Qemu-guest-agent

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
	spice-client-gtk \
    	unzip \
    	util-linux \
    	qemu-kvm \
    	qemu-system-x86 \
    	qemu-utils

# Usage

You should run the following from a mountpoint with a lot of disk space (at least 20GiB):

    make -f /path/to/qemuie/Makefile msedge

In another terminal use the following to get a terminal:

    make -f /path/to/qemuie/Makefile spice

You should open 'Device Manager' and 'Update Driver' by telling Windows to recurse into the directories of starting at `D:\` for all unknown devices as well as the 'Display adapter'.

You should also download and install the [Windows Guest Tools](https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe).

Other available targets can be found with `all` like so:

    make -f /path/to/qemuie/Makefile all
      ie10               - start vm
      ie11               - start vm
      ie8                - start vm
      ie9                - start vm
      msedge             - start vm
