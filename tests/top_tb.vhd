library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library machxo2;
use machxo2.components.ALL;


entity top_tb is
end entity;

architecture sim of top_tb is


component JTAGF is
    generic(
        ER1             : string  := "ENABLED";
        ER2             : string  := "ENABLED"
		);
    port(
        TCK             : in     std_logic;
        TMS             : in     std_logic;
        TDI             : in     std_logic;
        TDO             : out    std_logic;
        JTDO1           : in     std_logic;
        JTDO2           : in     std_logic;
        JTDI            : out    std_logic;
        JTCK            : out    std_logic;
        JRTI1           : out    std_logic;
        JRTI2           : out    std_logic;
        JSHIFT          : out    std_logic;
        JUPDATE         : out    std_logic;
        JRSTN           : out    std_logic;
        JCE1            : out    std_logic;
        JCE2            : out    std_logic
    );
end component;

component top is
	port (
	tck : in std_logic;
	tms : in std_logic;
	tdi : in std_logic;
	tdo : out std_logic;
	jtdo1 : out std_logic;
	reset : in std_logic;
	signals : out std_logic_vector (18 downto 0) := (others => '1')
	);
end component;

signal recivedir : std_logic_vector(7 downto 0):= (others => '0');
signal ircnt : integer := 0;
signal ir : std_logic_vector(7 downto 0):= "00110010";
signal drcnt : integer := 0;
signal RESET_CMD : std_logic_vector(47 downto 0):= (47 => '1',41 => '1',0 => '1', 7 => '1', 1 => '1', others => '0');
signal SEED_CMD : std_logic_vector(47 downto 0):= (47 => '1',41 => '1',0 => '1', 7 => '1',15=>'0',16=>'1',others => '0');
signal PARAM_CMD : std_logic_vector(47 downto 0):= (47 => '1',41 => '1',0 => '1', 7 => '1', 2 => '1',26=>'1',35=>'1',others => '0');
signal signals : std_logic_vector( 18 downto 0 );
signal reset : std_logic;
signal tck : std_logic := '0';
signal tms : std_logic;
signal tdi : std_logic;
signal tdo : std_logic;
signal jtdo1 : std_logic;
signal jtdo2 : std_logic;
signal jtdi : std_logic;
signal jtck : std_logic;
signal jrti1 : std_logic;
signal jrti2 : std_logic;
signal jshift : std_logic;
signal jupdate : std_logic;
signal jrstn : std_logic;
signal jce1 : std_logic;
signal jce2 : std_logic;
signal state : integer := 0;
signal sam_tck : std_logic := '0';
signal shift : std_logic := '0';
signal send_next : std_logic := '0';

procedure tck_toggle (signal tck : out std_logic) is
begin
	wait for 10 ns;
	tck <= '1';
	wait for 10 ns;
	tck <= '0';
end procedure;

procedure tap_reset (signal tck : out std_logic;
signal tms : out std_logic) is
begin
	tms <= '1';
	for i in 0 to 4 loop	
	tck_toggle(tck);
	end loop;
end procedure;
		
procedure shift_ir ( signal ir : in std_logic_vector(7 downto 0);
signal tck : out std_logic;
signal tdi : out std_logic;
signal tms : out std_logic) is
begin
	for i in 0 to 7 loop
	tms <= '0';
	tdi <= ir(i);
	if i = 7 then
	tms <= '1';
	end if;
	tck_toggle(tck);
	tdi <= 'Z';
end loop;
end procedure;

procedure shift_dr ( signal dr : in std_logic_vector(47 downto 0);
signal tck : out std_logic;
signal tdi : out std_logic;
signal tms : out std_logic) is
begin
	for i in 0 to 47 loop
	tms <= '0';
	tdi <= dr(i);
	if i = 47 then
	tms <= '1';
	end if;
	tck_toggle(tck);
	tdi <= 'Z';
end loop;
end procedure;

