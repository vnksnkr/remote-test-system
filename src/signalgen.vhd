----------------------------------------------------------------------------
--  signalgen.vhd
--	Signal Generator
--
--  Copyright (C) Vinayak Sankar
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	3 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity signal_gen is
    port (
        clk : in std_logic;
        send : in std_logic;
        reset : in std_logic;
        frequency_div : in std_logic_vector(21 downto 0);
        pulse_no : in std_logic_vector(5 downto 0);
        output : out std_logic := '1';
        done : out std_logic := '0'
    );
end entity;

architecture rtl of signal_gen is
    signal clkcnt : integer := 0;
    signal pulse_count : integer := 0;
    signal r_output : std_logic := '1';
    type SM is (IDLE, SEND_pulse);
    signal STATE : SM := IDLE;

begin
    output <= r_output;
    process (clk, reset)
    begin
        if reset = '1' then
            r_output <= '1';
            clkcnt <= 0;
            pulse_count <= 0;
            STATE <= IDLE;
            done <= '0';
        elsif rising_edge(clk) then
            case STATE is
                when IDLE =>
                    if send = '1' then
                        STATE <= SEND_pulse;
                        clkcnt <= 0;
                        pulse_count <= 0;
                        r_output <= '0';
                        done <= '0';
                    else
                        STATE <= IDLE;
                        r_output <= '1';
                    end if;

                when SEND_pulse =>
                    if pulse_count = unsigned(pulse_no) then
                        STATE <= IDLE;
                    else
                        if clkcnt = unsigned(frequency_div) then
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
                    if pulse_count = unsigned(pulse_no) then
                        done <= '1';
                    end if;
            end case;
        end if;
    end process;
end rtl;
