library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prng_tb is
end prng_tb;

architecture tb of prng_tb is
    constant CLK_PERIOD : time := 500 ns;
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal gen : std_logic := '0';
    signal prn : std_logic_vector (13 downto 0);
    

    component prng
        port (
            clk, rst,gen: IN std_logic;
            output: OUT std_logic_vector (13 DOWNTO 0)
        );
    end component;

begin
    prng_inst : prng
        port map (
            clk => clk,
            rst => rst,
            gen => gen,
            output => prn
        );

        clk <= not clk after CLK_PERIOD/2;
        gen <= not gen after CLK_PERIOD/2;
        process begin
            rst <= '1';
            wait for 510 ns;
            rst <= '0';
            wait;
        end process;
end tb;


