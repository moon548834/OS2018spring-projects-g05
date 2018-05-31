-- DO NOT MODIFY THIS FILE.
-- This file is generated by hard_tests_gen

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.debugpoint_w1c_test_const.all;
use work.global_const.all;

entity debugpoint_w1c_fake_ram is
    port (
        clk, rst: in std_logic;
        enable_i, write_i: in std_logic;
        data_i: in std_logic_vector(DataWidth);
        addr_i: in std_logic_vector(AddrWidth);
        byteSelect_i: in std_logic_vector(3 downto 0);
        data_o: out std_logic_vector(DataWidth);
        sync_i: in std_logic_vector(2 downto 0);
        scCorrect_o: out std_logic
    );
end debugpoint_w1c_fake_ram;

architecture bhv of debugpoint_w1c_fake_ram is
    type WordsArray is array(0 to MAX_RAM_ADDRESS) of std_logic_vector(DataWidth);
    signal words: WordsArray;
    signal wordAddr: integer;
    signal bitSelect: std_logic_vector(DataWidth);
    signal llBit: std_logic;
    signal llLoc: std_logic_vector(AddrWidth);
begin
    wordAddr <= to_integer(unsigned(addr_i(12 downto 2)));

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
words(1) <= x"00_80_02_3c"; -- RUN lui $2, 0x8000
words(2) <= x"24_00_42_34"; -- RUN ori $2, $2, 0x0024
words(3) <= x"00_90_82_40"; -- RUN mtc0 $2, $18
words(4) <= x"00_60_80_40"; -- RUN mtc0 $0, $12
words(5) <= x"00_00_00_00"; -- RUN nop
words(6) <= x"00_00_00_00"; -- RUN nop
words(7) <= x"00_00_00_00"; -- RUN nop
words(8) <= x"00_00_00_00"; -- RUN nop
words(9) <= x"00_00_00_00"; -- RUN nop
words(10) <= x"00_00_00_00"; -- RUN nop
words(11) <= x"00_00_00_00"; -- RUN nop
words(12) <= x"00_00_00_00"; -- RUN nop
words(13) <= x"00_00_00_00"; -- RUN nop
words(14) <= x"0c_00_00_08"; -- RUN j 0x30
words(15) <= x"00_00_00_00"; -- RUN nop
words(16) <= x"00_98_03_40"; -- RUN mfc0 $3, $19, 0
words(17) <= x"00_98_83_40"; -- RUN mtc0 $3, $19, 0
words(18) <= x"00_00_00_00"; -- RUN nop
words(19) <= x"00_00_00_00"; -- RUN nop
words(20) <= x"00_98_04_40"; -- RUN mfc0 $4, $19, 0
words(21) <= x"00_00_00_00"; -- RUN nop
words(22) <= x"00_00_00_00"; -- RUN nop
words(23) <= x"00_00_00_00"; -- RUN nop
            elsif ((enable_i = '1') and (write_i = '1')) then
                words(wordAddr) <= (words(wordAddr) and not bitSelect) or (data_i and bitSelect);
            end if;
        end if;
    end process;

    scCorrect_o <= llBit when addr_i = llLoc else '0';

    process(clk) begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                llBit <= '0';
                llLoc <= (others => 'X');
            else
                if (sync_i(0) = '1') then -- LL
                    llBit <= '1';
                    llLoc <= addr_i;
                elsif (sync_i(1) = '1') then -- SC
                    llBit <= '0';
                elsif (addr_i = llLoc) then -- Others
                    llBit <= '0';
                end if;
                if (sync_i(2) = '1') then -- Flush
                    llBit <= '0';
                end if;
            end if;
        end if;
    end process;

    data_o <= words(wordAddr) when (enable_i = '1') and (write_i = '0') else 32b"0";
end bhv;
