library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity encoder is
    port (
        clk : in std_logic;
        send : in std_logic;
        reset : in std_logic;
        frequency_div : in std_logic_vector(21 downto 0);
        pulse_no : in std_logic_vector(5 downto 0);
        enc_A : out std_logic := '1';
        enc_B : out std_logic := '1';
        done : out std_logic := '0'
    );
end entity;

architecture rtl of encoder is
    signal shift_count : std_logic_vector(21 downto 0);
    signal phase_shift_count : std_logic_vector(21 downto 0) := (others => '0');
    signal r_enc_A : std_logic := '1';
    signal r_enc_B : std_logic := '1';
    signal send_B : std_logic := '0';

    signal done_A : std_logic := '0';
	signal done_B : std_logic := '0';
    signal enc_A_d : std_logic;

    component signal_gen is
        port (
            clk : in std_logic;
            send : in std_logic;
            reset : in std_logic;
            frequency_div : in std_logic_vector(21 downto 0) := (others => '0');
            pulse_no : in std_logic_vector(5 downto 0)  := (others => '0');
            output : out std_logic := '1';
            done : out std_logic := '0'
        );
    end component;
begin
    
    phase_shift_count(20 downto 0) <= frequency_div(21 downto 1);
    enc_A <= r_enc_A;
	done <= done_B;
    process(clk,reset)
    begin
        if reset = '1' then
            shift_count <= frequency_div;
            send_B <= '0';
            done_A <= '0';
            enc_A_d <= '1';
        elsif rising_edge(clk) then
            enc_A_d <= r_enc_A;
            if shift_count = phase_shift_count then
                send_B <= '1';
                shift_count <= std_logic_vector(unsigned(shift_count) + 1);
            elsif done_B = '0' then
                if enc_A_d = '1' and r_enc_A = '0' then
                    shift_count <= (others => '0');
                else
                    shift_count <= std_logic_vector(unsigned(shift_count) + 1);
                end if;
                send_B <= '0';
            end if;
        end if;
    end process;

    signal_gen_inst_A : signal_gen 
    port map(
        clk => clk,
        send => send,
        reset => reset,
        frequency_div => frequency_div,
        pulse_no => pulse_no,
        output => r_enc_A,
        done => done_A
    );


    signal_gen_inst_B : signal_gen 
    port map(
        clk => clk,
        send => send_B,
        reset => reset,
        frequency_div => frequency_div,
        pulse_no => pulse_no,
        output => enc_B,
        done => done_B
    );
            
        
    
end rtl;