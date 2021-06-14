library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.all;


entity top is
	port (
		reset : in std_logic;
		
		enc : in std_logic;
		button : in std_logic;
		component_addr : in std_logic_vector(4 downto 0);
		
		frequency_div : in std_logic_vector(15 downto 0) := (others => '0');
		pulse_no : in std_logic_vector(5 downto 0)  := (others => '0');
        
		seed_duration : in std_logic_vector(12 downto 0) ;
		seed_length   : in std_logic_vector(12 downto 0) ;
		seed_delay    : in std_logic_vector(12 downto 0) ;
		

		enc_B : out std_logic;
		button_or_encA  : out std_logic;
		done : out std_logic := '0'
		
	);
end entity;
	
architecture rtl of top is

attribute NOM_FREQ : string;
attribute NOM_FREQ of OSCinst0 : label is "2.56";
signal button_clean : std_logic := '1';
signal encA_clean : std_logic := '1';
signal encB_clean : std_logic := '1';
signal button_done : std_logic := '0';
signal enc_done : std_logic := '0';
signal osc_inst : std_logic;
signal stdby_sed : std_logic;
signal clk : std_logic;
signal borenc_clean : std_logic := '1';


component osch
generic (NOM_FREQ: string := "2.56");
port (STDBY : in std_logic;
OSC : out std_logic ;
SEDSTDBY : out std_logic);
end component;

component signal_gen is
    port (
        clk : in std_logic;
        send : in std_logic;
        reset : in std_logic;
        frequency_div : in std_logic_vector(15 downto 0) := (others => '0');
        pulse_no : in std_logic_vector(5 downto 0)  := (others => '0');
        output : out std_logic := '1';
        done : out std_logic := '0'
    );
end component;

component bounce_generator is
    port (
        reset : in std_logic;
        clk   : in std_logic;
        input : in std_logic;
        seed_duration : in std_logic_vector(12 downto 0) ;
        seed_length   : in std_logic_vector(12 downto 0) ;
        seed_delay    : in std_logic_vector(12 downto 0) ;
        output : out std_logic
    );
end component;	


component encoder is
    port (
        clk : in std_logic;
        send : in std_logic;
        reset : in std_logic;
        frequency_div : in std_logic_vector(15 downto 0) := (others => '0');
        pulse_no : in std_logic_vector(5 downto 0)  := (others => '0');
        enc_A : out std_logic := '1';
        enc_B : out std_logic := '1';
        done : out std_logic := '0'
    );
end component;

begin
	
	borenc_clean <= encA_clean and button_clean;
	done <= button_done or enc_done;
	
	OSCinst0 : OSCH
	generic map (
	NOM_FREQ => "2.56")
	
	port map (
	STDBY => '0',OSC => clk ,SEDSTDBY => OPEN);
	
	signalinst0 : signal_gen 
	port map (
	clk => clk,
	send => button,
	reset => reset,
	frequency_div => frequency_div,
	pulse_no => pulse_no,
	output => button_clean,
	done => button_done
	);
	
	encoderinst0 : encoder
	port map (
	clk => clk,
	send => enc,
	reset => reset,
	frequency_div => frequency_div,
	pulse_no => pulse_no,
	enc_A => encA_clean,
	enc_B => encB_clean,
	done => enc_done
	);
	
	bounceinst0 : bounce_generator
	port map (
	reset => reset,
	clk => clk,
	input => borenc_clean,
	seed_duration => seed_duration,
	seed_length => seed_length,
	seed_delay => seed_delay,
	output => button_or_encA
	);
	
	bounceinst1 : bounce_generator
	port map (
	reset => reset,
	clk => clk,
	input => encB_clean,
	seed_duration => seed_duration,
	seed_length => seed_length,
	seed_delay => seed_delay,
	output => enc_B
	);
	

end rtl;






















	