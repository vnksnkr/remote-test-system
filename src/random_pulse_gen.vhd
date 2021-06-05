library ieee;
use ieee.std_logic_1164.all;
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
    signal w_length : std_logic_vector(12 downto 0) := (others => '0');
    signal w_delay : std_logic_vector(12 downto 0) := (others => '0');
    signal pulse_gen_out : std_logic;
    signal seed_length : std_logic_vector(12 downto 0) := "0000001111001";
    signal seed_delay : std_logic_vector(12 downto 0) := "0000000001000";

    component prng
        port (
            clk : in std_logic;
            rst : in std_logic;
            gen : in std_logic;
            seed : in std_logic_vector (12 downto 0);
            output : out std_logic_vector (12 downto 0)

        );
    end component;

    component pulse_gen
        port (
            clk : in std_logic;
            output : out std_logic;
            length : in std_logic_vector (7 downto 0);
            delay : in std_logic_vector (7 downto 0);
            send : in std_logic;
            stop : in std_logic;
            done : out std_logic
        );
    end component;

    signal shift : std_logic := '0';
    signal gen : std_logic;

begin
    pulse <= not pulse_gen_out;
    prng_inst_1 : prng
    port map(
        clk => clk,
        rst => rst,
        gen => send,
        output => w_length,
        seed => seed_length
    );

    prng_inst_2 : prng
    port map(
        clk => clk,
        rst => rst,
        gen => send,
        output => w_delay,
        seed => seed_delay
    );

    pulse_gen_inst : pulse_gen
    port map(
        clk => clk,
        output => pulse_gen_out,
        length => w_delay(7 downto 0),
        delay => w_length(7 downto 0),
        send => send,
        stop => stop,
        done => done
    );
end rtl;