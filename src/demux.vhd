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

begin
    with addr select output <=
        (0 => input_A,others => '1') when "00000",
        (1 => input_A,others => '1') when "00001",
        (2 => input_A,others => '1') when "00010",
        (3 => input_A,others => '1') when "00011",
        (4 => input_A,others => '1') when "00100",
        (5 => input_A,others => '1') when "00101",
        (6 => input_A,others => '1') when "00110",
        (7 => input_A,others => '1') when "00111",
        (8 => input_A,others => '1') when "01000",
        (9 => input_A,others => '1') when "01001",
        (10 => input_A,others => '1') when "01010",
        (11 => input_A,others => '1') when "01011",
        (12 => input_A,others => '1') when "01100",
        (13 => input_A,14 =>input_B,others => '1') when  "10000",
        (13 => input_B,14 => input_A,others => '1') when "10001",
        (15 => input_A,others => '1') when "01101",
        (16 => input_A,17 => input_B,others => '1') when "10010",
        (16 => input_B,17 => input_A,others => '1') when "10011",
        (18 => input_A,others => '1') when "01110",
        (others => '1') when others;
end rtl;



