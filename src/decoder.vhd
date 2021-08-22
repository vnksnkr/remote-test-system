----------------------------------------------------------------------------
--  decoder.vhd
--	Instruction Decoder for Remote Test System
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
library machxo2;
use machxo2.all;

entity decoder is
	generic (
		SEED_COMMAND  : std_logic_vector(4 downto 0) := "10011";
		RESET_COMMAND : std_logic_vector(4 downto 0) := "10100";
		PARAM_COMMAND : std_logic_vector(4 downto 0) := "10101"
	);
	port (
		async_reset : in std_logic;
		cmdin : in std_logic_vector(37 downto 0);

		jtag2dec : in std_logic := '0';
		dec2jtag : out std_logic := '0';
		ready : out std_logic := '1';
		send_led : out std_logic := '1';

		shld_buttons : out std_logic_vector(12 downto 0);
		shld_encA : out std_logic_vector(1 downto 0);
		shld_encB : out std_logic_vector(1 downto 0);
		shld_encS : out std_logic_vector(1 downto 0)

	);
end entity;

architecture rtl of decoder is

	signal cmd : std_logic_vector(37 downto 0);
	signal seed : std_logic_vector(12 downto 0);

	--output control--
	signal terminal_addr : std_logic_vector (4 downto 0);

	--signalgen and encoder--
	signal send_signals : std_logic := '0';
	signal push_button : std_logic := '0';
	signal turn_knob : std_logic := '0';
	signal frequency_div : std_logic_vector (21 downto 0);
	signal pulse_no : std_logic_vector (5 downto 0);

	signal reset_encoder : std_logic := '0';
	signal reset_button : std_logic := '0';
	signal reset_bounce : std_logic := '0';

	signal is_enc : std_logic;
	signal button_clean : std_logic := '1';
	signal encA_clean : std_logic := '1';
	signal encB_clean : std_logic := '1';
	signal button_or_encA_clean : std_logic := '1';

	signal button_done : std_logic := '0';
	signal enc_done : std_logic := '0';
	signal done : std_logic := '0';

	signal button_bounce_done : std_logic;
	signal encB_bounce_done : std_logic;

	signal button_or_encA : std_logic := '1';
	signal enc_B : std_logic := '1';

	type SM is (IDLE, DECODE, LOAD_SEED, LOAD_PARAM, SEND, WAIT_FOR_BOUNCE, RESET, DELAY);
	signal STATE : SM := IDLE;

	signal delay_count : integer := 0;

	signal jtag2dec_sync1 : std_logic := '0';
	signal jtag2dec_sync2 : std_logic := '0';
	signal jtag2dec_sync3 : std_logic := '0';
	signal dec2jtag_r : std_logic := '0';

	--clock--
	signal osc_inst : std_logic;
	signal stdby_sed : std_logic;
	signal clk : std_logic;
	attribute NOM_FREQ : string;
	attribute NOM_FREQ of OSCinst0 : label is "2.56";

	component osch
		generic (NOM_FREQ : string := "2.56");
		port (
			STDBY : in std_logic;
			OSC : out std_logic;
			SEDSTDBY : out std_logic);
	end component;

	component signal_gen is
		port (
			clk : in std_logic;
			send : in std_logic;
			reset : in std_logic;
			frequency_div : in std_logic_vector(21 downto 0);
			pulse_no : in std_logic_vector(5 downto 0);
			output : out std_logic := '1';
			done : out std_logic := '0'
		);
	end component;

	component bounce_generator is
		port (
			reset : in std_logic;
			clk : in std_logic;
			input : in std_logic;
			is_enc : in std_logic;
			seed : in std_logic_vector(12 downto 0);
			output : out std_logic;
			done : out std_logic
		);
	end component;
	component encoder is
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
	end component;
	component demux is
		port (
			addr : in std_logic_vector(4 downto 0);
			input_A : in std_logic := '1';
			input_B : in std_logic := '1';
			shld_buttons : out std_logic_vector(12 downto 0);
			shld_encA : out std_logic_vector(1 downto 0);
			shld_encB : out std_logic_vector(1 downto 0);
			shld_encS : out std_logic_vector(1 downto 0)
		);
	end component;

