BOARD="MachXO2"
DEVICE="LCMXO2-2000HC"
PKG="TQFP100"
GRADE=6

ifndef $(DIAMOND_VER)
	DIAMOND_VER=3.12
endif

SEARCH="/usr/local/diamond/$(DIAMOND_VER)/ispfpga/vhdl/data/"
BUILD= ./build/
SRC= ./src/
CFG= ./cfg/

ALL: $(BUILD)remoteremote.bit

$(BUILD)%.edi : $(SRC)top.vhd 
	@echo "Lattice Diamond Version being used:" $(DIAMOND_VER)
	@mkdir -p $(BUILD) && cp $(CFG)$*.prj $(BUILD)
	@ln -sf /usr/local/diamond/$(DIAMOND_VER)/cae_library $(BUILD)/cae_library
	@/usr/local/diamond/3.12/bin/lin64/synpwrap -prj $(BUILD)$*.prj >$(BUILD)$*.synpwrap.out \
	    || ( $(CFG)/cc.sh srr $(BUILD)$*.srr && false )
	@echo "--- premap"
	@ $(CFG)/cc.sh srr $(BUILD)synlog/$*_premap.srr
	@echo "--- fpga_mapper"
	@ $(CFG)/cc.sh srr $(BUILD)synlog/$*_fpga_mapper.srr
	@echo "--- synpwrap"
	@ $(CFG)/cc.sh synpwrap $(BUILD)$*.synpwrap.out

$(BUILD)%.ngo : $(BUILD)%.edi
	@echo "### running edif2ngd ..."
	@edif2ngd -l $(BOARD) -d $(DEVICE) $< $@ \
	    | tee $(BUILD)$*.edif2ngd.out | $(CFG)/cc.sh edif2ngd

$(BUILD)%.ngd : $(BUILD)%.ngo
	@echo "### running ngdbuild ..."
	@ngdbuild -a $(BOARD) -d $(DEVICE) -p $(SEARCH) $< $@ \
	    | tee $(BUILD)$*.ngdbuild.out | $(CFG)/cc.sh ngdbuild

$(BUILD)%.ncd : $(BUILD)%.ngd $(SRC)%.lpf
	@echo "### running map ..."
	@cp $(SRC)$*.lpf $(BUILD)
	@map -a $(BOARD) -p $(DEVICE) -t $(PKG) -s $(GRADE) $< -o $@ \
	    | tee $(BUILD)$*.map.out | $(CFG)/cc.sh map
	@ncdread $@ -o $@.asc \
	    | $(CFG)/cc.sh ncdread
	@$(CFG)/cc.sh mrp $(BUILD)$*.mrp

$(BUILD)%.o.ncd : $(BUILD)%.ncd
	@echo "### running par ..."
	@par -w $< $(BUILD)$*.o.ncd $(BUILD)$*.prf \
	    | tee $(BUILD)$*.par.out | $(CFG)/cc.sh par
	@ncdread $@ -o $@.asc \
	    | $(CFG)/cc.sh ncdread

$(BUILD)%.bit : $(BUILD)%.o.ncd
	@echo "### running bitgen ..."
	@bitgen -g RamCfg:Reset -w $< $@ \
	    | tee $(BUILD)$*.bitgen.out | $(CFG)/cc.sh bitgen
	@echo "--------------------Lattice MachXO2 Build Complete--------------------"

# $(BUILD)%.svf : $(BUILD)%.bit
# 	ddtcmd -oft -svfsingle -revd -op "SRAM Fast Program" -if $< -of $@

clean:
	rm -rf $(BUILD)
	rm -f stdout.log stdout.log.* synlog.tcl synlog.tcl.*