procedure wait_before_next_command (
signal tdo : in std_logic;
signal tms : out std_logic;signal tck : out std_logic;
signal send_next : inout std_logic;
signal tdi : out std_logic
) is
begin
		while send_next = '0' loop
		tms <= '0';
		tck_toggle(tck);
		tms <= '0';
		tck_toggle(tck);
		tdi <= '0';
		tms <= '0';
		tck_toggle(tck);
		if tdo = '1' then
		send_next <= '1';
		end if;
		tms <= '0';
		tdi <= '0';
		tck_toggle(tck);
		if tdo = '1' then
		send_next <= '1';
		end if;
		tms <= '1';
		tck_toggle(tck);
		tms <= '1';
		tck_toggle(tck);
		tms <= '1';
		tck_toggle(tck);
		end loop;
end procedure;

begin
	topinst : top
		port map(
		tck => tck,
		tms => tms,
		tdi => tdi,
		tdo => tdo,
		jtdo1 => jtdo1,
		reset => reset,
		signals => signals);
		
	JTAGFsim : JTAGF
		port map(
		tck => tck,
		tms => tms,
		tdi => tdi,
		tdo => tdo,
		jtdo1 => jtdo1,
		jtdo2 => jtdo2,
		jtdi => jtdi,
		jtck => jtck,
		jrti1=>jrti1,
		jrti2=>jrti2,
		jshift=>jshift,
		jupdate=>jupdate,
		jrstn=>jrstn,
		jce1 => jce1,
		jce2 => jce2 );
		

		process
		begin
			tdi <= 'Z';
			tms <= '0';
			for i in 0 to 20 loop
			tck_toggle(tck);
			end loop;
			tap_reset(tck,tms);
			wait for 50 ns;
			
	        tms     <= '0';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '0';
			tck_toggle(tck);
			tms     <= '0';
			tck_toggle(tck);
			shift_ir(ir, tck, tdi, tms);
	        tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '0';
			tck_toggle(tck);
			tms     <= '0';
			tck_toggle(tck);
			shift_dr(RESET_CMD,tck,tdi,tms);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			
			tms <= '0';
			tck_toggle(tck);
			tms <= '0';
			tck_toggle(tck);
			tdi <= '0';
			tck_toggle(tck);
			tms <= '1';
			tck_toggle(tck);
			tms <= '1';
			tck_toggle(tck);
			tms <= '1';
			tck_toggle(tck);			
			
			wait_before_next_command(tdo,tms,tck,send_next,tdi);
			send_next <= '0';
				
			shift_dr(SEED_CMD,tck,tdi,tms);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			wait_before_next_command(tdo,tms,tck,send_next,tdi);
			send_next <= '0';
			
			shift_dr(PARAM_CMD,tck,tdi,tms);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			wait_before_next_command(tdo,tms,tck,send_next,tdi);
			send_next <= '0';
			
			PARAM_CMD <= (47 => '1',41 => '1',0 => '1', 7 => '1', 2 => '1',26=>'1',36=> '1',35=>'1',12 => '1',others => '0');
			shift_dr(PARAM_CMD,tck,tdi,tms);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			wait_before_next_command(tdo,tms,tck,send_next,tdi);
			send_next <= '0';
			
			PARAM_CMD <= (47 => '1',41 => '1',0 => '1', 7 => '1', 2 => '1',27=>'1',12 => '1',8=>'1',others => '0');
			shift_dr(PARAM_CMD,tck,tdi,tms);
			tms     <= '1';
			tck_toggle(tck);
			tms     <= '1';
			tck_toggle(tck);
			wait_before_next_command(tdo,tms,tck,send_next,tdi);
			send_next <= '0';
			
			
--			PARAM_CMD <= (47 => '1',41 => '1',0 => '1', 7 => '1', 2 => '1',26=>'1',36=> '1',35=>'1',12 => '1',8=>'1',others => '0');
--			shift_dr(PARAM_CMD,tck,tdi,tms);
--			tms     <= '1';
--			tck_toggle(tck);
--			tms     <= '1';
--			tck_toggle(tck);
--			wait_before_next_command(tdo,tms,tck,send_next,tdi);
--			send_next <= '0';
			
			
			
			wait for 100 ns;
			wait;
		end process;
end ;