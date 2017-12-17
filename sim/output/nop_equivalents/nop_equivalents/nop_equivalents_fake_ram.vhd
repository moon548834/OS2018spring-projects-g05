-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nop_equivalents_test_const.all;
use work.global_const.all;

entity nop_equivalents_fake_ram is
    port (
        clk, rst: in std_logic;
        enable_i, write_i: in std_logic;
        data_i: in std_logic_vector(DataWidth);
        addr_i: in std_logic_vector(AddrWidth);
        byteSelect_i: in std_logic_vector(3 downto 0);
        data_o: out std_logic_vector(DataWidth)
    );
end nop_equivalents_fake_ram;

architecture bhv of nop_equivalents_fake_ram is
    type WordsArray is array(0 to MAX_RAM_ADDRESS) of std_logic_vector(DataWidth);
    signal words: WordsArray;
    signal wordAddr: integer;
    signal bitSelect: std_logic_vector(DataWidth);
begin
    wordAddr <= to_integer(unsigned(addr_i(31 downto 2)));

    bitSelect <= (
        31 downto 24 => byteSelect_i(3),
        23 downto 16 => byteSelect_i(2),
        15 downto 8 => byteSelect_i(1),
        7 downto 0 => byteSelect_i(0)
    );

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                -- CODE BELOW IS AUTOMATICALLY GENERATED
words(1) <= x"3f_00_00_70"; -- RUN sdbbp
words(2) <= x"20_00_00_42"; -- RUN wait
words(3) <= x"0f_00_00_00"; -- RUN sync
words(4) <= x"00_00_55_bc"; -- RUN cache 0x15, 0($2)
words(5) <= x"3f_00_00_70"; -- RUN sdbbp
words(6) <= x"20_00_00_42"; -- RUN wait
words(7) <= x"0f_00_00_00"; -- RUN sync
words(8) <= x"00_00_50_bc"; -- RUN cache 0x10, 0($2)
words(9) <= x"3f_00_00_70"; -- RUN sdbbp
words(10) <= x"20_00_00_42"; -- RUN wait
words(11) <= x"0f_00_00_00"; -- RUN sync
words(12) <= x"00_00_e7_bd"; -- RUN cache 0x07, 0($15)
words(13) <= x"3f_00_00_70"; -- RUN sdbbp
words(14) <= x"20_00_00_42"; -- RUN wait
words(15) <= x"0f_00_00_00"; -- RUN sync
words(16) <= x"00_00_f0_bf"; -- RUN cache 0x10, 0($31)
words(17) <= x"3f_00_00_70"; -- RUN sdbbp
words(18) <= x"20_00_00_42"; -- RUN wait
words(19) <= x"0f_00_00_00"; -- RUN sync
words(20) <= x"00_00_90_be"; -- RUN cache 0x10, 0($20)
words(21) <= x"3f_00_00_70"; -- RUN sdbbp
words(22) <= x"20_00_00_42"; -- RUN wait
words(23) <= x"0f_00_00_00"; -- RUN sync
words(24) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(25) <= x"3f_00_00_70"; -- RUN sdbbp
words(26) <= x"20_00_00_42"; -- RUN wait
words(27) <= x"0f_00_00_00"; -- RUN sync
words(28) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(29) <= x"3f_00_00_70"; -- RUN sdbbp
words(30) <= x"20_00_00_42"; -- RUN wait
words(31) <= x"0f_00_00_00"; -- RUN sync
words(32) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(33) <= x"3f_00_00_70"; -- RUN sdbbp
words(34) <= x"20_00_00_42"; -- RUN wait
words(35) <= x"0f_00_00_00"; -- RUN sync
words(36) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(37) <= x"3f_00_00_70"; -- RUN sdbbp
words(38) <= x"20_00_00_42"; -- RUN wait
words(39) <= x"0f_00_00_00"; -- RUN sync
words(40) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(41) <= x"3f_00_00_70"; -- RUN sdbbp
words(42) <= x"20_00_00_42"; -- RUN wait
words(43) <= x"0f_00_00_00"; -- RUN sync
words(44) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(45) <= x"3f_00_00_70"; -- RUN sdbbp
words(46) <= x"20_00_00_42"; -- RUN wait
words(47) <= x"0f_00_00_00"; -- RUN sync
words(48) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(49) <= x"3f_00_00_70"; -- RUN sdbbp
words(50) <= x"20_00_00_42"; -- RUN wait
words(51) <= x"0f_00_00_00"; -- RUN sync
words(52) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(53) <= x"3f_00_00_70"; -- RUN sdbbp
words(54) <= x"20_00_00_42"; -- RUN wait
words(55) <= x"0f_00_00_00"; -- RUN sync
words(56) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(57) <= x"3f_00_00_70"; -- RUN sdbbp
words(58) <= x"20_00_00_42"; -- RUN wait
words(59) <= x"0f_00_00_00"; -- RUN sync
words(60) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(61) <= x"3f_00_00_70"; -- RUN sdbbp
words(62) <= x"20_00_00_42"; -- RUN wait
words(63) <= x"0f_00_00_00"; -- RUN sync
words(64) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(65) <= x"3f_00_00_70"; -- RUN sdbbp
words(66) <= x"20_00_00_42"; -- RUN wait
words(67) <= x"0f_00_00_00"; -- RUN sync
words(68) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(69) <= x"3f_00_00_70"; -- RUN sdbbp
words(70) <= x"20_00_00_42"; -- RUN wait
words(71) <= x"0f_00_00_00"; -- RUN sync
words(72) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(73) <= x"3f_00_00_70"; -- RUN sdbbp
words(74) <= x"20_00_00_42"; -- RUN wait
words(75) <= x"0f_00_00_00"; -- RUN sync
words(76) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(77) <= x"3f_00_00_70"; -- RUN sdbbp
words(78) <= x"20_00_00_42"; -- RUN wait
words(79) <= x"0f_00_00_00"; -- RUN sync
words(80) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(81) <= x"3f_00_00_70"; -- RUN sdbbp
words(82) <= x"20_00_00_42"; -- RUN wait
words(83) <= x"0f_00_00_00"; -- RUN sync
words(84) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(85) <= x"3f_00_00_70"; -- RUN sdbbp
words(86) <= x"20_00_00_42"; -- RUN wait
words(87) <= x"0f_00_00_00"; -- RUN sync
words(88) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(89) <= x"3f_00_00_70"; -- RUN sdbbp
words(90) <= x"20_00_00_42"; -- RUN wait
words(91) <= x"0f_00_00_00"; -- RUN sync
words(92) <= x"00_00_30_bf"; -- RUN cache 0x10, 0($25)
words(93) <= x"3f_00_00_70"; -- RUN sdbbp
words(94) <= x"20_00_00_42"; -- RUN wait
words(95) <= x"0f_00_00_00"; -- RUN sync
words(96) <= x"01_00_42_34"; -- RUN ori $2, $2, 0x0001
            elsif ((enable_i = '1') and (write_i = '1')) then
                words(wordAddr) <= (words(wordAddr) and not bitSelect) or (data_i and bitSelect);
            end if;
        end if;
    end process;

    data_o <= words(wordAddr) when (enable_i = '1') and (write_i = '0') else 32b"0";
end bhv;
