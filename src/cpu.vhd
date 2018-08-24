library ieee;
use ieee.std_logic_1164.all;
use work.global_const.all;
use work.except_const.all;
use work.mmu_const.all;
use work.bus_const.all;
use work.ddr3_const.all;

entity cpu is
    generic (
        extraCmd: boolean := true;
        instEntranceAddr: std_logic_vector(AddrWidth) := 32ux"bfc0_0000";
        exceptBootBaseAddr: std_logic_vector(AddrWidth) := 32ux"bfc0_0200";
        tlbRefillExl0Offset: std_logic_vector(AddrWidth) := 32ux"000";
        generalExceptOffset: std_logic_vector(AddrWidth) := 32ux"180";
        interruptIv1Offset: std_logic_vector(AddrWidth) := 32ux"200";
        convEndianEnable: boolean := false;
        cpuId: std_logic_vector(9 downto 0) := 10ub"0";
        enableCache: std_logic := YES;
        scStallPeriods: integer := 0
    );
    port (
        clk, rst: in std_logic;

        instEnable_o: out std_logic;
        instAddr_o: out std_logic_vector(AddrWidth);
        instRequestAck_i: in std_logic;
        instEnable_i: in std_logic;
        instData_i: in std_logic_vector(DataWidth);
        instAddr_i: in std_logic_vector(AddrWidth);

        dataArenable_o: out std_logic;
        dataAraddr_o: out std_logic_vector(AddrWidth);
        dataArrequestAck_i: in std_logic;
        dataAwenable_o: out std_logic;
        dataAwaddr_o: out std_logic_vector(AddrWidth);
        dataAwdata_o: out std_logic_vector(DataWidth);
        dataAwbyteSelect_o: out std_logic_vector(3 downto 0);
        dataAwrequestAck_i: in std_logic;
        dataEnable_i: in std_logic;
        dataData_i: in std_logic_vector(DataWidth);
        dataAddr_i: in std_logic_vector(AddrWidth);
        dataSingleByte_o: out std_logic;

        int: in std_logic_vector(IntWidth);
        debug_wb_pc: out std_logic_vector(AddrWidth);
        debug_wb_rf_wen: out std_logic_vector(3 downto 0);
        debug_wb_rf_wnum: out std_logic_vector(CP0RegAddrWidth);
        debug_wb_rf_wdata: out std_logic_vector(DataWidth)
    );
end cpu;

architecture bhv of cpu is

    signal instEnable: std_logic;
    signal instData: std_logic_vector(DataWidth);
    signal instVAddr: std_logic_vector(AddrWidth);
    signal instExcept: std_logic_vector(ExceptionCauseWidth);
    signal instTlbRefill: std_logic;

    signal dataEnable, dataWrite: std_logic;
    signal dataDataSave: std_logic_vector(DataWidth);
    signal dataDataLoad: std_logic_vector(DataWidth);
    signal dataVAddr: std_logic_vector(AddrWidth);
    signal dataTlbRefill: std_logic;
    signal debug_wb_rf_wen_ref: std_logic;
    signal data_sram_wen_ref: std_logic;
    signal instDataWrite: std_logic_vector(DataWidth);
    signal instByteSelect: std_logic_vector(3 downto 0);
    signal dataByteSelect: std_logic_vector(3 downto 0);

    signal instCache_d2c, dataCache_d2c: BusD2C;
    signal instCache_c2d, dataCache_c2d: BusC2D;

begin
    inst_cache: entity work.inst_cache
        port map (
            clk => clk, rst => rst,
            req_i => instCache_c2d,
            res_o => instCache_d2c,

            enable_o => instEnable_o,
            addr_o => instAddr_o,
            requestAck_i => instRequestAck_i,
            enable_i => instEnable_i,
            data_i => instData_i,
            addr_i => instAddr_i
        );
    data_cache: entity work.data_cache
        port map (
            clk => clk, rst => rst,
            req_i => dataCache_c2d,
            res_o => dataCache_d2c,

            arenable_o => dataArenable_o,
            araddr_o => dataAraddr_o,
            arrequestAck_i => dataArrequestAck_i,
            awenable_o => dataAwenable_o,
            awaddr_o => dataAwaddr_o,
            awdata_o => dataAwdata_o,
            awbyteSelect_o => dataAwbyteSelect_o,
            awrequestAck_i => dataAwrequestAck_i,
            enable_i => dataEnable_i,
            data_i => dataData_i,
            addr_i => dataAddr_i,
            singleByte_o => dataSingleByte_o
        );

    instCache_c2d.dataSave <= (others => '0');
    conv_endian_inst_load: entity work.conv_endian
        generic map (enable => convEndianEnable)
        port map (input => instCache_d2c.dataLoad, output => instData);
    conv_endian_data_save: entity work.conv_endian
        generic map (enable => convEndianEnable)
        port map (input => dataDataSave, output => dataCache_c2d.dataSave);
    conv_endian_data_load: entity work.conv_endian
        generic map (enable => convEndianEnable)
        port map (input => dataCache_d2c.dataLoad, output => dataDataLoad);

    instCache_c2d.byteSelect <= "1111";
    process (all) begin
        if (convEndianEnable) then
            dataCache_c2d.byteSelect <= dataByteSelect(0) & dataByteSelect(1) & dataByteSelect(2) & dataByteSelect(3);
        else
            dataCache_c2d.byteSelect <= dataByteSelect;
        end if;
    end process;

    instCache_c2d.write <= NO;
    debug_wb_rf_wen <= (0 => debug_wb_rf_wen_ref, 1 => debug_wb_rf_wen_ref, 2 => debug_wb_rf_wen_ref, 3 => debug_wb_rf_wen_ref);

    datapath_ist: entity work.datapath
        generic map (
            extraCmd                => extraCmd,
            instEntranceAddr        => instEntranceAddr,
            exceptBootBaseAddr      => exceptBootBaseAddr,
            tlbRefillExl0Offset     => tlbRefillExl0Offset,
            generalExceptOffset     => generalExceptOffset,
            interruptIv1Offset      => interruptIv1Offset,
            cpuId                   => cpuId,
            scStallPeriods          => scStallPeriods
        )
        port map (
            rst => rst,
            clk => clk,
            instEnable_o => instCache_c2d.enable,
            instData_i => instData,
            instAddr_o => instCache_c2d.addr,
            dataEnable_o => dataCache_c2d.enable,
            dataWrite_o => dataCache_c2d.write,
            dataData_i => dataDataLoad,
            dataData_o => dataDataSave,
            dataAddr_o => dataCache_c2d.addr,
            dataByteSelect_o => dataByteSelect,
            instExcept_i => NO_CAUSE,
            dataExcept_i => NO_CAUSE,
            instTlbRefill_i => NO,
            dataTlbRefill_i => NO,
            ifToStall_i => instCache_d2c.busy,
            memToStall_i => dataCache_d2c.busy,
            int_i => int,
            timerInt_o => open,
            isKernelMode_o => open,
            entryIndex_i => (others => '0'),
            entryIndexValid_i => NO,
            entryIndex_o => open,
            entryWrite_o => open,
            entryFlush_o => open,
            entry_i => (others => (others => '0')),
            entry_o => open,
            pageMask_o => open,
            scCorrect_i => YES,
            sync_o => open,
            debug_wb_pc => debug_wb_pc,
            debug_wb_rf_wdata => debug_wb_rf_wdata,
            debug_wb_rf_wnum => debug_wb_rf_wnum,
            debug_wb_rf_wen_datapath => debug_wb_rf_wen_ref
        );

end bhv;
