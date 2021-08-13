library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.components.all;
entity top is
	port (
		--simulation--
		--	tck : in std_logic;
		--	tms : in std_logic;
		--	tdi : in std_logic;
		--	tdo : out std_logic;
		mclr : out std_logic := '0';
		send_led : out std_logic := '1';
		shld_buttons : out std_logic_vector(12 downto 0);
		shld_encA : out std_logic_vector(1 downto 0);
		shld_encB : out std_logic_vector(1 downto 0);
		shld_encS : out std_logic_vector(1 downto 0)
	);
end top;

architecture struct of top is

	signal reset : std_logic;
	signal jtdi : std_logic;
	signal jtck : std_logic;
	signal jshift : std_logic;
	signal jrstn : std_logic;
	signal jupdate : std_logic;
	signal jce : std_logic_vector(2 downto 1);
	signal jtdo : std_logic_vector(2 downto 1);
	signal jrti : std_logic_vector(2 downto 1);
	signal ready : std_logic;
	signal cmdin : std_logic_vector(47 downto 0);
	signal jtag2dec : std_logic := '0';
	signal dec2jtag : std_logic := '0';

	signal jreg : std_logic_vector(47 downto 0);
	signal jin : std_logic_vector(jreg'range) := (others => '0');
	signal jout : std_logic_vector(jreg'range);

	signal update_r : std_logic := '0';
	signal jtag2dec_r : std_logic := '0';
	signal jsync1 : std_logic := '0';
	signal jsync2 : std_logic := '0';
	signal jsync_d : std_logic := '0';
	signal esync1 : std_logic := '0';
	signal esync2 : std_logic := '0';
	component decoder is
		generic (
			SEED_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', others => '0');
			RESET_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 1 => '1', others => '0');
			PARAM_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 2 => '1', others => '0')
		);
		port (
			async_reset : in std_logic;
			cmdin : in std_logic_vector(47 downto 0);

			jtag2dec : in std_logic := '0';
			dec2jtag : out std_logic := '0';
			ready : out std_logic := '1';
			send_led : out std_logic := '1';
			shld_buttons : out std_logic_vector(12 downto 0);
			shld_encA : out std_logic_vector(1 downto 0);
			shld_encB : out std_logic_vector(1 downto 0);
			shld_encS : out std_logic_vector(1 downto 0)
		);
	end component;
begin

	mclr <= '0';
	JTAGF_inst : JTAGF
	generic map(
		ER1 => "ENABLED",
		ER2 => "ENABLED")
	port map(
		---simulation--
		--TCK => tck,
		--TMS => tms,
		--TDI => tdi,
		--TDO => tdo,
		TCK => '0',
		TMS => '0',
		TDI => '0',
		TDO => open,
		--
		JTDI => jtdi,
		JTCK => jtck,
		--
		JSHIFT => jshift,
		JUPDATE => jupdate,
		JRSTN => jrstn,
		--
		JRTI1 => jrti(1),
		JRTI2 => jrti(2),
		--
		JTDO1 => jtdo(1),
		JTDO2 => jtdo(2),
		--
		JCE1 => jce(1),
		JCE2 => jce(2));

	decoderinst : decoder
	generic map(
		SEED_COMMAND => (0 => '1', 7 => '1', others => '0'),
		RESET_COMMAND => (0 => '1', 7 => '1', 1 => '1', others => '0'),
		PARAM_COMMAND => (0 => '1', 7 => '1', 2 => '1', others => '0')
	)
	port map(

		async_reset => reset,
		cmdin => cmdin,
		jtag2dec => jtag2dec,
		dec2jtag => dec2jtag,
		ready => ready,
		send_led => send_led,
		shld_buttons => shld_buttons,
		shld_encA => shld_encA,
		shld_encB => shld_encB,
		shld_encS => shld_encS
	);

	er1_proc : process (jtck, jce(1))
	begin

		if falling_edge(jtck) then
			if jrstn = '0' then -- Test Logic Reset
				reset <= '0';
			elsif jce(1) = '1' then -- Capture/Shift DR
				if jshift = '1' then -- Shift DR
					jreg <= jtdi & jreg(jreg'high downto 1);
				else -- Capture DR
					jreg <= jin;
				end if;

			elsif jupdate = '1' then
				if jreg(47 downto 41) = "1000001" then
					jout <= jreg;
				end if;
			elsif jrti(1) = '1' then -- Run Test/Idle
				reset <= '1';
			else -- Last Bit
				jreg <= jtdi & jreg(jreg'high downto 1);
			end if;
		end if;
	end process;

	jtdo(1) <= jreg(0);
	jtag2dec <= jtag2dec_r;
	sync_proc : process (jtck)
	begin

		if falling_edge(jtck) then
			jsync1 <= dec2jtag;
			jsync2 <= jsync1;
			jsync_d <= jsync2;
			esync1 <= ready;
			esync2 <= esync1;
			if jrstn = '0' then -- Test Logic Reset
				jin <= (others => '1');
				jtag2dec_r <= '0';
				jsync1 <= '0';
				jsync2 <= '0';
				jsync_d <= '0';
				esync1 <= '1';
				esync2 <= '1';
				update_r <= '0';
			end if;
			if jsync_d = not(jsync2) then
				jin <= "100100100100100100100100100100100100100100100100";
			elsif jupdate = '1' then
				if jreg(47 downto 41) = "1000001" then
					jin <= "101010101010101010101010101010101010101010101010";
				end if;
			end if;
			if esync2 = '1' and update_r = '1' then
				cmdin <= jout;
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
end struct;
