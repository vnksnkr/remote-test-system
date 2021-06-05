library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity pulse_gen is
    port (
        clk : in std_logic;
        output : out std_logic := '0';
        length : in std_logic_vector (7 downto 0);
        delay : in std_logic_vector (7 downto 0);
        send : in std_logic;
        stop : in std_logic;
        done : out std_logic
    );
end entity pulse_gen;

architecture rtl of pulse_gen is
    signal length_c : std_logic_vector (7 downto 0) := "00000000";
    signal max_length : std_logic_vector (7 downto 0) := "00000000";
    signal max_delay : std_logic_vector (7 downto 0) := "00000000";
    signal delay_c : std_logic_vector (7 downto 0) := "00000000";
    type SM is (IDLE, SEND_pulse, WAIT_delay, RESPOND);
    signal STATE : SM := IDLE;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if stop = '1' then
                STATE <= IDLE;
            else
                case STATE is
                    when IDLE =>

                        done <= '0';
                        if send = '1' then
                            max_length <= length;
                            max_delay <= delay;
                            STATE <= SEND_pulse;
                        else
                            max_length <= "00000000";
                            max_delay <= "00000000";
                            STATE <= IDLE;
                        end if;

                    when SEND_pulse =>
                        if length_c >= max_length then
                            state <= WAIT_delay;
                            length_c <= "00000000";
                            output <= '0';
                        else
                            if length_c = std_logic_vector(unsigned(max_length) - 1) then
                            end if;
                            output <= '1';
                            STATE <= SEND_pulse;
                            length_c <= std_logic_vector(unsigned(length_c) + 1);
                        end if;
                    when WAIT_delay =>
                        if delay_c >= max_delay then
                            state <= RESPOND;
                            delay_c <= "00000000";
                        else
                            output <= '0';
                            STATE <= WAIT_delay;
                            delay_c <= std_logic_vector(unsigned(delay_c) + 1);
                        end if;
                    when RESPOND =>
                        done <= '1';
                        STATE <= IDLE;

                end case;
            end if;
        end if;
    end process;

end rtl;