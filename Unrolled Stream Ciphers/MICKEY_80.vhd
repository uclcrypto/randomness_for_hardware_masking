library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MICKEY_80 is
    Generic (output_bits : INTEGER := 4);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            mixing : in STD_LOGIC;
            din : in STD_LOGIC_VECTOR(output_bits-1 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end MICKEY_80;

architecture Behavioral of MICKEY_80 is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(99 downto 0);
    signal lfsr_state, nlfsr_state : cycle_states;
    signal lfsr_feedback, nlfsr_feedback, CBR, CBS : STD_LOGIC_VECTOR(output_bits-1 downto 0);

    constant RTAPS : STD_LOGIC_VECTOR(98 downto 0) := "101111001001100100111100100100000000110011001100010101010101101111100011000000111100001111110111100";
    constant COMP0 : STD_LOGIC_VECTOR(97 downto 0) := "00011000101111010010101010101101001000000010101010000101001111001010111111111010111111010100000011";
    constant COMP1 : STD_LOGIC_VECTOR(97 downto 0) := "10110010111100101000110101110111100011010111000010001011100011111101011101111000100001110001001100";
    constant FB0 : STD_LOGIC_VECTOR(99 downto 0)   := "1111010111111110010111111111100110000001110010010101001011110101010000000001101000110111001110011000";
    constant FB1 : STD_LOGIC_VECTOR(99 downto 0)   := "1110111000011101001100010011001011000110000011011000100010010010110101001010001111011111000000100001";        

begin

    StateUpdate: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                lfsr_state(0)  <= (OTHERS => '0');
                nlfsr_state(0) <= (OTHERS => '0');
            else
                lfsr_state(0)  <= lfsr_state(output_bits);
                nlfsr_state(0) <= nlfsr_state(output_bits);
            end if;
        end if;
    end process;
    
    MultipleCycles: for i in 1 to output_bits generate
        lfsr_feedback(i-1) <= din(output_bits-i) XOR (nlfsr_state(i-1)(50) AND mixing) XOR lfsr_state(i-1)(99);
        lfsr_state(i)(0) <= lfsr_feedback(i-1) XOR (CBR(i-1) AND lfsr_state(i-1)(0));
        LFSRUpdateFunction: for j in 1 to 99 generate
            ActiveTaps: if (RTAPS(99-j) = '1') generate
                lfsr_state(i)(j) <= lfsr_state(i-1)(j-1) XOR lfsr_feedback(i-1) XOR (CBR(i-1) AND lfsr_state(i-1)(j));
            end generate;
            NotActiveTaps: if (RTAPS(99-j) = '0') generate
                lfsr_state(i)(j) <= lfsr_state(i-1)(j-1) XOR (CBR(i-1) AND lfsr_state(i-1)(j));
            end generate;
        end generate;
        
        nlfsr_feedback(i-1) <= din(output_bits-i) XOR nlfsr_state(i-1)(99);
        nlfsr_state(i)(0) <= ((CBS(i-1) AND FB1(99)) OR ((NOT CBS(i-1)) AND FB0(99))) AND nlfsr_feedback(i-1);
        nlfsr_state(i)(99) <= nlfsr_state(i-1)(98) XOR (((CBS(i-1) AND FB1(0)) OR ((NOT CBS(i-1)) AND FB0(0))) AND nlfsr_feedback(i-1));
        NLFSRUpdateFunction: for j in 1 to 98 generate
            nlfsr_state(i)(j) <= nlfsr_state(i-1)(j-1) XOR ((nlfsr_state(i-1)(j) XOR COMP0(97-j+1)) AND (nlfsr_state(i-1)(j+1) XOR COMP1(97-j+1))) XOR (((CBS(i-1) AND FB1(99-j)) OR ((NOT CBS(i-1)) AND FB0(99-j))) AND nlfsr_feedback(i-1));
        end generate;
        
        CBR(i-1) <= nlfsr_state(i-1)(34) XOR lfsr_state(i-1)(67);
        CBS(i-1) <= nlfsr_state(i-1)(67) XOR lfsr_state(i-1)(33);
        stream_out(i-1) <= nlfsr_state(output_bits-i)(0) XOR lfsr_state(output_bits-i)(0);
    end generate;
    
end Behavioral;