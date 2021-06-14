library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end top_tb;


architecture rtl of top_tb is
    signal reset : std_logic := '0';
    signal enc : std_logic := '0';
	signal button : std_logic := '0';
	signal component_addr : std_logic_vector(4 downto 0);
    signal frequency_div : std_logic_vector (15 downto 0):=(others => '0'); --output frequency = input frequency/2^(frequency_div+1)
    signal pulse_no : std_logic_vector (5 downto 0):=(others => '0');
    
	signal seed_duration : std_logic_vector(12 downto 0);
	signal seed_length :  std_logic_vector(12 downto 0);
	signal seed_delay :  std_logic_vector(12 downto 0);
	
	
	signal button_or_encA : std_logic;
	signal enc_B : std_logic;
	signal done : std_logic;

    component top is
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
    end component;

begin

    top_inst : top
    port map (
	reset => reset,
	enc => enc,
	button => button,
	component_addr => component_addr,
	frequency_div => frequency_div,
	pulse_no => pulse_no,
	seed_duration => seed_duration,
	seed_length => seed_length,
	seed_delay => seed_delay,
	enc_B => enc_B,
	button_or_encA => button_or_encA,
	done => done
    );


    process begin
        frequency_div <= "0000000001000000";
        pulse_no <= "010100";

		button <= '0';
		seed_duration  <= "0000000000111";
		seed_length <= "0000001111001";
		seed_delay  <= "0000000001000";
        reset <= '1';
		wait for 1000 ns;
        reset <= '0';
		enc <= '1';
        wait for 510 ns;
        enc <= '0';
        wait;
    end process;
    end rtl;