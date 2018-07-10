-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;

use work.debugpoint_load_test_const.all;
use work.global_const.all;
use work.except_const.all;
use work.mmu_const.all;
use work.bus_const.all;
-- CODE BELOW IS AUTOMATICALLY GENERATED

entity debugpoint_load_tb is
end debugpoint_load_tb;

architecture bhv of debugpoint_load_tb is
    signal rst: std_logic := '1';
    signal clk: std_logic := '0';

    signal cpu1Inst_c2d, cpu1Data_c2d: BusC2D;
    signal cpu1Inst_d2c, cpu1Data_d2c: BusD2C;
    signal ram_c2d, flash_c2d, serial_c2d, boot_c2d, eth_c2d, led_c2d, num_c2d: BusC2D;
    signal ram_d2c, flash_d2c, serial_d2c, boot_d2c, eth_d2c, led_d2c, num_d2c: BusD2C;

    signal sync: std_logic_vector(2 downto 0);
    signal scCorrect: std_logic;

    signal int: std_logic_vector(IntWidth);
    signal timerInt: std_logic;
begin
    ram_ist: entity work.debugpoint_load_fake_ram
        port map (
            clk => clk,
            rst => rst,
            cpu_i => ram_c2d,
            cpu_o => ram_d2c
        );

    cpu_ist: entity work.cpu
        generic map (
            instEntranceAddr        => 32ux"8000_0004",
            exceptBootBaseAddr      => 32ux"8000_0000",
            tlbRefillExl0Offset     => 32ux"40",
            generalExceptOffset     => 32ux"40",
            interruptIv1Offset      => 32ux"40",
            convEndianEnable        => true
        )
        port map (
            rst => rst, clk => clk,
            instDev_i => cpu1Inst_d2c,
            dataDev_i => cpu1Data_d2c,
            instDev_o => cpu1Inst_c2d,
            dataDev_o => cpu1Data_c2d,
            int_i => int,
            timerInt_o => timerInt,
            sync_o => sync,
            scCorrect_i => scCorrect
        );
    int <= (0 => timerInt, others => '0');

    devctrl_ist: entity work.devctrl
        port map (
            clk => clk,
            rst => rst,

            cpu1Inst_i => cpu1Inst_c2d,
            cpu1Data_i => cpu1Data_c2d,
            cpu1Inst_o => cpu1Inst_d2c,
            cpu1Data_o => cpu1Data_d2c,

            ddr3_i => ram_d2c,
            flash_i => flash_d2c,
            serial_i => serial_d2c,
            boot_i => boot_d2c,
            eth_i => eth_d2c,
            led_i => led_d2c,
            num_i => num_d2c,
            ddr3_o => ram_c2d,
            flash_o => flash_c2d,
            serial_o => serial_c2d,
            boot_o => boot_c2d,
            eth_o => eth_c2d,
            led_o => led_c2d,
            num_o => num_c2d,

            sync_i => sync,
            scCorrect_o => scCorrect
    );
    flash_d2c.dataLoad <= (others => '0'); flash_d2c.busy <= PIPELINE_STOP;
    serial_d2c.dataLoad <= (others => '0'); serial_d2c.busy <= PIPELINE_STOP;
    boot_d2c.dataLoad <= (others => '0'); boot_d2c.busy <= PIPELINE_STOP;
    eth_d2c.dataLoad <= (others => '0'); eth_d2c.busy <= PIPELINE_STOP;
    led_d2c.dataLoad <= (others => '0'); led_d2c.busy <= PIPELINE_STOP;
    num_d2c.dataLoad <= (others => '0'); num_d2c.busy <= PIPELINE_STOP;

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
alias user_reg is <<signal ^.cpu_ist.datapath_ist.regfile_ist.regArray: RegArrayType>>;
    begin
        -- CODE BELOW IS AUTOMATICALLY GENERATED
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 20 * CLK_PERIOD;
    assert user_reg(3) = 32ux"0100" severity FAILURE;
    wait;
end process;
    end block assertBlk;
end bhv;
