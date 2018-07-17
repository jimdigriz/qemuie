Microsoft IE and Edge VMs for QEMU.

## Related Links

 * [modern.IE](http://modern.ie)
     * [Microsoft Development Virtual Machines](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
 * Windows on QEMU
     * [cardi/qemu-windows-10](https://github.com/cardi/qemu-windows-10)
     * [QEMU + Windows 10 x64 + KVM + IOMMU + AHCI + QXL & SPICE (as socket)](https://gist.github.com/francoism90/bff2630d8eb568d6f790)

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

**N.B.** for Windows 10 you should 'Pause updates' otherwise the guest will spend its time at 100% cpu downloading updates for a VM destined for destruction.

You should also download and install the [Windows Guest Tools](https://www.spice-space.org/download.html#windows-binaries) (you can call `make spice-guest-tools-latest.exe` to do this for you).

Other available targets can be found with `all` like so:

    make -f /path/to/qemuie/Makefile
    VMs:
      ie10                           - start ie10
      ie11                           - start ie11
      ie8                            - start ie8
      ie9                            - start ie9
      msedge                         - start msedge
    
    Misc:
      help                           - this message
      spice                          - connect via SPICE client
      http                           - serve the local directory via http://0.0.0.0:8000 (requires Python or PHP)
      spice-guest-tools-latest.exe   - download spice-guest-tools-latest.exe
