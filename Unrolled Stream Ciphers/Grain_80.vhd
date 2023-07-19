library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Grain_80 is
    Generic (output_bits : INTEGER := 16);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            init : in STD_LOGIC;
            key : in STD_LOGIC_VECTOR(79 downto 0);
            iv : in STD_LOGIC_VECTOR(63 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end Grain_80;

architecture Behavioral of Grain_80 is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(79 downto 0);
    signal lfsr_state, nlfsr_state : cycle_states;
    signal lfsr_feedback, nlfsr_feedback, outfeed, N_63_60, N_63_45, N_60_52, N_37_33, N_28_9, N_21_15, N_33_28_21, L3_L46, L46_L64 : STD_LOGIC_VECTOR(output_bits-1 downto 0);

begin

    StateUpdate: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                lfsr_state(0)      <= x"FFFF" & iv;
                nlfsr_state(0)     <= key;
            else
                lfsr_state(0)      <= lfsr_state(output_bits);
                nlfsr_state(0)     <= nlfsr_state(output_bits);
            end if;
        end if;
    end process;
    
    MultipleCycles: for i in 1 to output_bits generate
        N_63_60(i-1)               <= nlfsr_state(i-1)(63) AND nlfsr_state(i-1)(60);
        N_63_45(i-1)               <= nlfsr_state(i-1)(63) AND nlfsr_state(i-1)(45);
        N_60_52(i-1)               <= nlfsr_state(i-1)(60) AND nlfsr_state(i-1)(52);
        N_37_33(i-1)               <= nlfsr_state(i-1)(37) AND nlfsr_state(i-1)(33);
        N_28_9(i-1)                <= nlfsr_state(i-1)(28) AND nlfsr_state(i-1)(9);
        N_21_15(i-1)               <= nlfsr_state(i-1)(21) AND nlfsr_state(i-1)(15);
        N_33_28_21(i-1)            <= nlfsr_state(i-1)(33) AND nlfsr_state(i-1)(28) AND nlfsr_state(i-1)(21);
        L3_L46(i-1)                <= lfsr_state(i-1)(3) AND lfsr_state(i-1)(46);
        L46_L64(i-1)               <= lfsr_state(i-1)(46) AND lfsr_state(i-1)(64);
        lfsr_feedback(i-1)         <= lfsr_state(i-1)(62) XOR lfsr_state(i-1)(51) XOR lfsr_state(i-1)(38) XOR lfsr_state(i-1)(23) XOR lfsr_state(i-1)(13) XOR lfsr_state(i-1)(0);
        lfsr_state(i)              <= (lfsr_feedback(i-1) & lfsr_state(i-1)(79 downto 1)) when init = '0' else ((outfeed(i-1) XOR lfsr_feedback(i-1)) & lfsr_state(i-1)(79 downto 1));
        nlfsr_feedback(i-1)        <= lfsr_state(i-1)(0) XOR nlfsr_state(i-1)(62) XOR nlfsr_state(i-1)(60) XOR nlfsr_state(i-1)(52) XOR nlfsr_state(i-1)(45) XOR nlfsr_state(i-1)(37) XOR nlfsr_state(i-1)(33) XOR nlfsr_state(i-1)(28) XOR nlfsr_state(i-1)(21) XOR nlfsr_state(i-1)(14) XOR nlfsr_state(i-1)(9) XOR nlfsr_state(i-1)(0) XOR N_63_60(i-1) XOR N_37_33(i-1) XOR (nlfsr_state(i-1)(15) AND nlfsr_state(i-1)(9)) XOR (N_60_52(i-1) AND nlfsr_state(i-1)(45)) XOR N_33_28_21(i-1) XOR (N_63_45(i-1) AND N_28_9(i-1)) XOR (N_60_52(i-1) AND N_37_33(i-1)) XOR (N_63_60(i-1) AND N_21_15(i-1)) XOR (N_63_45(i-1) AND N_60_52(i-1) AND nlfsr_state(i-1)(37)) XOR (N_28_9(i-1) AND N_21_15(i-1) AND nlfsr_state(i-1)(33)) XOR (N_33_28_21(i-1) AND nlfsr_state(i-1)(52) AND nlfsr_state(i-1)(45) AND nlfsr_state(i-1)(37));
        nlfsr_state(i)             <= (nlfsr_feedback(i-1) & nlfsr_state(i-1)(79 downto 1)) when init = '0' else ((outfeed(i-1) XOR nlfsr_feedback(i-1)) & nlfsr_state(i-1)(79 downto 1));
        outfeed(i-1)               <= nlfsr_state(i-1)(1) XOR nlfsr_state(i-1)(2) XOR nlfsr_state(i-1)(4) XOR nlfsr_state(i-1)(10) XOR nlfsr_state(i-1)(31) XOR nlfsr_state(i-1)(43) XOR nlfsr_state(i-1)(56) XOR lfsr_state(i-1)(25) XOR nlfsr_state(i-1)(63) XOR (lfsr_state(i-1)(3) AND lfsr_state(i-1)(64)) XOR L46_L64(i-1) XOR (lfsr_state(i-1)(64) AND nlfsr_state(i-1)(63)) XOR (L3_L46(i-1) AND lfsr_state(i-1)(25)) XOR (L3_L46(i-1) AND lfsr_state(i-1)(64)) XOR (L3_L46(i-1) AND nlfsr_state(i-1)(63)) XOR (lfsr_state(i-1)(25) AND lfsr_state(i-1)(46) AND nlfsr_state(i-1)(63)) XOR (L46_L64(i-1) AND nlfsr_state(i-1)(63));
        stream_out(i-1)            <= outfeed(output_bits-i);
    end generate;

end Behavioral;
