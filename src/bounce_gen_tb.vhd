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
    signal seed_duration : std_logic_vector(12 downto 0) := "0000001000111";
    signal seed_length : std_logic_vector(12 downto 0) := "0000001111001";
    signal seed_delay : std_logic_vector(12 downto 0) := "0001001111001";

    component bounce_generator
        port (
            reset : in std_logic;
            clk : in std_logic;
            input : in std_logic;
            seed_duration : in std_logic_vector(12 downto 0) ;
            seed_length   : in std_logic_vector(12 downto 0) ;
            seed_delay    : in std_logic_vector(12 downto 0) ;
            output : out std_logic
        );
    end component;

begin
    bounce_tb : bounce_generator
    port map(
        reset => reset,
        clk => clk,
        input => input,
        seed_duration => seed_duration,
        seed_length => seed_length,
        seed_delay => seed_delay,
        output => output
    );

    clk <= not clk after CLK_PERIOD/2;

    process begin
        input <= '1';
        reset <= '1';
        wait for 510 ns;
        reset <= '0';
        wait for 510 ns;
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';    
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';    
        wait for 5000000 ns;
        input <= '0';
        wait for 50000000 ns;
        input <= '1';        
    end process;
end tb;