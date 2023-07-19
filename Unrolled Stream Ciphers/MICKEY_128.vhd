library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MICKEY_128 is
    Generic (output_bits : INTEGER := 4);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            mixing : in STD_LOGIC;
            din : in STD_LOGIC_VECTOR(output_bits-1 downto 0);
            stream_out : out STD_LOGIC_VECTOR(output_bits-1 downto 0));
end MICKEY_128;

architecture Behavioral of MICKEY_128 is

    type cycle_states is array (0 to output_bits) of STD_LOGIC_VECTOR(159 downto 0);
    signal lfsr_state, nlfsr_state : cycle_states;
    signal lfsr_feedback, nlfsr_feedback, CBR, CBS : STD_LOGIC_VECTOR(output_bits-1 downto 0);

    constant RTAPS : STD_LOGIC_VECTOR(158 downto 0) := "000110010110010100010000100001010011010001100100011011111001111011001000110100111100110001110010100110001111101110111000000000111110101110010100100101011101100";
    constant COMP0 : STD_LOGIC_VECTOR(157 downto 0) := "11110100100111101101011101110101010101010010000011001001001111001000110000011100000000010011110100011001001101111110101111011000111110101100000011111011111000";
    constant COMP1 : STD_LOGIC_VECTOR(157 downto 0) := "00011001111100010011000101111100001100100111100011011010111111100000111110000110000000000111110101000101100011100000110011001101010110111011010001011111111111";
    constant FB0 : STD_LOGIC_VECTOR(159 downto 0)   := "1111010111111000001111000010001101000100110001011111010001110000100000011011001010100111011001101000100111010010001010100010101110000011110100001100011011000001";
    constant FB1 : STD_LOGIC_VECTOR(159 downto 0)   := "1101010111101110001011111101100100001001001100011001111000001110011011010001100001011001111101101110011101111110110100100011011011110111000000011110010110001000";        

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
        lfsr_feedback(i-1) <= din(output_bits-i) XOR (nlfsr_state(i-1)(80) AND mixing) XOR lfsr_state(i-1)(159);
        lfsr_state(i)(0) <= lfsr_feedback(i-1) XOR (CBR(i-1) AND lfsr_state(i-1)(0));
        LFSRUpdateFunction: for j in 1 to 159 generate
            ActiveTaps: if (RTAPS(159-j) = '1') generate
                lfsr_state(i)(j) <= lfsr_state(i-1)(j-1) XOR lfsr_feedback(i-1) XOR (CBR(i-1) AND lfsr_state(i-1)(j));
            end generate;
            NotActiveTaps: if (RTAPS(159-j) = '0') generate
                lfsr_state(i)(j) <= lfsr_state(i-1)(j-1) XOR (CBR(i-1) AND lfsr_state(i-1)(j));
            end generate;
        end generate;
        
        nlfsr_feedback(i-1) <= din(output_bits-i) XOR nlfsr_state(i-1)(159);
        nlfsr_state(i)(0) <= ((CBS(i-1) AND FB1(159)) OR ((NOT CBS(i-1)) AND FB0(159))) AND nlfsr_feedback(i-1);
        nlfsr_state(i)(159) <= nlfsr_state(i-1)(158) XOR (((CBS(i-1) AND FB1(0)) OR ((NOT CBS(i-1)) AND FB0(0))) AND nlfsr_feedback(i-1));
        NLFSRUpdateFunction: for j in 1 to 158 generate
            nlfsr_state(i)(j) <= nlfsr_state(i-1)(j-1) XOR ((nlfsr_state(i-1)(j) XOR COMP0(157-j+1)) AND (nlfsr_state(i-1)(j+1) XOR COMP1(157-j+1))) XOR (((CBS(i-1) AND FB1(159-j)) OR ((NOT CBS(i-1)) AND FB0(159-j))) AND nlfsr_feedback(i-1));
        end generate;
        
        CBR(i-1) <= nlfsr_state(i-1)(54) XOR lfsr_state(i-1)(106);
        CBS(i-1) <= nlfsr_state(i-1)(106) XOR lfsr_state(i-1)(53);
        stream_out(i-1) <= nlfsr_state(output_bits-i)(0) XOR lfsr_state(output_bits-i)(0);
    end generate;
    
end Behavioral;