library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_tb is
end controller_tb;

architecture tb of controller_tb is
    constant CLK_PERIOD : time := 500 ns;
    signal reset : std_logic;
    signal clk : std_logic :='0';
    signal start : std_logic;
    signal output : std_logic := '1';
    signal done : std_logic;

    component controller 
        port (
            reset : in std_logic;
            clk : in std_logic;
            start : in std_logic;
            output : out std_logic := '1';
            done : out std_logic
        );
    end component;

    begin
        contr_inst : controller
            port map (
                reset => reset,
                clk => clk,
                start => start,
                output => output,
                done => done
            );
    
        clk <= not clk after CLK_PERIOD/2;

        process begin
            reset <= '1';
            wait for 530 ns;
            reset <= '0';
            start <= '1';
            wait for 530 ns;
            start <= '0';
            -- wait until done = '1';wait for 200000 ns;
            -- start <= '1';
            -- wait for 530 ns;
            -- start <= '0';
            -- wait until done = '1';wait for 200000 ns;
            -- start <= '1';
            -- wait for 530 ns;
            -- start <= '0';
            -- wait until done = '1';wait for 200000 ns;
            -- start <= '1';
            -- wait for 530 ns;
            -- start <= '0';
            wait;
        end process;  
    end tb;
    

