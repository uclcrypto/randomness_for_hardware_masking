library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Grain_128 is
    Generic (output_bits : INTEGER := 32);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            init : in STD_LOGIC;
            key : in STD_LOGIC_VECTOR(127 downto 0);
            iv : in STD_LOGIC_VECTOR(95 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end Grain_128;

architecture Behavioral of Grain_128 is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(127 downto 0);
    signal lfsr_state, nlfsr_state : cycle_states;
    signal lfsr_feedback, nlfsr_feedback, outfeed : STD_LOGIC_VECTOR(output_bits-1 downto 0);

begin

    StateUpdate: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                lfsr_state(0)      <= x"FFFFFFFF" & iv;
                nlfsr_state(0)     <= key;
            else
                lfsr_state(0)      <= lfsr_state(output_bits);
                nlfsr_state(0)     <= nlfsr_state(output_bits);
            end if;
        end if;
    end process;
    
    MultipleCycles: for i in 1 to output_bits generate
        lfsr_feedback(i-1)         <= lfsr_state(i-1)(96) XOR lfsr_state(i-1)(81) XOR lfsr_state(i-1)(70) XOR lfsr_state(i-1)(38) XOR lfsr_state(i-1)(7) XOR lfsr_state(i-1)(0);
        lfsr_state(i)              <= (lfsr_feedback(i-1) & lfsr_state(i-1)(127 downto 1)) when init = '0' else ((outfeed(i-1) XOR lfsr_feedback(i-1)) & lfsr_state(i-1)(127 downto 1));
        nlfsr_feedback(i-1)        <= lfsr_state(i-1)(0) XOR nlfsr_state(i-1)(96) XOR nlfsr_state(i-1)(91) XOR nlfsr_state(i-1)(56) XOR nlfsr_state(i-1)(26) XOR nlfsr_state(i-1)(0) XOR (nlfsr_state(i-1)(84) AND nlfsr_state(i-1)(68)) XOR (nlfsr_state(i-1)(67) AND nlfsr_state(i-1)(3)) XOR (nlfsr_state(i-1)(65) AND nlfsr_state(i-1)(61)) XOR (nlfsr_state(i-1)(48) AND nlfsr_state(i-1)(40)) XOR (nlfsr_state(i-1)(59) AND nlfsr_state(i-1)(27)) XOR (nlfsr_state(i-1)(18) AND nlfsr_state(i-1)(17)) XOR (nlfsr_state(i-1)(13) AND nlfsr_state(i-1)(11));
        nlfsr_state(i)             <= (nlfsr_feedback(i-1) & nlfsr_state(i-1)(127 downto 1)) when init = '0' else ((outfeed(i-1) XOR nlfsr_feedback(i-1)) & nlfsr_state(i-1)(127 downto 1));
        outfeed(i-1)               <= lfsr_state(i-1)(93) XOR nlfsr_state(i-1)(2) XOR nlfsr_state(i-1)(15) XOR nlfsr_state(i-1)(36) XOR nlfsr_state(i-1)(45) XOR nlfsr_state(i-1)(64) XOR nlfsr_state(i-1)(73) XOR nlfsr_state(i-1)(89) XOR (nlfsr_state(i-1)(12) AND lfsr_state(i-1)(8)) XOR (lfsr_state(i-1)(13) AND lfsr_state(i-1)(20)) XOR (nlfsr_state(i-1)(95) AND lfsr_state(i-1)(42)) XOR (lfsr_state(i-1)(60) AND lfsr_state(i-1)(79)) XOR (nlfsr_state(i-1)(12) AND nlfsr_state(i-1)(95) AND lfsr_state(i-1)(95));
        stream_out(i-1)            <= outfeed(output_bits-i);
    end generate;

end Behavioral;
