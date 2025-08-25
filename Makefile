PROJECT_NAME := r2r_dac_control

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

lvs:
	netgen -batch lvs \
	"openlane/$(PROJECT_NAME)/runs/$(PROJECT_NAME)/results/final/spice/$(PROJECT_NAME).spice $(PROJECT_NAME)" \
	"verilog/gl/$(PROJECT_NAME).v $(PROJECT_NAME)" \
	$$(PDK_ROOT)/sky130A/libs.tech/netgen/sky130A_setup.tcl \
	| tee lvs.log
