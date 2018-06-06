VMS = https://developer.microsoft.com/en-us/microsoft-edge/api/tools/vms/
FMT = vmdk
NICE = nice -n 19 ionice -c 3

all: vms.json

vms.json:
	curl -fsSL -z $@ -o $@ $(VMS)

QEMU =  @echo 'user credentials are IEUser / Passw0rd!'; \
	env TMPDIR=$$$$(pwd) QEMU_AUDIO_DRV=none nice -n 5 qemu-system-x86_64 \
		-machine type=q35,accel=kvm:tcg \
		-m 2G -mem-prealloc \
		-smp 4,sockets=1,cores=2,threads=2 \
		-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
		-rtc clock=host,base=localtime \
		-nodefaults -serial none -parallel none \
		-usbdevice tablet \
		-soundhw hda \
		-drive file=$(1).qcow2,snapshot=on,cache=writethrough,if=none,l2-cache-size=8M,aio=native,cache.direct=on,id=disk \
		-device ich9-ahci,id=ahci \
		-device ide-drive,drive=disk,bus=ahci.0 \
		$(2) \
		-net nic,model=e1000 -net user \
		-vga qxl \
		-boot c

COMMA = ,
define BROWSER_template
ifeq ($(wildname $(1).qcow2),)
$(1).zip $(1).md5.txt:: TIMECOND = -z $(1).qcow2
endif

$(1).md5.txt:
	curl -fL $(TIMECOND) -o $$@ $(3)

$(1).zip:
	curl -fL $(TIMECOND) -o $$@ $(4)

$(1): $(1).qcow2
	@echo "running '$(2)'"
ifeq ($(1),msedge)
	$(call QEMU,$(1),-drive file=/usr/share/OVMF/OVMF_CODE.fd$(COMMA)if=pflash$(COMMA)readonly -drive file=/usr/share/OVMF/OVMF_VARS.fd$(COMMA)if=pflash$(COMMA)readonly)
else
	$(call QEMU,$(1))
endif
endef

BROWSERS = $(shell cat vms.json | jq -r 'map(.name | split(" ") | .[0]) | reverse | unique | @tsv' | tr A-Z a-z)
$(foreach b, $(BROWSERS), \
	$(eval s = $(shell cat vms.json | jq -r 'map(select(.name | test("^$(b)"; "i")))[-1]')) \
	$(eval f = $(shell echo '$(s)' | jq -r '.software[] | select(.name == "Vagrant") | .files[] | select(.name | test("\\.zip$$"))')) \
	$(eval n = $(shell echo '$(s)' | jq -r '.name')) \
	$(eval m = $(shell echo '$(f)' | jq -r '.md5')) \
	$(eval u = $(shell echo '$(f)' | jq -r '.url')) \
	$(eval $(call BROWSER_template,$(b),$(n),$(m),$(u))) \
)

%.$(FMT): %.md5.txt %.zip
	test $$(cat $*.md5.txt | tr A-F a-f) = $$($(NICE) md5sum $*.zip | cut -b 1-32)
	$(NICE) unzip -p $*.zip '*.box' \
		| $(NICE) tar zxO --wildcards '*.$(FMT)' \
		| $(NICE) cp --sparse=always /dev/stdin $@

%.qcow2: %.$(FMT)
	$(NICE) qemu-img convert -f $(FMT) -O qcow2 -o lazy_refcounts=on -t writethrough -c -p $< $@

.DELETE_ON_ERROR:
