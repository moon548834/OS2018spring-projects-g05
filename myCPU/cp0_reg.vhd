library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- NOTE: std_logic_unsigned cannot be used at the same time with std_logic_signed
--       Use numeric_std if signed number is needed (different API)
use work.global_const.all;
use work.except_const.all;
use work.cp0_const.all;

entity cp0_reg is
    generic (
        cpuId: std_logic_vector(9 downto 0)
    );
    port (
        rst, clk: in std_logic;

        we_i: in std_logic;
        waddr_i: in std_logic_vector(CP0RegAddrWidth);
        raddr_i: in std_logic_vector(CP0RegAddrWidth);
        wsel_i: in std_logic_vector(SelWidth);
        rsel_i: in std_logic_vector(SelWidth);
        data_i: in std_logic_vector(DataWidth);
        int_i: in std_logic_vector(IntWidth);
        data_o: out std_logic_vector(DataWidth);
        status_o: out std_logic_vector(DataWidth);
        cause_o: out std_logic_vector(DataWidth);
        epc_o: out std_logic_vector(DataWidth);

        -- for exception --
        -- These run in MEM stage
        valid_i: in std_logic;
        exceptCause_i: in std_logic_vector(ExceptionCauseWidth);
        currentInstAddr_i, currentAccessAddr_i: in std_logic_vector(AddrWidth);
        memDataWrite_i: in std_logic;
        isIndelaySlot_i: in std_logic;
        exceptCause_o: out std_logic_vector(ExceptionCauseWidth);

        -- Connect ctrl, for address error after eret instruction
        ctrlBadVAddr_i: in std_logic_vector(DataWidth);
        ctrlToWriteBadVAddr_i: in std_logic;

        -- Connect ctrl, for ExceptNormalBaseAddress modification
        cp0EBaseAddr_o: out std_logic_vector(DataWidth)
    );
end cp0_reg;

architecture bhv of cp0_reg is
    type RegArray is array (0 to CP0_MAX_ID) of std_logic_vector(DataWidth);
    signal regArr, curArr: RegArray;
    -- curArr including the data that will be written to regArr in the next period
    signal exceptCause: std_logic_vector(ExceptionCauseWidth);
    signal currentInstAddr, currentAccessAddr, ctrlBadVAddr: std_logic_vector(AddrWidth);
    signal isIndelaySlot: std_logic;
