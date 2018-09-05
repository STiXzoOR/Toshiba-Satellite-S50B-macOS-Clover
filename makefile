# makefile
#
# Created by the-braveknight, edited by me.
#

BUILDDIR=./Build

IASL=iasl

HACK=$(BUILDDIR)/SSDT-HACK.aml

.PHONY: all
all: $(HACK)
	
$(BUILDDIR)/%.aml : Hotpatch/%.dsl
	$(IASL) -p $@ $<
	
.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.aml
	rm -f AppleHDA_CX20756.kext

.PHONY: install
install: $(HACK)
	$(eval EFIDIR:=$(shell macos-tools/mount_efi.sh))
	rm -f $(EFIDIR)/EFI/CLOVER/ACPI/patched/*.aml
	cp $(HACK) $(EFIDIR)/EFI/CLOVER/ACPI/patched