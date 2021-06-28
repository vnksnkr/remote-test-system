library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
end entity;


architecture rtl of testbench is

		signal r_data : std_logic_vector(47 downto 0) ;
		signal data : std_logic_vector(47 downto 0) ;
		signal signals : std_logic_vector (18 downto 0) := (others => '1');
		-- response : out std_logic_vector (47 downto 0)
        signal jtag2dec  :   std_logic := '0';
        signal dec2jtag :  std_logic ;
        signal ready :		 std_logic := '1';
		
	component decoder is
	generic (
		SEED_COMMAND  : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', others => '0');
		RESET_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 1 => '1', others => '0');
		PARAM_COMMAND : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 2 => '1', others => '0')
		-- NEXT_COMMAND  : std_logic_vector(7 downto 0) := (0 => '1', 7 => '1', 2 => '1', 1 => '1', others => '0');
		-- WAITING 	  : std_logic_vector(7 downto 0) :=  (0 => '0', 7 => '0', others => '1');
		-- DONE_COMMAND  : std_logic_vector(7 downto 0) :=  (0 => '0', 7 => '0', 1 => '0', others => '1')
	);
	port (
		data : in std_logic_vector(47 downto 0) ;
		signals : out std_logic_vector (18 downto 0) := (others => '1');
		-- response : out std_logic_vector (47 downto 0)
        jtag2dec  : in std_logic := '0';
        dec2jtag : out std_logic := '0';
        ready : out std_logic := '1'	);
	end component;
begin

decoder_inst0 : decoder 
port map (
	data => data,
	signals => signals,
	jtag2dec => jtag2dec,
	dec2jtag => dec2jtag,
	ready => ready);
	
	process begin
	wait for 1000 ns;
	data <= (0 => '1', 7 => '1', 1 => '1', others => '0'); --reset
	jtag2dec <= not(jtag2dec);
	wait until rising_edge(dec2jtag) or falling_edge(dec2jtag);
	
	data <= (0 => '1', 7 => '1',15=>'0',16=>'1',others => '0'); --seed
	wait until ready = '1';
	jtag2dec <= not jtag2dec;
	wait until rising_edge(dec2jtag) or falling_edge(dec2jtag);
	
	data <= (0 => '1', 7 => '1', 2 => '1',26=>'1',35=>'1',others => '0'); --button
	wait until ready = '1';
	jtag2dec <= not jtag2dec;
	
	wait until rising_edge(dec2jtag) or falling_edge(dec2jtag);
	data <= (0 => '1', 7 => '1', 2 => '1',34 => '1',35 => '1',others => '0');
	data(12 downto 8) <= "10000";
	wait until ready = '1';
	jtag2dec <= not jtag2dec;
	
	wait until rising_edge(dec2jtag) or falling_edge(dec2jtag);
	data <= (0 => '1', 7 => '1', 2 => '1',26=>'1',35=>'1',others => '0');
	wait until ready = '1';
	jtag2dec <= not jtag2dec;
	
	wait until rising_edge(dec2jtag) or falling_edge(dec2jtag);
	data <= (0 => '1', 7 => '1', 2 => '1',26=>'1',35=>'1',others => '0');
	wait until ready = '1';
	jtag2dec <= not jtag2dec;
	wait;
	end process;
	
end rtl;
	
	

