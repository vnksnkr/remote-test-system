library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.components.ALL;


entity top is
	port (
	--simulation--
--	tck : in std_logic;
--	tms : in std_logic;
--	tdi : in std_logic;
--	tdo : out std_logic;
--	jtdo1 : out std_logic;
	--------------
	reset : in std_logic;
	signals : out std_logic_vector (18 downto 0) := (others => '1')
	);
end top;

architecture struct of top is


	
signal	jtdi :  std_logic;
signal	jtck :  std_logic;
signal	jshift :  std_logic;
signal	jrstn :  std_logic;
signal	jupdate :  std_logic;
signal	jce :  std_logic_vector(2 downto 1);
signal	jtdo :  std_logic_vector(2 downto 1);
signal	jrti :   std_logic_vector(2 downto 1);
signal ready : std_logic;
signal data : std_logic_vector(47 downto 0);
signal jtag2dec  : std_logic:= '0';
signal dec2jtag : std_logic:= '0';


	
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
		async_reset : in std_logic;
		data : in std_logic_vector(47 downto 0) ;
		signals : out std_logic_vector (18 downto 0) := (others => '1');
		-- response : out std_logic_vector (47 downto 0)
        jtag2dec  : in std_logic := '0';
        dec2jtag : out std_logic ;
        ready : out std_logic := '1'
	);
end component;


component jtag_ctrl is
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

end component;

begin

--simulation---
--jtdo1 <= jtdo(1);
		
    JTAGF_inst: JTAGF
	generic map (
	    ER1 => "ENABLED",
	    ER2 => "ENABLED" )
	port map (
	    ---simulation--
		--TCK => tck,
	    --TMS => tms,
	    --TDI => tdi,
	    --TDO => tdo,
		--TCK => '0',
		--TMS => '0',
		--TDI => '0',
		--TDO => open,
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
	    JCE2 => jce(2) );
		
	decoderinst : decoder
	generic map (
		SEED_COMMAND  =>  (0 => '1', 7 => '1', others => '0'),
		RESET_COMMAND =>  (0 => '1', 7 => '1', 1 => '1', others => '0'),
		PARAM_COMMAND =>  (0 => '1', 7 => '1', 2 => '1', others => '0')
	)
	port map (
	async_reset => reset,
	data => data,
	signals => signals,
	jtag2dec => jtag2dec,
	dec2jtag => dec2jtag,
	ready => ready
	);
	
	
	jtagctrlinst : jtag_ctrl
	port map (
	jtdi => jtdi,
	jtck => jtck,
	jshift => jshift,
	jrstn => jrstn,
	jupdate => jupdate,
	jce => jce,
	jtdo => jtdo,
	jrti => jrti,
	dec2jtag => dec2jtag,
	jtag2dec => jtag2dec,
	ready => ready,
	cmd => data
	);
	
end struct;