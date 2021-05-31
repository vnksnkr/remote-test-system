LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY prng IS
  PORT (clk, rst,gen: IN std_logic;
        output: OUT std_logic_vector (13 DOWNTO 0));
END prng;

ARCHITECTURE rtl OF prng IS
  SIGNAL currstate, nextstate: std_logic_vector (13 DOWNTO 0);
  signal min : std_logic_vector(13 downto 0) := "00000001111111";
  signal max : std_logic_vector(13 downto 0) := "11111110000000";

  SIGNAL feedback: std_logic;
BEGIN

  StateReg: PROCESS (clk,Rst)
  BEGIN
    IF (rst = '1') THEN
      currstate <= (0 => '1', OTHERS =>'0');
    ELSIF rising_edge(clk) and gen = '1' THEN
        currstate <= nextstate;  
    END IF;
  END PROCESS;

  process(clk)
  begin
    if(currstate < min) then
      output <= min;
    elsif currstate > max then
      output <= max;
    else
      output <= currstate;
    end if;
  end process;    
      
  
  feedback <= currstate(13) XOR currstate(4) XOR currstate(2) XOR currstate(0);
  nextstate <= feedback & currstate(13 DOWNTO 1);

  end rtl;