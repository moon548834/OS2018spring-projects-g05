library ieee;
use ieee.std_logic_1164.all;
use work.global_const.all;

entity ex_mem is
    port (
        rst, clk: in std_logic;
        stall_i: in std_logic_vector(StallWidth);
        toWriteReg_i: in std_logic;
        writeRegAddr_i: in std_logic_vector(RegAddrWidth);
        writeRegData_i: in std_logic_vector(DataWidth);
        toWriteReg_o: out std_logic;
        writeRegAddr_o: out std_logic_vector(RegAddrWidth);
        writeRegData_o: out std_logic_vector(DataWidth);

        -- Hi Lo --
        toWriteHi_i, toWriteLo_i: in std_logic;
        writeHiData_i, writeLoData_i: in std_logic_vector(DataWidth);
        toWriteHi_o, toWriteLo_o: out std_logic;
        writeHiData_o, writeLoData_o: out std_logic_vector(DataWidth);

        -- multi-period --
        tempProduct_i: in std_logic_vector(DoubleDataWidth);
        cnt_i: in std_logic_vector(CntWidth);
        tempProduct_o: out std_logic_vector(DoubleDataWidth);
        cnt_o: out std_logic_vector(CntWidth)
    );
end ex_mem;

architecture bhv of ex_mem is
begin
    process(clk) begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                toWriteReg_o <= NO;
                writeRegAddr_o <= (others => '0');
                writeRegData_o <= (others => '0');

                toWriteHi_o <= NO;
                toWriteLo_o <= NO;
                writeHiData_o <= (others => '0');
                writeLoData_o <= (others => '0');

                tempProduct_o <= (others => '0');
                cnt_o <= (others => '0');
            elsif (stall_i(EX_STOP_IDX) = PIPELINE_STOP and stall_i(MEM_STOP_IDX) = PIPELINE_NONSTOP) then
                toWriteReg_o <= NO;
                writeRegAddr_o <= (others => '0');
                writeRegData_o <= (others => '0');

                toWriteHi_o <= NO;
                toWriteLo_o <= NO;
                writeHiData_o <= (others => '0');
                writeLoData_o <= (others => '0');

                tempProduct_o <= tempProduct_i;
                cnt_o <= cnt_i;
            elsif (stall_i(EX_STOP_IDX) = PIPELINE_NONSTOP) then
                toWriteReg_o <= toWriteReg_i;
                writeRegAddr_o <= writeRegAddr_i;
                writeRegData_o <= writeRegData_i;

                toWriteHi_o <= toWriteHi_i;
                toWriteLo_o <= toWriteLo_i;
                writeHiData_o <= writeHiData_i;
                writeLoData_o <= writeLoData_i;

                tempProduct_o <= (others => '0');
                cnt_o <= (others => '0');
            end if;
        end if;
    end process;
end bhv;