library ieee;
use ieee.std_logic_1164.all;

entity ddr3_ctrl_100 is
    port (
        clk, rst: in std_logic;

        enable_i, readEnable_i: in std_logic; -- read enable means write disable
        addr_i: in std_logic_vector(31 downto 0);
        writeData_i: in std_logic_vector(31 downto 0);
        readData_o: out std_logic_vector(31 downto 0);
        byteSelect_i: in std_logic_vector(3 downto 0);
        busy_o: out std_logic;

        axi_awid_o: out std_logic_vector(7 downto 0);
        axi_awaddr_o: out std_logic_vector(26 downto 0);
        axi_awlen_o: out std_logic_vector(7 downto 0);
        axi_awsize_o: out std_logic_vector(2 downto 0);
        axi_awburst_o: out std_logic_vector(1 downto 0);
        axi_awvalid_o: out std_logic;
        axi_awready_i: in std_logic;

        axi_wdata_o: out std_logic_vector(31 downto 0);
        axi_wstrb_o: out std_logic_vector(3 downto 0);
        axi_wlast_o: out std_logic;
        axi_wvalid_o: out std_logic;
        axi_wready_i: in std_logic;

        axi_bid_i: in std_logic_vector(7 downto 0);
        axi_bresp_i: in std_logic_vector(1 downto 0);
        axi_bvalid_i: in std_logic;
        axi_bready_o: out std_logic;

        axi_arid_o: out std_logic_vector(7 downto 0);
        axi_araddr_o: out std_logic_vector(26 downto 0);
        axi_arlen_o: out std_logic_vector(7 downto 0);
        axi_arsize_o: out std_logic_vector(2 downto 0);
        axi_arburst_o: out std_logic_vector(1 downto 0);
        axi_arvalid_o: out std_logic;
        axi_arready_i: in std_logic;

        axi_rid_i: in std_logic_vector(7 downto 0);
        axi_rdata_i: in std_logic_vector(31 downto 0);
        axi_rresp_i: in std_logic_vector(1 downto 0);
        axi_rlast_i: in std_logic;
        axi_rvalid_i: in std_logic;
        axi_rready_o: out std_logic
    );
end ddr3_ctrl_100;

architecture bhv of ddr3_ctrl_100 is

    signal wid, rid: std_logic_vector(7 downto 0);
    
    type ReadState is (INIT, READ);
    signal rstate: ReadState;
    type WriteState is (INIT, AOK, DOK, WRITE);
    signal wstate: WriteState;

    constant ENABLE: std_logic := '1';
    constant DISABLE: std_logic := '0';

begin

    axi_awid_o <= wid;
    axi_awaddr_o <= addr_i(26 downto 0);
    axi_awlen_o <= 8ub"0";
    axi_awsize_o <= "101";
    axi_awburst_o <= "01";
    axi_awvalid_o <= '1' when (wstate = INIT or wstate = DOK) and enable_i = ENABLE and readEnable_i = DISABLE else '0';

    axi_wdata_o <= writeData_i;
    axi_wstrb_o <= byteSelect_i;
    axi_wvalid_o <= '1' when (wstate = INIT or wstate = AOK) and enable_i = ENABLE and readEnable_i = DISABLE else '0';
    axi_wlast_o <= '1' when (wstate = INIT or wstate = AOK) and enable_i = ENABLE and readEnable_i = DISABLE else '0';

    axi_bready_o <= '1' when wstate = WRITE else '0';

    -------
    
    rid <= 8ub"0";

    axi_arid_o <= rid;
    axi_araddr_o <= addr_i(26 downto 0);
    axi_arlen_o <= 8ub"0";
    axi_arsize_o <= "101";
    axi_arburst_o <= "01";
    --
    axi_arvalid_o <= '1' when rstate = INIT and enable_i = ENABLE and readEnable_i = ENABLE else '0';

    readData_o <= axi_rdata_i;
    axi_rready_o <= '1' when rstate = READ else '0';

    busy_o <= (not (axi_rlast_i and axi_rvalid_i)) when readEnable_i = ENABLE else (not axi_bvalid_i);

    process(clk) begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                rstate <= INIT;
                wstate <= INIT;
            else

                if (enable_i = ENABLE and readEnable_i = ENABLE) then
                    if (rstate = INIT and axi_arready_i = '1') then
                        rstate <= READ;
                    elsif (rstate = READ and axi_rvalid_i = '1') then
                        rstate <= INIT;
                    end if;
                end if;

                if (enable_i = ENABLE and readEnable_i = DISABLE) then
                    if (wstate = INIT and axi_awready_i = '1' and axi_wready_i = '1') then
                        wstate <= WRITE;
                    elsif (wstate = INIT and axi_awready_i = '1') then
                        wstate <= AOK;
                    elsif (wstate = INIT and axi_wready_i = '1') then
                        wstate <= DOK;
                    elsif ((wstate = DOK and axi_awready_i = '1') or (wstate = AOK and axi_wready_i = '1')) then
                        wstate <= WRITE;
                    elsif (wstate = WRITE and axi_bvalid_i = '1') then
                        wstate <= INIT;
                    end if;
                end if;

            end if;
        end if;
    end process;

end bhv;