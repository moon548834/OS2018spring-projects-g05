-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;

use work.jump2_test_const.all;
use work.global_const.all;
use work.except_const.all;
use work.mmu_const.all;
use work.bus_const.all;
-- CODE BELOW IS AUTOMATICALLY GENERATED
use work.alu_const.all;

entity jump2_tb is
end jump2_tb;

architecture bhv of jump2_tb is
    signal rst: std_logic := '1';
    signal clk: std_logic := '0';

    signal conn: BusInterface;
    signal sync: std_logic_vector(2 downto 0);
    signal scCorrect: std_logic;

    signal int: std_logic_vector(IntWidth);
    signal timerInt: std_logic;
begin
    ram_ist: entity work.jump2_fake_ram
        port map (
            clk => clk,
            rst => rst,
            cpu_io => conn,
            scCorrect_o => scCorrect,
            sync_i => sync
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
            dev_io => conn,
            int_i => int,
            timerInt_o => timerInt,
            sync_o => sync,
            scCorrect_i => scCorrect
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
alias user_reg is <<signal ^.cpu_ist.datapath_ist.regfile_ist.regArray: RegArrayType>>;
    begin
        -- CODE BELOW IS AUTOMATICALLY GENERATED
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 6 * CLK_PERIOD;
    assert user_reg(2) = x"00000004" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 11 * CLK_PERIOD;
    assert user_reg(2) = x"00000000" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 16 * CLK_PERIOD;
    assert user_reg(2) = x"00000000" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 16 * CLK_PERIOD;
    assert user_reg(31) = x"80000018" severity FAILURE;
    wait;
end process;
process begin
    wait for CLK_PERIOD; -- resetting
    wait for 17 * CLK_PERIOD;
    assert user_reg(5) = x"80000020" severity FAILURE;
    wait;
end process;
    end block assertBlk;
end bhv;
