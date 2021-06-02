LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity random_pulse_gen is
    port (
        clk : in std_logic;
        rst : in std_logic;
        send : in std_logic;
        stop : in std_logic;
        pulse : out std_logic;
        done : out std_logic
    );

end entity;

architecture rtl of random_pulse_gen is
signal response: std_logic;
signal word : std_logic_vector(7 downto 0);
signal w_length : std_logic_vector(7 downto 0) := "00000000";
signal w_delay : std_logic_vector(7 downto 0) := "00000000" ;
signal pulse_gen_out : std_logic;

component prng
port (
    clk, rst,gen: IN std_logic;
    output: OUT std_logic_vector (7 downto 0)
);
end component;

component pulse_gen 
    port (
        clk : in std_logic;
        output : out std_logic ;
        length : in std_logic_vector (7 downto 0);
        delay : in std_logic_vector (7 downto 0);
        send  : in std_logic;
        stop  : in std_logic;
        resp  : out std_logic;
        done : out std_logic
    );
end component;

signal shift : std_logic := '0';
signal gen : std_logic;
begin
    gen <= response or send;   
    pulse <= not pulse_gen_out;
    prng_inst : prng
        port map (
            clk => clk,
            rst => rst,
            gen => gen,
            output => word
        );
    
    
    process(clk)
    begin
        if response = '1' then
            w_delay <= word;
            w_length <= "00000000";
        elsif send = '1' then
            w_length <= word;
            w_delay <= "00000000";
        end if;
    end process;

    pulse_gen_inst : pulse_gen
                port map (
                    clk => clk,
                    output => pulse_gen_out,
                    length => w_length,
                    delay => w_delay,
                    send => send,
                    stop => stop,
                    resp => response,
                    done => done
                );
end rtl;
