-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.multicore_ipi1_test_const.all;
use work.global_const.all;
use work.bus_const.all;

entity multicore_ipi1_fake_ram is
    port (
        clk, rst: in std_logic;
        cpu_i: in BusC2D;
        cpu_o: out BusD2C
    );
end multicore_ipi1_fake_ram;

architecture bhv of multicore_ipi1_fake_ram is
    type WordsArray is array(0 to MAX_RAM_ADDRESS) of std_logic_vector(DataWidth);
    signal words: WordsArray;
    signal wordAddr: integer;
    signal bitSelect: std_logic_vector(DataWidth);
    signal llBit: std_logic;
    signal llLoc: std_logic_vector(AddrWidth);
begin
    cpu_o.busy <= PIPELINE_NONSTOP;

    wordAddr <= to_integer(unsigned(cpu_i.addr(11 downto 2)));

    bitSelect <= (
        31 downto 24 => cpu_i.byteSelect(3),
        23 downto 16 => cpu_i.byteSelect(2),
        15 downto 8 => cpu_i.byteSelect(1),
        7 downto 0 => cpu_i.byteSelect(0)
    );

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                -- CODE BELOW IS AUTOMATICALLY GENERATED
words(1) <= x"f0_bf_1c_3c"; -- RUN lui $gp, 0xbff0
words(2) <= x"00_10_9c_37"; -- RUN ori $gp, $gp, 0x1000
words(3) <= x"01_40_08_34"; -- RUN ori $t0, $0, 0x4001
words(4) <= x"00_60_88_40"; -- RUN mtc0 $t0, $12
words(5) <= x"01_78_08_40"; -- RUN mfc0 $t0, $15, 1
words(6) <= x"ff_03_08_31"; -- RUN andi $t0, $t0, 0x3ff
words(7) <= x"03_00_00_11"; -- RUN beq $t0, $0, 0x2c-0x20
words(8) <= x"02_00_09_34"; -- RUN ori $t1, $0, 2
words(9) <= x"09_00_00_08"; -- RUN j 0x24
words(10) <= x"00_00_00_00"; -- RUN nop
words(11) <= x"01_00_0a_34"; -- RUN ori $t2, $0, 1
words(12) <= x"28_00_8a_af"; -- RUN sw $t2, 0x28($gp)
words(13) <= x"24_00_8a_af"; -- RUN sw $t2, 0x24($gp)
words(14) <= x"0e_00_00_08"; -- RUN j 0x38
words(15) <= x"00_00_00_00"; -- RUN nop
words(16) <= x"ff_ff_29_21"; -- RUN addi $t1, $t1, -1
words(17) <= x"02_00_20_15"; -- RUN bne $t1, $0, 0x50-0x48
words(18) <= x"01_00_0a_34"; -- RUN ori $t2, $0, 1
words(19) <= x"2c_00_8a_af"; -- RUN sw $t2, 0x2c($gp)
words(20) <= x"18_00_00_42"; -- RUN eret
            elsif ((cpu_i.enable = '1') and (cpu_i.write = '1')) then
                words(wordAddr) <= (words(wordAddr) and not bitSelect) or (cpu_i.dataSave and bitSelect);
            end if;
        end if;
    end process;

    cpu_o.dataLoad <= words(wordAddr) when (cpu_i.enable = '1') and (cpu_i.write = '0') else 32b"0";
end bhv;
