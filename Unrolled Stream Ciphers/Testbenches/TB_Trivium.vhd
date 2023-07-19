library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Trivium is
end TB_Trivium;

architecture Behavioral of TB_Trivium is

    component Trivium is
        Generic (output_bits : INTEGER := 64);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                key : in STD_LOGIC_VECTOR(79 downto 0);
                iv : in STD_LOGIC_VECTOR(79 downto 0);
                stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal key : STD_LOGIC_VECTOR(79 downto 0) := (OTHERS => '0');
    signal iv : STD_LOGIC_VECTOR(79 downto 0) := (OTHERS => '0');
    signal stream_out : STD_LOGIC_VECTOR(63 downto 0);

    signal keystream : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
    
    constant clk_period : time := 10ns;
    
begin

    UUT: Trivium generic map (64) port map (clk, rst, key, iv, stream_out);
    
    clk_proc: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
        key <= x"F046AD10DA75802AE55F";
        iv <= x"14F16FBA23D4499F06E3";
        
        rst <= '1';
                
        wait for clk_period;

        rst <= '0';

        wait for clk_period*18; -- 1152/OUTPUT_BITS
        wait for clk_period*2; -- 128/OUTPUT_BITS
        
        if keystream = x"251C36B66E2419FC57B17DCE28A77FF8" then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;
    
    shift_reg: process(CLK)
    begin
        if (rising_edge(CLK)) then
            keystream  <= keystream(63 downto 0) & stream_out;
        end if;
    end process;

end Behavioral;
