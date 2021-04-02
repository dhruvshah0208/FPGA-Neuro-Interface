library ieee;
use ieee.std_logic_1164.all;

entity counter_test_bench is
end entity;

architecture Behave of counter_test_bench is
component ADC_interface is
	generic (wait_clock_cycles: integer := 100);
	port (
		clk, enable: in std_logic;
		DIN: out std_logic;
		SCLK: out std_logic;
		DOUT : in std_logic;
		CONVST: out std_logic;
		Data_read : out std_logic_vector(15 downto 0)
		);
end component ADC_interface;

	signal clk: std_logic := '0';
	signal enable: std_logic := '0';
	signal SCLK: std_logic;
	signal DOUT: std_logic := '1';
	signal DIN: std_logic;
	signal CONVST : std_logic;
	signal Data_read :std_logic_vector(15 downto 0);
begin

	clk <= not clk after 5 ns;
	process
	begin
		wait until clk = '1';
		enable <= '1';
		wait;	
	end process;

	dut: ADC_interface
		generic map (wait_clock_cycles => 50)
		port map (clk => clk, enable => enable, SCLK => SCLK, DOUT => DOUT, DIN => DIN, CONVST => CONVST, Data_read => Data_read);
end Behave;
