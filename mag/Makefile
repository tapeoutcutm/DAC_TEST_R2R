PROJECT_NAME ?= tt_um_mattvenn_r2r_dac_3v3
MAGIC_RC := $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc
TEMPLATE_FILE := tt_analog_1x2_3v3.def

.PHONY: lvs magic start clean drc antenna update_gds

magic:
	magic -rcfile $(MAGIC_RC) $(PROJECT_NAME).mag

tt_analog_1x2.def:
	wget https://raw.githubusercontent.com/TinyTapeout/tt-support-tools/tt08/def/analog/tt_analog_1x2.def

tt_analog_1x2_3v3.def:
	wget https://raw.githubusercontent.com/TinyTapeout/tt-support-tools/tt08/def/analog/tt_analog_1x2_3v3.def

start: $(TEMPLATE_FILE)
	magic -rcfile $(MAGIC_RC) -noconsole -dnull tcl/tt-analog-draw.tcl $(TEMPLATE_FILE) $(PROJECT_NAME)

# --- Extraction for LVS ---
$(PROJECT_NAME).lvs.spice: $(PROJECT_NAME).mag
	magic -rcfile $(MAGIC_RC) -noconsole -dnull <<EOF
	load $(PROJECT_NAME)
	extract all
	ext2spice lvs
	quit
EOF
	rm -f *.ext

# --- LVS ---
lvs.report: $(PROJECT_NAME).lvs.spice ../verilog/gl/$(PROJECT_NAME).v
	netgen -batch lvs "$(PROJECT_NAME).lvs.spice $(PROJECT_NAME)" "../verilog/gl/$(PROJECT_NAME).v $(PROJECT_NAME)" $(PDK_ROOT)/sky130A/libs.tech/netgen/sky130A_setup.tcl lvs.report

lvs: lvs.report
	@propOk=1; match=0; port=1; \
	if grep -q "match uniquely" lvs.report; then match=1; fi; \
	if grep -q "Property errors were found" lvs.report; then propOk=0; fi; \
	if grep -q "failed pin matching" lvs.report; then match=0; fi; \
	if grep -q "Final result: Netlists do not match" lvs.report; then match=0; fi; \
	if grep -q "port errors" lvs.report; then port=0; fi; \
	if grep -q "Final result: Circuits match uniquely\." lvs.report; then match=1; fi; \
	if [ $$match -eq 1 ] && [ $$propOk -eq 1 ] && [ $$port -eq 1 ]; then \
	    echo "LVS OK"; exit 0; \
	else \
	    echo "LVS FAIL: match=$$match properties=$$propOk port=$$port"; exit 1; \
	fi

# --- DRC / Antenna ---
antenna:
	magic -rcfile $(MAGIC_RC) -noconsole -dnull tcl/antenna.tcl $(PROJECT_NAME)
	rm -f *.ext

drc:
	magic -rcfile $(MAGIC_RC) -noconsole -dnull tcl/drc.tcl $(PROJECT_NAME)

# --- Simulation Extraction ---
$(PROJECT_NAME).sim.spice: $(PROJECT_NAME).mag
	magic -rcfile $(MAGIC_RC) -noconsole -dnull tcl/extract_for_sim.tcl $(PROJECT_NAME)
	rm -f *.ext

# --- Update GDS ---
update_gds:
	mkdir -p ../gds ../lef
	magic -rcfile $(MAGIC_RC) -noconsole -dnull tcl/update_gds_lef.tcl $(PROJECT_NAME)

clean:
	rm -f lvs.report *.lvs.spice *.nodes *.ext
