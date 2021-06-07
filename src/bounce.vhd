library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bounce_generator is
    port (
        reset : in std_logic;
        clk   : in std_logic;
        input : in std_logic;
        seed_duration : in std_logic_vector(12 downto 0) ;
        seed_length   : in std_logic_vector(12 downto 0) ;
        seed_delay    : in std_logic_vector(12 downto 0) ;
        output : out std_logic
    );
end bounce_generator;

architecture rtl of bounce_generator is

    ---state machine---
    type SM is (IDLE, LOAD, WAIT_to_LOAD, BOUNCE);
    signal STATE : SM := IDLE;
    signal clkcnt : integer := 0;

    ---bounce control signals--- 
    signal gen : std_logic := '0';
    signal sent_pulse : std_logic;
    signal stop_gen : std_logic := '0';

    ---bounce parameters---
    signal load_bounce_interval : std_logic;
    signal bounce_duration : std_logic_vector(12 downto 0);
    signal bounce_signal : std_logic := '0';
    signal bounce_direction : std_logic := '0';
    
    ---pulse parameters---
    signal pulse_length : std_logic_vector(12 downto 0) := (others => '0');
    signal pulse_delay : std_logic_vector(12 downto 0) := (others => '0');
    signal pulse_gen_out : std_logic := '0';

    ---seeds (need to be input port)---


    component pulse_gen
        port (
            clk : in std_logic;
            output : out std_logic;
            length : in std_logic_vector (7 downto 0);
            delay : in std_logic_vector (7 downto 0);
            send : in std_logic;
            reset : in std_logic;
            done : out std_logic
        );
    end component;
    component prng
        port (
            clk : in std_logic;
            reset : in std_logic;
            gen : in std_logic;
            seed : in std_logic_vector (12 downto 0);
            output : out std_logic_vector (12 downto 0)
        );
    end component;

begin
    output <= ((bounce_signal or input) and (not bounce_direction)) or((not(bounce_signal) and input) and (bounce_direction));
    prng_bounce_duration : prng
    port map(
        clk => clk,
        reset => reset,
        gen => load_bounce_interval,
        output => bounce_duration,
        seed => seed_duration
    );

    prng_bounce_length : prng
    port map(
        clk => clk,
        reset => reset,
        gen => gen,
        output => pulse_length,
        seed => seed_length
    );

    prng_length_delay : prng
    port map(
        clk => clk,
        reset => reset,
        gen => gen,
        output => pulse_delay,
        seed => seed_delay
    );

    pulse_gen_inst : pulse_gen
    port map(
        clk => clk,
        output => bounce_signal,
        length => pulse_delay(7 downto 0),
        delay => pulse_length(7 downto 0),
        send => gen,
        reset => reset,
        done => sent_pulse
    );

    process (clk, input, reset)
    begin
        clkcnt <= clkcnt + 1;
        if reset = '1' then
            STATE <= IDLE;
            clkcnt <= 0;
        else
            case STATE is
                when IDLE =>
                    if rising_edge(input) then
                        STATE <= LOAD;
                        clkcnt <= 0;
                        bounce_direction <= '1';
                    elsif falling_edge(input) then
                        STATE <= LOAD;
                        clkcnt <= 0;
                        bounce_direction <= '0';
                    else
                        gen <= '0';
                        STATE <= IDLE;
                    end if;
                when LOAD =>
                    clkcnt <= 0;
                    load_bounce_interval <= '1';
                    STATE <= WAIT_to_LOAD;
                when WAIT_to_LOAD =>
                    state <= BOUNCE;
                when BOUNCE =>
                    load_bounce_interval <= '0';
                    if clkcnt >= unsigned(bounce_duration) then
                        STATE <= IDLE;
                        clkcnt <= 0;
                        gen <= '0';
                    else
                        gen <= '1';
                        STATE <= BOUNCE;
                    end if;

            end case;
        end if;
    end process;
end rtl;