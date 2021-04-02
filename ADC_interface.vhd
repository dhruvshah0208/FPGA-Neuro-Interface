library ieee;
use ieee.std_logic_1164.all;

-- Machine will output a sequence from 1 to n and again from 1 to n
--
entity ADC_interface is
	generic (wait_clock_cycles: integer := 100);
	port (
		clk, enable: in std_logic;
		DIN: out std_logic;
		SCLK: out std_logic;
		DOUT : in std_logic;
		CONVST: out std_logic;
		Data_read : out std_logic_vector(15 downto 0)
		);
end entity ADC_interface;


architecture RtlBehavioural of ADC_interface is

	type FsmState is (OFF, DATA_CONV,DATA_OUTPUT);

	-- RTL machine control FSM state.
	signal fsm_state: FsmState;
	-- RTL machine registers.
	signal clk_counter_register: integer range 0 to wait_clock_cycles;
	signal CONVST_reg : std_logic;
	signal DIN_reg : std_logic;

begin

	process(clk, enable,clk_counter_register,CONVST_reg,DIN_reg,fsm_state)
		variable next_fsm_state_var: FsmState;
		variable next_CONVST_reg: std_logic;
		variable next_clock_counter_register: integer;

	begin

		-- default values of next state and register values.
		next_fsm_state_var := fsm_state;
		next_CONVST_reg := CONVST_reg;
		next_clock_counter_register:= clk_counter_register;

		-- next value computation for state, registers.
		case fsm_state is
			when OFF =>
				next_fsm_state_var := DATA_CONV;
				next_clock_counter_register:= 1;
				next_CONVST_reg := '1';
			when DATA_CONV =>
				if(clk_counter_register= wait_clock_cycles) then
					next_clock_counter_register:= 1;
					next_fsm_state_var := DATA_OUTPUT;
					next_CONVST_reg := '0';
				else 
					next_clock_counter_register:= clk_counter_register+ 1;
					next_CONVST_reg := '1';
				end if;
			when DATA_OUTPUT =>
				if(clk_counter_register= 16) then
					next_clock_counter_register:= 1;
					next_fsm_state_var := DATA_CONV;
					next_CONVST_reg := '1';
				else 
					next_clock_counter_register:= clk_counter_register+ 1;
					next_CONVST_reg := '0';
				end if;
				
		end case;

		-- output of the state machine.
		CONVST <= CONVST_reg;
		SCLK <= clk;
		-- state and register updates.
		if(clk'event and (clk = '1')) then -- posedge of clk --> perfrom state updates
			if(enable = '0') then
				clk_counter_register <= 0;
				DIN <= '0';
				fsm_state <= OFF;
			else
				clk_counter_register <= next_clock_counter_register;
				fsm_state <= next_fsm_state_var;
				DIN <= '0';
			end if;
		end if;
		
		if(clk'event and (clk = '0')) then -- negedge of clk
			if(enable = '0') then
				CONVST_reg <= '0';
			else
				CONVST_reg <= next_CONVST_reg;
				if(fsm_state = DATA_OUTPUT)then
					data_read(16 - clk_counter_register) <= DOUT;
				end if;
			end if;
		end if;
		
		
	end process;
end RtlBehavioural;
