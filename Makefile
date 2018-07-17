CURL = curl -fL -C - --retry 3 -o $(2).tmp $(3) $(1) && mv $(2).tmp $(2)

SPICE_SOCK = /run/user/$(shell id -u)/spice.qemuie.sock
QEMU = env TMPDIR=$$(pwd) QEMU_AUDIO_DRV=none nice -n 5 qemu-system-x86_64 \
	-machine type=q35,accel=kvm:tcg \
	-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
	-m 2G \
	-smp 4,sockets=1,cores=2,threads=2 \
	-drive file=$(1).qcow2,snapshot=on,cache=writethrough,if=none,l2-cache-size=8M,aio=native,cache.direct=on,id=disk \
	-drive file=virtio-win.iso,media=cdrom,id=cdrom \
	-device ich9-ahci,id=ahci \
	-device ide-drive,drive=disk,bus=ahci.0 \
	-device intel-iommu \
	-rtc clock=host,base=localtime \
	-nodefaults -serial none -parallel none \
	-soundhw hda \
	-net user -net nic,model=virtio \
	-balloon virtio \
	-device usb-ehci,id=ehci -device usb-tablet,bus=ehci.0 \
	-vga qxl \
	-spice unix,addr=$(SPICE_SOCK),disable-ticketing \
	-chardev spicevmc,id=vdagent,debug=0,name=vdagent \
	-device virtio-serial \
	-device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
	-boot c \
	$(2)

COMMA = ,
define BROWSER_template
$(1).md5.txt:
	$$(call CURL,$(3),$$@,--compressed)

$(1).zip:
	$$(call CURL,$(4),$$@)

.PHONY: $(1)
$(1): $(1).qcow2 virtio-win.iso
	@echo "running '$(2)' (user credentials are IEUser / Passw0rd!)"
ifeq ($(1),msedge)
	$$(call QEMU,$(1),-drive file=/usr/share/OVMF/OVMF_CODE.fd$$(COMMA)if=pflash$$(COMMA)readonly -drive file=/usr/share/OVMF/OVMF_VARS.fd$$(COMMA)if=pflash$$(COMMA)readonly)
else
	$$(call QEMU,$(1))
endif
endef

ifneq ($(wildcard vms.json),)
BROWSERS = $(shell cat vms.json | jq -r 'map(.name | split(" ") | .[0]) | unique | @tsv' | tr A-Z a-z)

.PHONY: all
all: vms.json
	@$(foreach b, $(BROWSERS),printf "  %-18s - %s\\n" $(b) "start vm";)

$(foreach b, $(BROWSERS), \
	$(eval s = $(shell cat vms.json | jq -r 'map(select(.name | test("^$(b)"; "i")))[-1]')) \
	$(eval f = $(shell echo '$(s)' | jq -r '.software[] | select(.name == "Vagrant") | .files[] | select(.name | test("\\.zip$$"))')) \
	$(eval n = $(shell echo '$(s)' | jq -r '.name')) \
	$(eval m = $(shell echo '$(f)' | jq -r '.md5')) \
	$(eval u = $(shell echo '$(f)' | jq -r '.url')) \
	$(eval $(call BROWSER_template,$(b),$(n),$(m),$(u))) \
)
else
.PHONY: $(MAKECMDGOALS)
$(MAKECMDGOALS): vms.json
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) $(MAKECMDGOALS)
endif

vms.json: URL = https://developer.microsoft.com/en-us/microsoft-edge/api/tools/vms/
vms.json:
	$(call CURL,$(URL),$@,--compressed)

virtio-win.iso: URL = https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
virtio-win.iso:
	$(call CURL,$(URL),$@,--compressed)

spice-guest-tools-latest.exe: URL = https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe
spice-guest-tools-latest.exe:
	$(call CURL,$(URL),$@,--compressed)

NICE = nice -n 19 ionice -c 3
FMT = vmdk
%.$(FMT): %.md5.txt %.zip
	test $$(cat $*.md5.txt | tr A-F a-f) = $$($(NICE) md5sum $*.zip | cut -b 1-32)
	$(NICE) unzip -p $*.zip '*.box' \
		| $(NICE) tar zxO --wildcards '*.$(FMT)' \
		| $(NICE) cp --sparse=always /dev/stdin $@.tmp
	mv $@.tmp $@

%.qcow2: %.$(FMT)
	$(NICE) qemu-img convert -f $(FMT) -O qcow2 -o lazy_refcounts=on -t writethrough -c -p $< $@.tmp
	mv $@.tmp $@

.PHONY: spice
spice:
	spicy --uri="spice+unix://$(SPICE_SOCK)"

.PHONY: http
http:
	python -m SimpleHTTPServer || php -S 127.0.0.1:8000 -t .
