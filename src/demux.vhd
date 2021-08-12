library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity demux is
    port (
        addr : in std_logic_vector(4 downto 0) := "11111";
        input_A : in std_logic := '1';
        input_B : in std_logic := '1';
        shld_buttons : out std_logic_vector(12 downto 0);
        shld_encA : out std_logic_vector(1 downto 0);
        shld_encB : out std_logic_vector(1 downto 0);
        shld_encS : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of demux is

    signal not_a : std_logic := '0';
    signal not_b : std_logic := '0';
begin
    not_a <= not(input_A);
    not_b <= not(input_B);

    with addr select shld_buttons <=
        (0 => not_a, others => '0') when "00000",
        (1 => not_a, others => '0') when "00001",
        (2 => not_a, others => '0') when "00010",
        (3 => not_a, others => '0') when "00011",
        (4 => not_a, others => '0') when "00100",
        (5 => not_a, others => '0') when "00101",
        (6 => not_a, others => '0') when "00110",
        (7 => not_a, others => '0') when "00111",
        (8 => not_a, others => '0') when "01000",
        (9 => not_a, others => '0') when "01001",
        (10 => not_a, others => '0') when "01010",
        (11 => not_a, others => '0') when "01011",
        (12 => not_a, others => '0') when "01100",
        (others => '0') when others;

    with addr select shld_encA <=
        (0 => not_a, others => '0') when "10000",
        (0 => not_b, others => '0') when "10001",
        (1 => not_a, others => '0') when "10010",
        (1 => not_b, others => '0') when "10011",
        (others => '0') when others;

    with addr select shld_encB <=
        (0 => not_b, others => '0') when "10000",
        (0 => not_a, others => '0') when "10001",
        (1 => not_b, others => '0') when "10010",
        (1 => not_a, others => '0') when "10011",
        (others => '0') when others;
    with addr select shld_encS <=
        (0 => not_a, others => '0') when "01101",
        (1 => not_a, others => '0') when "01110",
        (others => '0') when others;

end rtl;