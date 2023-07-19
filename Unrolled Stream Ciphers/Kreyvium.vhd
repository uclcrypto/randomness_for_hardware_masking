library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Kreyvium is
    Generic (output_bits : INTEGER := 64);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            key : in STD_LOGIC_VECTOR(127 downto 0);
            iv : in STD_LOGIC_VECTOR(127 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end Kreyvium;

architecture Behavioral of Kreyvium is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(287 downto 0);
    signal state : cycle_states;
    type keyiv_states is array (0 to output_bits) of STD_LOGIC_VECTOR(127 downto 0);
    signal key_state, iv_state : keyiv_states;
    signal t1, t2, t3 : STD_LOGIC_VECTOR(output_bits-1 downto 0);

begin

    StateUpdate: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state(0)        <= "011" & x"FFFFFFFFFFFFFFFF" & iv & key(92 downto 0);
                key_state(0)    <= key;
                iv_state(0)     <= iv;
            else
                state(0)        <= state(output_bits);
                key_state(0)    <= key_state(output_bits);
                iv_state(0)     <= iv_state(output_bits);
            end if;
        end if;
    end process;
    
    MultipleCycles: for i in 1 to output_bits generate
        key_state(i)    <= key_state(i-1)(0) & key_state(i-1)(127 downto 1);
        iv_state(i)     <= iv_state(i-1)(0) & iv_state(i-1)(127 downto 1);
        t1(i-1)         <= state(i-1)(161) XOR state(i-1)(176);
        t2(i-1)         <= state(i-1)(65) XOR state(i-1)(92);
        t3(i-1)         <= state(i-1)(242) XOR state(i-1)(287) XOR key_state(i-1)(0);
        state(i)        <= state(i-1)(286 downto 177) & (t1(i-1) XOR (state(i-1)(174) AND state(i-1)(175)) XOR state(i-1)(263)) & 
                           state(i-1)(175 downto 93) & (t2(i-1) XOR (state(i-1)(90) AND state(i-1)(91)) XOR state(i-1)(170) XOR iv_state(i-1)(0)) &
                           state(i-1)(91 downto 0) & (t3(i-1) XOR (state(i-1)(285) AND state(i-1)(286))XOR state(i-1)(68));
        stream_out(i-1) <= t1(output_bits-i) XOR t2(output_bits-i) XOR t3(output_bits-i);
    end generate;

end Behavioral;
