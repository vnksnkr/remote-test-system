library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bounce_generator_tb is
end bounce_generator_tb;

architecture tb of bounce_generator_tb is
    constant CLK_PERIOD : time := 500 ns;
    signal reset : std_logic;
    signal clk : std_logic := '0';
    signal input : std_logic;
    signal output : std_logic := '1';
    signal done : std_logic;

    component bounce_generator
        port (
            reset : in std_logic;
            clk : in std_logic;
            input : in std_logic;
            output : out std_logic
        );
    end component;

begin
    bounce_tb : bounce_generator
    port map(
        reset => reset,
        clk => clk,
        input => input,
        output => output
    );

    clk <= not clk after CLK_PERIOD/2;

    process begin
        input <= '1';
        reset <= '1';
        wait for 510 ns;
        reset <= '0';
        wait for 510 ns;
        wait for 2000000 ns;
        input <= '0';
        wait for 20000000 ns;
        input <= '1';
        wait for 2000000 ns;
        input <= '0';
        wait for 20000000 ns;
        input <= '1';
        wait for 2000000 ns;
        input <= '0';
        wait for 20000000 ns;
        input <= '1';
        wait for 2000000 ns;
        input <= '0';
        wait for 20000000 ns;
        input <= '1';        
    end process;
end tb;