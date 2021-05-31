library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random_tb is
end random_tb;

architecture tb of random_tb is
    constant CLK_PERIOD : time := 500 ns;
    signal clk :  std_logic:='0';
    signal rst :  std_logic:= '1';
    signal send :  std_logic;
    signal stop :  std_logic;
    signal pulse :  std_logic;
    signal done : std_logic;
    signal wait_r : std_logic;

    component random_pulse_gen  
        port (
            clk : in std_logic;
            rst : in std_logic;
            send : in std_logic;
            stop : in std_logic;
            pulse : out std_logic;
            done : out std_logic           
        );
    end component;

begin
    rpg_inst : random_pulse_gen
        port map (
            clk => clk,
            rst => rst,
            send => send,
            stop => stop,
            pulse => pulse,
            done => done
        );

    clk <= not clk after CLK_PERIOD/2;
    process begin
        rst <= '1';
        wait for 530 ns;
        rst <= '0';
        send <= '1';
        wait for 530 ns;
        send <= '0';
        wait until done = '1';
        send <= '1';
        wait for 530 ns;
        send <= '0';
        wait;
    end process;  
end tb;



