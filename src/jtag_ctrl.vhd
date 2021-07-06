library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.components.ALL;


entity jtag_ctrl is
    port  (
		jtdi : in std_logic;
		jtck : in std_logic;
		jshift : in std_logic;
		jrstn : in std_logic;
		jupdate : in std_logic;
		jce : in std_logic_vector(2 downto 1);
		jtdo : out std_logic_vector(2 downto 1);
		jrti :  in std_logic_vector(2 downto 1);
		
        dec2jtag : in std_logic;
        jtag2dec : out std_logic := '0';
        ready : in std_logic;
        cmd  :  out std_logic_vector(47 downto 0)
    );

end entity;

architecture rtl of jtag_ctrl is

    signal jreg : std_logic_vector(47 downto 0);
    signal jin : std_logic_vector(jreg'range);
	signal jout : std_logic_vector(jreg'range);
	
    signal update_r : std_logic := '0';
    signal jtag2dec_r : std_logic:= '0';
    signal jsync1 : std_logic;
    signal jsync2 : std_logic;
    signal jsync_d : std_logic;
    signal esync1 : std_logic;
    signal esync2 : std_logic;

begin




    er1_proc : process(jtck, jce(1))
    begin
    if falling_edge(jtck) then
        if jrstn = '0' then		-- Test Logic Reset

        elsif jce(1) = '1' then	-- Capture/Shift DR
        if jshift = '1' then	-- Shift DR
            jreg <= jtdi & jreg(jreg'high downto 1);

        else			-- Capture DR
            jreg <= jin;
        end if;

        elsif jupdate = '1' then
        if jreg(47 downto 41) = "1000001" then
		jout <= jreg;
        end if;


        elsif jrti(1) = '1' then	-- Run Test/Idle

        else			-- Last Bit
        jreg <= jtdi & jreg(jreg'high downto 1);
        end if; 
    end if;
    end process;

    jtdo(1) <= jreg(0);
    jtag2dec <= jtag2dec_r;
    sync_proc : process(jtck)
    begin
        if falling_edge(jtck) then
            jsync1 <= dec2jtag;
            jsync2 <= jsync1;
            jsync_d <= jsync2;
            esync1 <= ready;
            esync2 <= esync1;
            if jsync_d = not(jsync2) then
                jin <= (others => '1');
			elsif jupdate = '1' then
			if jreg(47 downto 41) = "1000001" then
				jin <= (others => '0');
            end if;
			end if;
            if esync2 = '1' and update_r = '1' then
                cmd <= jout;
				jtag2dec_r <= not(jtag2dec_r);
			end if;
            if esync2 = '1' and update_r = '1' then    
				update_r <= '0';
			elsif jupdate = '1' then
			if jreg(47 downto 41) = "1000001" then	
				update_r <= '1';
			end if;
            end if;
        end if;
    end process;


end rtl;