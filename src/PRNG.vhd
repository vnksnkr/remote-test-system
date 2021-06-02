LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY prng IS
  PORT (clk, rst,gen: IN std_logic;
        output: OUT std_logic_vector (7 DOWNTO 0));
END prng;

ARCHITECTURE rtl OF prng IS
  SIGNAL currstate, nextstate: std_logic_vector (7 DOWNTO 0);
  signal min : std_logic_vector(7 downto 0) := "00000010";
  SIGNAL feedback: std_logic;
BEGIN

  StateReg: PROCESS (clk,rst)
  BEGIN
    IF (rst = '1') THEN
      currstate <= "00000010";
    ELSIF rising_edge(clk)THEN
    if nextstate < min then
      currstate <= std_logic_vector(unsigned(nextstate) + unsigned(min));
    else
      currstate <= nextstate;
    end if;  
    END IF;
  END PROCESS;

  
      
  
  feedback <= currstate(4) XOR currstate(3) XOR currstate(2) XOR currstate(0);
  nextstate <= feedback & currstate(7 DOWNTO 1);
  output <= currstate;

  end rtl;