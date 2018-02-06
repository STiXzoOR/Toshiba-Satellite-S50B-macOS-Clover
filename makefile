# makefile
#
# Created by the-braveknight, edited by me.
#

BUILDDIR=./Build

IASLOPTS=-vw 2095 -vw 2008
IASL=iasl

RehabMan=$(BUILDDIR)/SSDT-IGPU.aml $(BUILDDIR)/SSDT-HDEF.aml $(BUILDDIR)/SSDT-HDAU.aml $(BUILDDIR)/SSDT-PNLF.aml $(BUILDDIR)/SSDT-XOSI.aml $(BUILDDIR)/SSDT-XCPM.aml $(BUILDDIR)/SSDT-DEHCI.aml
HACK=$(BUILDDIR)/SSDT-HACK.aml

.PHONY: all
all: $(RehabMan) $(HACK)

$(BUILDDIR)/%.aml : Downloads/Hotpatch/%.dsl
	$(IASL) $(IASLOPTS) -p $@ $<
	
$(BUILDDIR)/%.aml : Hotpatch/%.dsl
	$(IASL) $(IASLOPTS) -p $@ $<
	

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.aml
	rm -f AppleHDA_CX20756.kext

.PHONY: install_rehabman
install_rehabman: $(RehabMan)
	$(eval EFIDIR:=$(shell macos-tools/mount_efi.sh))
	cp $(RehabMan) $(EFIDIR)/EFI/CLOVER/ACPI/patched

.PHONY: install
install: $(HACK)
	$(eval EFIDIR:=$(shell macos-tools/mount_efi.sh))
	rm -f $(EFIDIR)/EFI/CLOVER/ACPI/patched/*.aml
	cp $(HACK) $(EFIDIR)/EFI/CLOVER/ACPI/patched
	make install_rehabman