library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
    generic (
        CLKS_PER_10ms : integer := 4000;
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

    type SM is (IDLE, BOUNCE_low, PUSH, BOUNCE_high);
    signal STATE : SM := IDLE;
    signal clkcnt : integer := 0;
    signal not_push : std_logic := '1';
    signal first_send : std_logic;
    signal gen : std_logic := '0';
    signal sent_pulse : std_logic;
    signal stop_gen : std_logic := '0';
    signal pulse_out : std_logic;
    signal load_bounce_interval : std_logic;
    signal bounce_duration : std_logic_vector(12 downto 0);
    signal seed_duration : std_logic_vector(12 downto 0) := "0000000000111"; --seeds need to be input port

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

    component prng
        port (
            clk : in std_logic;
            rst : in std_logic;
            gen : in std_logic;
            seed : in std_logic_vector (12 downto 0);
            output : out std_logic_vector (12 downto 0)
        );
    end component;

begin
    output <= pulse_out and not_push;
    random_pulse_gen_inst : random_pulse_gen
    port map(
        clk => clk,
        rst => reset,
        send => gen,
        stop => stop_gen,
        pulse => pulse_out,
        done => sent_pulse
    );

    prng_inst_1 : prng
    port map(
        clk => clk,
        rst => reset,
        gen => load_bounce_interval,
        output => bounce_duration,
        seed => seed_duration
    );
    process (clk)
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
                            load_bounce_interval <= '1';
                        else
                            STATE <= IDLE;
                        end if;
                    when BOUNCE_Low =>
                        load_bounce_interval <= '0';
                        if clkcnt >= unsigned(bounce_duration) then
                            STATE <= PUSH;
                            gen <= '0';
                            clkcnt <= 0;
                        else
                            if sent_pulse = '1' or first_send = '1' then
                                first_send <= '0';
                                gen <= '1';
                            else
                                gen <= '0';
                            end if;
                            STATE <= BOUNCE_low;
                        end if;
                    when PUSH =>
                        if clkcnt >= CLKS_PER_15ms then
                            STATE <= BOUNCE_high;
                            load_bounce_interval <= '1';
                            clkcnt <= 0;
                            first_send <= '1';
                            not_push <= '1';
                            gen <= '1';
                        else
                            not_push <= '0';
                            STATE <= PUSH;
                        end if;
                    when BOUNCE_high =>
                        load_bounce_interval <= '0';
                        if clkcnt >= unsigned(bounce_duration) then
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