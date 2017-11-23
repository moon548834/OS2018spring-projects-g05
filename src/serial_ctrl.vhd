library ieee;
use ieee.std_logic_1164.all;
use work.global_const.all;

entity serial_ctrl is
    port (
        clk, rst: in std_logic;

        enable_i, readEnable_i: in std_logic; -- read enable means write disable
        mode_i: in std_logic; -- 1 for status (0xBFD003FC), 0 for data (0xBFD003F8)
        dataSave_i: in std_logic_vector(DataWidth);
        dataLoad_o: out std_logic_vector(DataWidth);

        int_o: out std_logic; -- Interruption

        rxdReady_i: in std_logic;
        rxdData_i: in std_logic_vector(7 downto 0); -- rxdReady_i and rxdData_i only hold for 1 period
        txdBusy_i: in std_logic;
        txdStart_o: out std_logic;
        txdData_o: out std_logic_vector(7 downto 0)
    );
end serial_ctrl;

architecture bhv of serial_ctrl is
    signal recvAvail: std_logic;
    signal recvData: std_logic_vector(7 downto 0);
begin
    dataLoad_o <=
            (1 => rxdReady_i or recvAvail, 0 => txdBusy_i, others => '0')
        when mode_i = '1' else
            24ux"0" & rxdData_i when rxdReady_i = '1' else 24ux"0" & recvData;
    -- When recvAvail = NO or chip disabled, outputting whatever is OK

    int_o <= recvAvail;
    -- Do NOT use rxdReady_i. If data comes when we are handling an exception,
    -- we must get acknowledged after returing to user mode.

    process (clk) begin
        if (rising_edge(clk)) then
            if (rst = RST_ENABLE) then
                recvAvail <= NO;
                recvData <= (others => '0');
            else
                if (rxdReady_i = '1') then
                    recvAvail <= YES;
                    recvData <= rxdData_i;
                elsif (enable_i = ENABLE and readEnable_i = ENABLE) then
                    recvAvail <= NO;
                    recvData <= (others => '0');
                end if;

                if (enable_i = ENABLE and readEnable_i = DISABLE and txdBusy_i = '0') then
                    -- If busy, ignore it
                    txdStart_o <= '1';
                    txdData_o <= dataSave_i(7 downto 0);
                end if;
            end if;
        end if;
    end process;
end bhv;
