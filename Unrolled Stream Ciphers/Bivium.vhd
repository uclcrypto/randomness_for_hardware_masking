library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Bivium is
    Generic (output_bits : INTEGER := 64);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            key : in STD_LOGIC_VECTOR(79 downto 0);
            iv : in STD_LOGIC_VECTOR(79 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end Bivium;

architecture Behavioral of Bivium is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(176 downto 0);
    signal state : cycle_states;
    signal t1, t2 : STD_LOGIC_VECTOR(output_bits-1 downto 0);

begin

    StateUpdate: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state(0)    <= x"0" & iv & x"000" & '0' & key;
            else
                state(0)    <= state(output_bits);
            end if;
        end if;
    end process;
    
    MultipleCycles: for i in 1 to output_bits generate
        t1(i-1)         <= state(i-1)(65) XOR state(i-1)(92);
        t2(i-1)         <= state(i-1)(161) XOR state(i-1)(176);
        state(i)        <= state(i-1)(175 downto 93) & (t1(i-1) XOR (state(i-1)(90) AND state(i-1)(91)) XOR state(i-1)(170)) &
                           state(i-1)(91 downto 0) & (t2(i-1) XOR (state(i-1)(174) AND state(i-1)(175)) XOR state(i-1)(68));
        stream_out(i-1) <= t1(output_bits-i) XOR t2(output_bits-i);
    end generate;

end Behavioral;
