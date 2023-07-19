library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Grain_80 is
end TB_Grain_80;

architecture Behavioral of TB_Grain_80 is

    component Grain_80 is
        Generic (output_bits : INTEGER := 16);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                init : in STD_LOGIC;
                key : in STD_LOGIC_VECTOR(79 downto 0);
                iv : in STD_LOGIC_VECTOR(63 downto 0);
                stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal init : STD_LOGIC := '0';
    signal key : STD_LOGIC_VECTOR(79 downto 0) := (OTHERS => '0');
    signal iv : STD_LOGIC_VECTOR(63 downto 0) := (OTHERS => '0');
    signal stream_out : STD_LOGIC_VECTOR(15 downto 0);

    signal keystream : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
    
    constant clk_period : time := 10ns;
    
begin

    UUT: Grain_80 generic map (16) port map (clk, rst, init, key, iv, stream_out);
    
    clk_proc: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
        key <= x"2c48f7b3d591e6a2c480";
        iv <= x"f7b3d591e6a2c480";
        
        init <= '1';
        rst <= '1';
                
        wait for clk_period;

        rst <= '0';
        init <= '1';

        wait for clk_period*10; -- 160/OUTPUT_BITS

        rst <= '0';
        init <= '0';
        
        wait for clk_period*8; -- 128/OUTPUT_BITS
        
        if keystream = x"42b567ccc65317680225cd83b21db3e4" then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;
    
    shift_reg: process(CLK)
    begin
        if (rising_edge(CLK)) then
            keystream  <= keystream(111 downto 0) & stream_out;
        end if;
    end process;

end Behavioral;
