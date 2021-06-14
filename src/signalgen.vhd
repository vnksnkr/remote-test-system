library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity signal_gen is
    port (
        clk : in std_logic;
        send : in std_logic;
        reset : in std_logic;
        frequency_div : in std_logic_vector(15 downto 0) := (others => '0');
        pulse_no : in std_logic_vector(5 downto 0)  := (others => '0');
        output : out std_logic := '1';
        done : out std_logic := '0'
    );
end entity;

architecture rtl of signal_gen is
    signal clkcnt : integer := 0;
    signal pulse_count : integer := 0;
    signal r_output : std_logic := '1';
    type SM is (IDLE,SEND_pulse);
    signal STATE : SM := IDLE;

begin
    output <= r_output;
    process(clk,reset)
    begin
        if reset = '1' then
            r_output <= '1';
            clkcnt <= 0;
            pulse_count <= 0;
            STATE <= IDLE;
        elsif rising_edge(clk) then
            case STATE is
                when IDLE =>
                done <= '0';
                if send = '1' then
                    STATE <= SEND_pulse;
                    clkcnt <= 0;
                    pulse_count <= 0;
                    r_output <= '0';
                else
                    STATE <= IDLE;
                    r_output <= '1';
                end if;

                when SEND_pulse =>
                    if pulse_count = unsigned(pulse_no)  then
                        STATE <= IDLE;
                        done <= '1';
                    else
                        if clkcnt = unsigned(frequency_div)  then
                            clkcnt <= 0;
                            if r_output = '0' then
                                pulse_count <= pulse_count + 1;
                            end if;
                            r_output <= not r_output;
                        else
                            clkcnt <= clkcnt + 1;
                            r_output <= r_output;
                        end if;
                    end if;
            end case;
        end if;
    end process;
                    

end rtl;