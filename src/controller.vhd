LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity controller is
    generic (
        CLKS_PER_10ms : integer := 20000;
        CLKS_PER_15ms : integer := 30000
    );
    port (
        reset : in std_logic;
        clk : in std_logic;
        start : in std_logic;
        output : out std_logic := '1';
        done : out std_logic
         );
end controller;

architecture rtl of controller is

    type SM is (IDLE,BOUNCE_low,PUSH,BOUNCE_high);
    signal STATE : SM := IDLE;
    signal clkcnt : integer := 0;
    signal not_push : std_logic :='1';
    signal first_send : std_logic ;
    signal gen : std_logic := '0';
    signal sent_pulse : std_logic;
    signal reset_gen : std_logic;
    signal stop_gen : std_logic := '0';
    signal pulse_out : std_logic;


    component random_pulse_gen is
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
    output <= pulse_out and not_push;
    random_pulse_gen_inst : random_pulse_gen
        port map (
            clk => clk,
            rst => reset,
            send => gen,
            stop => stop_gen,
            pulse => pulse_out,
            done => sent_pulse
        );

    process(clk)
    begin
        if rising_edge(clk) then
            clkcnt <= clkcnt + 1;
            if reset = '1' then
                STATE <= IDLE;
                clkcnt <= 0;

            else
                case STATE is
                    when IDLE =>
                        done <= '0';
                        gen <= '0';
                        if start = '1' then
                            STATE <= BOUNCE_low;
                            clkcnt <= 0;
                            first_send <= '1';
                        else
                            STATE <= IDLE;
                        end if;
                    when BOUNCE_Low =>
                        if clkcnt >= CLKS_PER_10ms then
                            STATE <= PUSH;
                            gen <= '1';
                            clkcnt <= 0;
                        else
                            if sent_pulse = '1' or first_send = '1' then
                                gen <= '1';
                                first_send <= '0';
                            else
                                gen <= '0';
                            end if;
                            STATE <= BOUNCE_low;
                        end if;
                    when PUSH =>
                        if clkcnt >= CLKS_PER_15ms then
                            STATE <= BOUNCE_high;
                            clkcnt <= 0;
                            first_send <= '1';
                            not_push <= '1';
                            gen <= '1';
                        else
                            not_push <= '0';
                            STATE <= PUSH;
                        end if;
                    when BOUNCE_high =>
                        if clkcnt >= CLKS_PER_10ms then
                            STATE <= IDLE;
                            done <= '1';
                            gen <= '0';
                        else
                            STATE <= BOUNCE_high;
                            if sent_pulse = '1' or first_send = '1' then
                                gen <= '1';
                                first_send <= '0';
                            else
                                gen <= '0';
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;


end rtl;
