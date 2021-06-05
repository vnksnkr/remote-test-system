library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prng is
  port (
    clk : in std_logic;
    rst : in std_logic;
    gen : in std_logic;
    seed : in std_logic_vector (12 downto 0);
    output : out std_logic_vector (12 downto 0)
  );
end prng;

architecture rtl of prng is
  signal currstate, nextstate : std_logic_vector (12 downto 0);
  signal feedback : std_logic;
begin

  process (clk, rst)
  begin
    if (rst = '1') then
      currstate <= seed;
    elsif rising_edge(clk) then
      if gen = '1' then
        currstate <= nextstate;
      end if;
    end if;
  end process;

  feedback <= currstate(12) xnor currstate(3) xnor currstate(2) xnor currstate(0);
  nextstate <= feedback & currstate(12 downto 1);
  output <= currstate;

end rtl;