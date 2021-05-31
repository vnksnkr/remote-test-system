library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity pulse_gen is
    port (
        clk : in std_logic;
        output : out std_logic := '0';
        length : in std_logic_vector (13 downto 0);
        delay : in std_logic_vector (13 downto 0);
        send  : in std_logic;
        stop  : in std_logic;
        resp  : out std_logic;
        done : out std_logic
    );
end entity pulse_gen;

architecture rtl of pulse_gen is
    signal length_out : std_logic_vector (13 downto 0) := "00000000000000";
    signal delay_out  : std_logic_vector (13 downto 0):= "00000000000000";
    type SM is (IDLE,SEND_pulse,WAIT_delay,RESPOND);
    signal STATE : SM := IDLE;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if stop = '1' then
                STATE <= IDLE;
            else
                case STATE is
                    when IDLE =>
                        done <= '0';
                        resp <= '0';
                        if send = '1' then
                            STATE <= SEND_pulse;
                        else
                            STATE <= IDLE;
                        end if;
                    
                    when SEND_pulse =>
                        if length_out >= length then
                            state <= WAIT_delay;
                            length_out <= "00000000000000";
                            output <= '0';
                        else
                            if length_out = std_logic_vector(unsigned(length)-1) then
                                resp <= '1';
                            end if;
                            output <= '1';
                            STATE <= SEND_pulse;    
                            length_out <= std_logic_vector(unsigned(length_out)+1);
                        end if;
                    when WAIT_delay =>
                        resp <= '0';
                        if delay_out = delay  then
                            state <= RESPOND;
                            delay_out <= "00000000000000";
                        else
                            output <= '0';
                            STATE <= WAIT_delay;
                            delay_out <= std_logic_vector(unsigned(delay_out) + 1);
                        end if;
                    when RESPOND =>
                            done <= '1';
                            STATE <= IDLE;
                    
                end case;
            end if;
        end if;
    end process;

end rtl;

                                        
                        
                        





