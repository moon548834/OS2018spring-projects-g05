-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;

use work.arith3_test_const.all;
use work.global_const.all;
-- CODE BELOW IS AUTOMATICALLY GENERATED

entity arith3_tb is
end arith3_tb;

architecture bhv of arith3_tb is
    component cpu
        port (
            rst, clk: in std_logic;

            instEnable_o: out std_logic;
            instData_i: in std_logic_vector(DataWidth);
            instAddr_o: out std_logic_vector(AddrWidth);

            dataEnable_o: out std_logic;
            dataWrite_o: out std_logic;
            dataData_i: in std_logic_vector(DataWidth);
            dataData_o: out std_logic_vector(DataWidth);
            dataAddr_o: out std_logic_vector(AddrWidth);
            dataByteSelect_o: out std_logic_vector(3 downto 0);

            int_i: in std_logic_vector(intWidth);
            timerInt_o: out std_logic
        );
    end component;

    component arith3_fake_ram is
        generic (
            isInst: boolean := false -- The RAM will be initialized with instructions when true
        );
        port (
            enable_i, write_i, clk: in std_logic;
            data_i: in std_logic_vector(DataWidth);
            addr_i: in std_logic_vector(AddrWidth);
            byteSelect_i: in std_logic_vector(3 downto 0);
            data_o: out std_logic_vector(DataWidth)
        );
    end component;

    signal rst: std_logic := '1';
    signal clk: std_logic := '0';

    signal instEnable: std_logic;
    signal instData: std_logic_vector(DataWidth);
    signal instAddr: std_logic_vector(AddrWidth);

    signal dataEnable: std_logic;
    signal dataWrite: std_logic;
    signal dataDataSave: std_logic_vector(DataWidth);
    signal dataDataLoad: std_logic_vector(DataWidth);
    signal dataAddr: std_logic_vector(AddrWidth);
    signal dataByteSelect: std_logic_vector(3 downto 0);

    signal int: std_logic_vector(IntWidth);
    signal timerInt: std_logic;
begin
    inst_ram: arith3_fake_ram
        generic map (
            isInst => true
        )
        port map (
            enable_i => instEnable,
            write_i => '0',
            clk => clk,
            data_i => 32b"0",
            addr_i => instAddr,
            byteSelect_i => "1111",
            data_o => instData
        );

    data_ram: arith3_fake_ram
        port map (
            enable_i =>dataEnable,
            write_i => dataWrite,
            clk => clk,
            data_i => dataDataSave,
            addr_i => dataAddr,
            byteSelect_i => dataByteSelect,
            data_o => dataDataLoad
        );

    cpu_inst: cpu
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
            int_i => int,
            timerInt_o => timerInt
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
    wait for 6 * CLK_PERIOD;
    assert user_reg(2) = 32ux"0" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 7 * CLK_PERIOD;
    assert user_reg(2) = 32ux"1" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 11 * CLK_PERIOD;
    assert user_reg(2) = 32ux"1" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 12 * CLK_PERIOD;
    assert user_reg(2) = 32ux"0" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 13 * CLK_PERIOD;
    assert user_reg(2) = 32ux"0" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 14 * CLK_PERIOD;
    assert user_reg(2) = 32ux"0" severity FAILURE;
    wait;
end process;
    end block assertBlk;
end bhv;
