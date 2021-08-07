library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity demux is
    port (
        addr    : in std_logic_vector(4 downto 0);
        input_A : in std_logic:='1';
        input_B : in std_logic:='1';
        output  : out std_logic_vector(18 downto 0)
    );
end entity;

architecture rtl of demux is

signal not_a : std_logic := '0';
signal not_b : std_logic:= '0';
begin
	not_a <= not(input_A);
	not_b <= not(input_A);
	
    with addr select output <=
        (0 => not_a,others => '0') when "00000",
        (1 => not_a,others => '0') when "00001",
        (2 => not_a,others => '0') when "00010",
        (3 => not_a,others => '0') when "00011",
        (4 => not_a,others => '0') when "00100",
        (5 => not_a,others => '0') when "00101",
        (6 => not_a,others => '0') when "00110",
        (7 => not_a,others => '0') when "00111",
        (8 => not_a,others => '0') when "01000",
        (9 => not_a,others => '0') when "01001",
        (10 => not_a,others => '0') when "01010",
        (11 => not_a,others => '0') when "01011",
        (12 => not_a,others => '0') when "01100",
        (13 => not_a,14 =>not_b,others => '0') when  "10000",
        (13 => not_b,14 => not_a,others => '0') when "10001",
        (15 => not_a,others => '0') when "01101",
        (16 => not_a,17 => not_b,others => '0') when "10010",
        (16 => not_b,17 => not_a,others => '0') when "10011",
        (18 => not_a,others => '1') when "01110",
        (others => '0') when others;
end rtl;



