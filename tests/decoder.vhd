library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.all;

entity decoder is
	generic (
		SEED_COMMAND  : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', others => '0');
		RESET_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 1 => '1', others => '0');
		PARAM_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 2 => '1', others => '0')
	);
	port (
--		clk : in std_logic;
		async_reset : in std_logic;
		data : in std_logic_vector(47 downto 0) ;
		
        jtag2dec  : in std_logic := '0';
        dec2jtag : out std_logic := '0';
        ready : out std_logic := '1';
		reset_led : out std_logic := '1';
		seed_led : out std_logic :=  '1';
		send_led : out std_logic :=  '1';
		delay_led : out std_logic := '1'
	);
end entity;

architecture rtl of decoder is


	signal signals : std_logic_vector (18 downto 0) := (others => '1');
    signal data_d :  std_logic_vector(47 downto 0);
	--seeds--
--	signal seed_duration : std_logic_vector(12 downto 0);
	signal seed_length : std_logic_vector(12 downto 0);
--	signal seed_delay : std_logic_vector(12 downto 0);

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

	type SM is (IDLE,DECODE,LOAD_SEED,LOAD_PARAM,SEND,WAIT_FOR_BOUNCE,RESET,DELAY);
	signal STATE : SM := IDLE;

	signal delay_count : integer := 0;
	
    signal jsync1 : std_logic := '0';
	signal jsync2 : std_logic := '0';
	signal jtag2dec_d : std_logic := '0';
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
			--seed_duration : in std_logic_vector(12 downto 0);
			seed_length : in std_logic_vector(12 downto 0);
			--seed_delay : in std_logic_vector(12 downto 0);
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
            addr    : in std_logic_vector(4 downto 0);
            input_A : in std_logic;
            input_B : in std_logic;
            output  : out std_logic_vector(18 downto 0)
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
        output => signals
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
--		seed_duration => seed_duration,
		seed_length => seed_length,
	--	seed_delay => seed_delay,
		output => button_or_encA,
		done => button_bounce_done
	);

	bounceinst1 : bounce_generator
	port map(
		reset => reset_bounce,
		clk => clk,
		input => encB_clean,
		is_enc => '1', 
		--seed_duration => seed_duration,
		seed_length => seed_length,
		--seed_delay => seed_delay,
		output => enc_B,
		done => encB_bounce_done
	);
	process (clk,async_reset)
	begin
		if async_reset = '0' then
			STATE <= RESET;
			seed_led  <= '1';
			send_led  <= '1';			
			delay_led <= '1';
		elsif rising_edge(clk) then
            jsync1 <= jtag2dec;
			jsync2 <= jsync1;
			jtag2dec_d <= jsync2;
			case STATE is
				when IDLE =>
					 delay_led <= '0';
                    reset_bounce <= '0';
                    reset_encoder <= '1';
                    reset_button <= '1';
                    if jtag2dec_d = not(jsync2) then
                        STATE <= DECODE;
                        data_d <= data;
                    else
                        STATE <= IDLE;
                    end if;
                
                when DECODE =>
					reset_led <= '1';
					seed_led  <= '1';
					send_led  <= '1';			
					delay_led <= '1';
					if data_d(47 downto 41) = "1000001" then
                    dec2jtag_r <= not(dec2jtag_r);
                    if data_d(7 downto 0) = SEED_COMMAND then
                        STATE <= LOAD_SEED;
						ready <= '0';
                    elsif data_d(7 downto 0) = RESET_COMMAND then
                        STATE <= RESET;
						ready <= '0';
                    elsif data_d(7 downto 0) = PARAM_COMMAND then
                        STATE <= LOAD_PARAM;
						ready <= '0';
					else 
						STATE <= IDLE;
                    end if;
					end if;
                when LOAD_SEED =>
					seed_led <= '0';
                    ready <= '1';
					seed_length <= data_d(20 downto 8);
					--seed_length <= data_d(33 downto 21);
					--seed_delay <= data_d(46 downto 34);
                    STATE <= IDLE;
					reset_bounce <= '1';
                
                when LOAD_PARAM =>
					send_led <= '0';
                    reset_encoder <= '0';
                    reset_button <= '0';
                    terminal_addr <= data_d(12 downto 8);
                    frequency_div <= data_d(34 downto 13);
                    pulse_no <= data_d(40 downto 35);
					if data_d(40 downto 35) = "000000" then
					STATE <= DELAY;
					delay_led <= '1';
					delay_count <= 0;
					else
                    STATE <= SEND;
					send_signals <= '1';
					end if;
					

                when SEND =>
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
					if button_bounce_done  = '1' or encB_bounce_done = '1' then
						ready <= '1';
						STATE <= IDLE;
					else
						ready <= '0';
						STATE <= WAIT_FOR_BOUNCE;
					end if;
                when RESET =>
					reset_led <= '0';
                    ready <= '1';
                    reset_bounce <= '1';
                    reset_button <= '1';
                    reset_encoder <= '1';
					jsync1 <= '0';
					jsync2 <= '0';
					jtag2dec_d <= '0';
                    STATE <= IDLE;
				when DELAY =>
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