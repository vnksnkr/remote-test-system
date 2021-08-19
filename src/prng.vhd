----------------------------------------------------------------------------
--  prng.vhd
--	Pseudo-Random Number Generator
--
--  Copyright (C) Vinayak Sankar
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	3 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prng is
  port (
    clk : in std_logic;
    reset : in std_logic;
    gen : in std_logic;
    seed : in std_logic_vector (12 downto 0);
    output : out std_logic_vector (12 downto 0)
  );
end prng;

architecture rtl of prng is
  signal currstate, nextstate : std_logic_vector (12 downto 0);
  signal feedback : std_logic;
begin

  process (clk, reset)
  begin
    if (reset = '1') then
      currstate <= seed;
    elsif rising_edge(clk) then
      if gen = '1' then
        currstate <= nextstate;
      else
        currstate <= currstate;
      end if;
    else
      currstate <= currstate;
    end if;
  end process;

  feedback <= currstate(12) xnor currstate(3) xnor currstate(2) xnor currstate(0);
  nextstate <= feedback & currstate(12 downto 1);
  output <= currstate;

end rtl;