begin
    status_o <= curArr(STATUS_REG);
    cause_o <= curArr(CAUSE_REG);
    epc_o <= curArr(EPC_REG);

    data_o <= PRID_CONSTANT when (conv_integer(raddr_i) = PRID_OR_EBASE_REG and rsel_i = "000") else
              curArr(PRID_OR_EBASE_REG) when (conv_integer(raddr_i) = PRID_OR_EBASE_REG and rsel_i = "001") else
              curArr(conv_integer(raddr_i)) when (rsel_i = "000" and conv_integer(raddr_i) /= PRID_OR_EBASE_REG) else
              32ux"0";

    -- we can still do this because PRID is a preset constant --
    cp0EBaseAddr_o <= curArr(PRID_OR_EBASE_REG);

    process (all) begin
        -- write to cp0 --
        for i in 0 to CP0_MAX_ID loop
            curArr(i) <= regArr(i);
        end loop;
        if (rst = RST_DISABLE and we_i = ENABLE) then
            case (conv_integer(waddr_i)) is
                when CAUSE_REG =>
                    curArr(CAUSE_REG)(CauseIpSoftBits) <= data_i(CauseIpSoftBits);
                    curArr(CAUSE_REG)(CAUSE_IV_BIT) <= data_i(CAUSE_IV_BIT);
                    if (data_i(CAUSE_WP_BIT) = '0') then -- we cannot write 1 when it's 0
                        curArr(CAUSE_REG)(CAUSE_WP_BIT) <= data_i(CAUSE_WP_BIT);
                    end if;
                when PRID_OR_EBASE_REG =>
                    -- PRID is not writable, but ebase is --
                    if (wsel_i = "001") then
                        curArr(PRID_OR_EBASE_REG)(EbaseAddrBits) <= data_i(EbaseAddrBits);
                    end if;
                when others =>
                    curArr(conv_integer(waddr_i)) <= data_i;
            end case;
        end if;
    end process;

    exceptCause_o <= exceptCause_i;

    process (clk)
        variable epc: std_logic_vector(AddrWidth);
    begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                -- Please refer to MIPS Vol3 for reset value
                -- Undefined reset value are reset to 0 here for robustness
                regArr(INDEX_REG) <= (others => '0');
                regArr(WIRED_REG) <= (others => '0');
                regArr(BAD_V_ADDR_REG) <= (others => '0');
                regArr(COUNT_REG) <= (others => '0');
                regArr(COMPARE_REG) <= (others => '0');
                regArr(STATUS_REG) <= (
                    STATUS_CP0_BIT => '1', STATUS_BEV_BIT => '1', STATUS_ERL_BIT => '1', StatusImBits => '1', others => '0'
                );
                regArr(CAUSE_REG) <= (others => '0');
                regArr(EPC_REG) <= (others => '0');
                regArr(PRID_OR_EBASE_REG) <= "1000000000000000000000" & cpuId;
                exceptCause <= NO_CAUSE;
            else
                exceptCause <= exceptCause_i;
                currentInstAddr <= currentInstAddr_i;
                currentAccessAddr <= currentAccessAddr_i;
                regArr(CAUSE_REG)(CauseIpHardBits) <= int_i;
                ctrlBadVaddr <= ctrlBadVAddr_i;
                isIndelaySlot <= isIndelaySlot_i;

                regArr(COUNT_REG) <= regArr(COUNT_REG) + 1;

                if (we_i = ENABLE) then
                    regArr(conv_integer(waddr_i)) <= curArr(conv_integer(waddr_i));
                    -- We only assign the `waddr_i`-th register, in order not to interfere the counters above
                end if;

                if (ctrlToWriteBadVAddr_i = YES) then
                    regArr(BAD_V_ADDR_REG) <= ctrlBadVAddr_i;
                    regArr(STATUS_REG)(STATUS_EXL_BIT) <= '1';
                    if (isIndelaySlot_i = YES) then
                        if exceptCause /= ERET_CAUSE then
                            regArr(EPC_REG) <= currentInstAddr - 4;
                        end if;
                        regArr(CAUSE_REG)(CAUSE_BD_BIT) <= '1';
                    else
                        if exceptCause /= ERET_CAUSE then
                            regArr(EPC_REG) <= currentInstAddr;
                        end if;
                        regArr(CAUSE_REG)(CAUSE_BD_BIT) <= '0';
                    end if;
                    regArr(CAUSE_REG)(CauseExcCodeBits) <= ADDR_ERR_LOAD_OR_IF_CAUSE;
                end if;

                if ((exceptCause /= NO_CAUSE) and (exceptCause /= ERET_CAUSE)) then
                    --if (curArr(STATUS_REG)(STATUS_EXL_BIT) = '0') then -- See doc of Status[EXL]
                        -- Here we use `curArr` instead of `regArr`, because this should happen at the same time
                        -- as the interrupt enabled
                        if (isIndelaySlot = YES) then
                            epc := currentInstAddr - 4;
                            regArr(CAUSE_REG)(CAUSE_BD_BIT) <= '1';
                        else
                            epc := currentInstAddr;
                            regArr(CAUSE_REG)(CAUSE_BD_BIT) <= '0';
                        end if;
                        regArr(EPC_REG) <= epc;
                    --end if;
                    regArr(STATUS_REG)(STATUS_EXL_BIT) <= '1';
                    regArr(CAUSE_REG)(CauseExcCodeBits) <= exceptCause;
                end if;
                case (exceptCause) is
                    when ERET_CAUSE =>
                        if regArr(EPC_REG)(1 downto 0) = "00" then
                            regArr(STATUS_REG)(STATUS_EXL_BIT) <= '0';
                        end if;
                    when ADDR_ERR_STORE_CAUSE =>
                        regArr(BAD_V_ADDR_REG) <= currentAccessAddr;
                    when ADDR_ERR_LOAD_OR_IF_CAUSE =>
                        if currentInstAddr(1 downto 0) /= "00" then
                            regArr(BAD_V_ADDR_REG) <= currentInstAddr;
                        else
                            regArr(BAD_V_ADDR_REG) <= currentAccessAddr;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
end bhv;
