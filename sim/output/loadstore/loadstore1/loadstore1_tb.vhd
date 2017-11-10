-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;

use work.loadstore1_test_const.all;
use work.global_const.all;
use work.except_const.all;
use work.mmu_const.all;
-- CODE BELOW IS AUTOMATICALLY GENERATED
use work.alu_const.all;

entity loadstore1_tb is
end loadstore1_tb;

architecture bhv of loadstore1_tb is
    signal rst: std_logic := '1';
    signal clk: std_logic := '0';

    signal instEnable: std_logic;
    signal instData: std_logic_vector(DataWidth);
    signal instAddr: std_logic_vector(AddrWidth);

    signal dataEnable, dataWrite: std_logic;
    signal dataDataSave, dataDataLoad: std_logic_vector(DataWidth);
    signal dataAddr: std_logic_vector(AddrWidth);
    signal dataByteSelect: std_logic_vector(3 downto 0);

    signal devEnable, devWrite: std_logic;
    signal devDataSave, devDataLoad: std_logic_vector(DataWidth);
    signal devVirtualAddr, devPhysicalAddr: std_logic_vector(AddrWidth);
    signal devByteSelect: std_logic_vector(3 downto 0);

    signal instStall, dataStall: std_logic;
    signal instExcept, dataExcept, devExcept: std_logic_vector(ExceptionCauseWidth);

    signal isKernelMode: std_logic;
    signal entryIndex: std_logic_vector(TLBIndexWidth);
    signal entryWrite: std_logic;
    signal entry: TLBEntry;

    signal int: std_logic_vector(IntWidth);
    signal timerInt: std_logic;
begin
    ram_inst: entity work.loadstore1_fake_ram
        port map (
            clk => clk,
            rst => rst,
            enable_i => devEnable,
            write_i => devWrite,
            data_i => devDataSave,
            addr_i => devPhysicalAddr,
            byteSelect_i => devByteSelect,
            data_o => devDataLoad
        );

    mmu_inst: entity work.mmu
        port map (
            clk => clk,
            rst => rst,

            isKernelMode_i => isKernelMode,
            isLoad_i => not devWrite,
            addr_i => devVirtualAddr,
            addr_o => devPhysicalAddr,
            exceptCause_o => devExcept,

            index_i => entryIndex,
            entryWrite_i => entryWrite,
            entry_i => entry
        );

    memctrl_inst: entity work.memctrl
        port map (
            -- Connect to instruction interface of CPU
            instData_o => instData,
            instAddr_i => instAddr,
            instEnable_i => instEnable,
            instStall_o => instStall,
            instExcept_o => instExcept,

            -- Connect to data interface of CPU
            dataEnable_i => dataEnable,
            dataWrite_i => dataWrite,
            dataData_o => dataDataLoad,
            dataData_i => dataDataSave,
            dataAddr_i => dataAddr,
            dataByteSelect_i => dataByteSelect,
            dataStall_o => dataStall,
            dataExcept_o => dataExcept,

            -- Connect to external device (MMU)
            devEnable_o => devEnable,
            devWrite_o => devWrite,
            devData_i => devDataLoad,
            devData_o => devDataSave,
            devAddr_o => devVirtualAddr,
            devByteSelect_o => devByteSelect,
            devBusy_i => PIPELINE_NONSTOP,
            devExcept_i => devExcept
        );

    cpu_inst: entity work.cpu
        generic map (
            instEntranceAddr        => 32ux"8000_0004",
            exceptNormalBaseAddr    => 32ux"8000_0000",
            exceptBootBaseAddr      => 32ux"8000_0000",
            tlbRefillExl0Offset     => 32ux"40",
            generalExceptOffset     => 32ux"40",
            interruptIv1Offset      => 32ux"40",
            instConvEndian          => true
        )
        port map (
            rst => rst,
            clk => clk,
            instEnable_o => instEnable,
            instData_i => instData,
            instAddr_o => instAddr,
            dataEnable_o => dataEnable,
            dataWrite_o => dataWrite,
            dataData_i => dataDataLoad,
            dataData_o => dataDataSave,
            dataAddr_o => dataAddr,
            dataByteSelect_o => dataByteSelect,
            instExcept_i => instExcept,
            dataExcept_i => dataExcept,
            ifToStall_i => instStall,
            memToStall_i => dataStall,
            int_i => int,
            timerInt_o => timerInt,
            isKernelMode_o => isKernelMode,
            entryIndex_o => entryIndex,
            entryWrite_o => entryWrite,
            entry_o => entry
        );

    int <= (0 => timerInt, others => '0');

    process begin
        wait for CLK_PERIOD / 2;
        clk <= not clk;
    end process;

    process begin
        -- begin reset
        wait for CLK_PERIOD;
        rst <= '0';
        wait;
    end process;

    assertBlk: block
        -- NOTE: `assertBlk` is also a layer in the herarchical reference
        -- CODE BELOW IS AUTOMATICALLY GENERATED
alias user_reg is <<signal ^.cpu_inst.regfile_ist.regArray: RegArrayType>>;
    begin
        -- CODE BELOW IS AUTOMATICALLY GENERATED
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 17 * CLK_PERIOD;
    assert user_reg(1) = x"ffffffff" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 19 * CLK_PERIOD;
    assert user_reg(1) = x"000000ee" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 21 * CLK_PERIOD;
    assert user_reg(1) = x"ffeeddcc" severity FAILURE;
    wait;
end process;
    end block assertBlk;
end bhv;
