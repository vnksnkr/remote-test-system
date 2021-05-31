library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_gen_tb is
end pulse_gen_tb;

architecture tb of pulse_gen_tb is

    constant CLK_PERIOD : time := 500 ns;
	signal clk : std_logic := '0';
    signal output : std_logic;
    signal length : std_logic_vector (13 downto 0);
    signal delay  : std_logic_vector (13 downto 0);
    signal send   : std_logic;
    signal stop   : std_logic;
    signal resp   : std_logic;
   
   	component pulse_gen
    	port (
          clk : in std_logic;
          output : out std_logic;
          length : in std_logic_vector (13 downto 0);
          delay : in std_logic_vector (13 downto 0);
          send  : in std_logic;
          stop  : in std_logic;
          resp  : out std_logic
		  );
    end component;
    
begin
	pulsegen_inst : pulse_gen
    	port map (
        	clk => clk,
            output => output,
            length => length,
            delay => delay,
            send => send,
            stop => stop,
            resp => resp );
            
    clk <= not clk after CLK_PERIOD/2;
        
    process 
    begin
    	length <= "00000011111111";
        delay <= "00000011111111";
        send <= '1';
        stop <= '0';
        wait for 510 ns;
        send <= '0';
    wait;
    end process;
    
end tb; 