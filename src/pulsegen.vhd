----------------------------------------------------------------------------
--  pulsegen.vhd
--	Programmable Pulse Generator
--
--  Copyright (C) Vinayak Sankar
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	3 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity pulse_gen is
    port (
        clk : in std_logic;
        output : out std_logic;
        length : in std_logic_vector (7 downto 0);
        delay : in std_logic_vector (7 downto 0);
        send : in std_logic;
        reset : in std_logic;
        done : out std_logic
    );
end entity pulse_gen;

architecture rtl of pulse_gen is
    
    signal length_c : std_logic_vector (7 downto 0) := (others => '0');
    signal max_length : std_logic_vector (7 downto 0) := (others => '0');
    signal max_delay : std_logic_vector (7 downto 0) := (others => '0');
    signal delay_c : std_logic_vector (7 downto 0) := (others => '0');
    type SM is (IDLE, SEND_pulse, WAIT_delay, RESPOND);
    signal STATE : SM := IDLE;

begin

    process (clk)
    begin
        if reset = '1' then
            STATE <= IDLE;
            output <= '0';
        elsif rising_edge(clk) then
            case STATE is
                when IDLE =>
                    output <= '0';
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
    end process;

end rtl;