begin
	button_or_encA_clean <= encA_clean and button_clean;
	done <= button_done or enc_done;
	dec2jtag <= dec2jtag_r;
	is_enc <= terminal_addr(4);

	OSCinst0 : OSCH
	generic map(
		NOM_FREQ => "2.56")

	port map(
		STDBY => '0', OSC => clk, SEDSTDBY => open);
	demux_inst0 : demux port map
	(
		addr => terminal_addr,
		input_A => button_or_encA,
		input_B => enc_B,
		shld_buttons => shld_buttons,
		shld_encA => shld_encA,
		shld_encB => shld_encB,
		shld_encS => shld_encS
	);

	signalinst0 : signal_gen
	port map(
		clk => clk,
		send => push_button,
		reset => reset_button,
		frequency_div => frequency_div,
		pulse_no => pulse_no,
		output => button_clean,
		done => button_done
	);

	encoderinst0 : encoder
	port map(
		clk => clk,
		send => turn_knob,
		reset => reset_encoder,
		frequency_div => frequency_div,
		pulse_no => pulse_no,
		enc_A => encA_clean,
		enc_B => encB_clean,
		done => enc_done
	);

	bounceinst0 : bounce_generator
	port map(
		reset => reset_bounce,
		clk => clk,
		input => button_or_encA_clean,
		is_enc => is_enc,
		seed => seed,
		output => button_or_encA,
		done => button_bounce_done
	);

	bounceinst1 : bounce_generator
	port map(
		reset => reset_bounce,
		clk => clk,
		input => encB_clean,
		is_enc => '1',
		seed => seed,
		output => enc_B,
		done => encB_bounce_done
	);
	process (clk, async_reset)
	begin
		if async_reset = '0' then
			STATE <= RESET;
			send_led <= '1';
			terminal_addr <= "11111";
		elsif rising_edge(clk) then
			jtag2dec_sync1 <= jtag2dec;
			jtag2dec_sync2 <= jtag2dec_sync1;
			jtag2dec_sync3 <= jtag2dec_sync2;
			case STATE is
				when IDLE =>
					send_led <= '1';
					if jtag2dec_sync3 = not(jtag2dec_sync2) then
						STATE <= DECODE;
						cmd <= cmdin;
					else
						STATE <= IDLE;
					end if;

				when DECODE =>
					send_led <= '1';
					dec2jtag_r <= not(dec2jtag_r);
					if cmd(4 downto 0) = SEED_COMMAND then 
						STATE <= LOAD_SEED;
						ready <= '0';
					elsif cmd(4 downto 0) = RESET_COMMAND then
						STATE <= RESET;
						ready <= '0';
					elsif cmd(4 downto 0) = PARAM_COMMAND then
						STATE <= LOAD_PARAM;
						ready <= '0';
					else
						STATE <= IDLE;
					end if;

				when LOAD_SEED =>
					send_led <= '1';
					ready <= '1';
					seed <= cmd(17 downto 5);
					reset_bounce <= '1';
					STATE <= IDLE;
				when LOAD_PARAM =>
					send_led <= '1';
					reset_encoder <= '0';
					reset_button <= '0';
					reset_bounce <= '0';
					terminal_addr <= cmd(9 downto 5);
					frequency_div <= cmd(31 downto 10);
					pulse_no <= cmd(37 downto 32);
					if cmd(37 downto 32) = "000000" then
						STATE <= DELAY;
						delay_count <= 0;
					else
						STATE <= SEND;
						send_signals <= '1';
					end if;

				when SEND =>
					send_led <= '0';
					if done = '1' then
						STATE <= WAIT_FOR_BOUNCE;
						reset_encoder <= '1';
						reset_button <= '1';
						turn_knob <= '0';
						push_button <= '0';
					else
						if send_signals = '1' then
							turn_knob <= terminal_addr(4);
							push_button <= not(terminal_addr(4));
							send_signals <= '0';
						else
							turn_knob <= '0';
							push_button <= '0';
						end if;
						STATE <= SEND;
					end if;

				when WAIT_FOR_BOUNCE =>
					send_led <= '0';
					if (button_bounce_done  = '1' and terminal_addr(4) = '0')   or encB_bounce_done = '1' then
						ready <= '1';
						STATE <= IDLE;
					else
						ready <= '0';
						STATE <= WAIT_FOR_BOUNCE;
					end if;

				when RESET =>
					send_led <= '1';
					ready <= '1';
					reset_bounce <= '1';
					reset_button <= '1';
					reset_encoder <= '1';
					jtag2dec_sync1 <= '0';
					jtag2dec_sync2 <= '0';
					jtag2dec_sync3 <= '0';
					STATE <= IDLE;
					
				when DELAY =>
					send_led <= '1';
					if delay_count = unsigned(frequency_div) then
						STATE <= IDLE;
						ready <= '1';
					else
						delay_count <= delay_count + 1;
						STATE <= DELAY;
					end if;
			end case;
		end if;
	end process;

end rtl;
