PROJECT_NAME := r2r_dac_control
# needs PDK_ROOT and OPENLANE_ROOT, OPENLANE_IMAGE_NAME set from your environment

harden:
	docker run --rm \
	-v $(OPENLANE_ROOT):/openlane \
	-v $(PDK_ROOT):$(PDK_ROOT) \
	-v $(CURDIR):/work \
	-e PDK_ROOT=$(PDK_ROOT) \
	-e PDK=$(PDK) \
	-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
	$(OPENLANE_IMAGE_NAME) \
	/bin/sh -c "./flow.tcl -overwrite -design /work/openlane/$(PROJECT_NAME) -run_path /work/openlane/$(PROJECT_NAME)/runs -tag $(PROJECT_NAME)"

update_files:
	cp openlane/$(PROJECT_NAME)/runs/$(PROJECT_NAME)/results/final/gds/$(PROJECT_NAME).gds gds
	cp openlane/$(PROJECT_NAME)/runs/$(PROJECT_NAME)/results/final/verilog/gl/$(PROJECT_NAME).v verilog/gl/

# LVS target
lvs:
	cd mag && magic -noconsole -dnull << EOF
	load $(PROJECT_NAME)
	extract all
	ext2spice lvs
	quit
	EOF
	netgen -batch lvs \
		"mag/$(PROJECT_NAME).lvs.spice $(PROJECT_NAME)" \
		"verilog/gl/$(PROJECT_NAME).v $(PROJECT_NAME)" \
		$(PDK_ROOT)/$(PDK)/libs.tech/netgen/sky130A_setup.tcl lvs.report
	grep "Result:" lvs.report || true
