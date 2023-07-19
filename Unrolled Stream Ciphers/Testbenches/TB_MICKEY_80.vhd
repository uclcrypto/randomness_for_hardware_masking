library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_MICKEY_80 is
end TB_MICKEY_80;

architecture Behavioral of TB_MICKEY_80 is

    component MICKEY_80 is
        Generic (output_bits : INTEGER := 4);
        Port (  clk : in STD_LOGIC;
                rst : in STD_LOGIC;
                mixing : in STD_LOGIC;
                din : in STD_LOGIC_VECTOR(output_bits-1 downto 0);
                stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst, mixing : STD_LOGIC := '0';
    signal din : STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
    constant key : STD_LOGIC_VECTOR(79 downto 0) := x"f11a5627ce43b61f8912";
    constant iv : STD_LOGIC_VECTOR(79 downto 0) := x"9c532f8ac3ea4b2ea0f5";
    signal stream_out : STD_LOGIC_VECTOR(3 downto 0);

    signal keystream : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
    
    constant clk_period : time := 10ns;
    
begin

    UUT: MICKEY_80 generic map (4) port map (clk, rst, mixing, din, stream_out);
    
    clk_proc: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
        rst <= '1';
        mixing <= '0';
        din <= x"0";
                
        wait for 4*clk_period;
        
        rst <= '0';
        mixing <= '1';
        for i in 0 to 19 loop
            din <= iv(79-i*4 downto 76-i*4);
            wait for clk_period;
        end loop;
        for i in 0 to 19 loop
            din <= key(79-i*4 downto 76-i*4);
            wait for clk_period;
        end loop;
        for i in 0 to 24 loop
            din <= x"0";
            wait for clk_period;
        end loop;
        
        mixing <= '0';
        
        wait for clk_period*32; -- 128/OUTPUT_BITS
        
        if keystream = x"21a0436619cb9f3f6f1fb303f56a09a9" then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;
    
    shift_reg: process(CLK)
    begin
        if (rising_edge(CLK)) then
            keystream  <= keystream(123 downto 0) & stream_out;
        end if;
    end process;

end Behavioral;
