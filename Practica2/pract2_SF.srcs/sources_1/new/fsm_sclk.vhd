library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
USE ieee.numeric_std.ALL;


entity fsm_sclk is
Generic(g_freq_SCLK_KHZ : INTEGER := 1500000; -- Frequency in KHz of the synchronous generated clk
		g_system_clock : INTEGER := 100000000 --Frequency in KHz of the system clk
		);
 Port (start, clk, rst_n: in std_logic;
       SCLK, SCLK_rise, SCLK_fall:out std_logic);
end fsm_sclk;

architecture Behavioral of fsm_sclk is
	CONSTANT c_half_T_SCLK :INTEGER := INTEGER(floor(real(g_system_clock)/real(g_freq_SCLK_KHZ))); --constant value to compare and generate the rising/falling edge 
	CONSTANT c_counter_width : INTEGER := INTEGER(ceil(log2(real(c_half_T_SCLK))));
	
	type state_type is (S0,S1,S2);
    signal CS, NS : state_type;
    
	signal CNT: unsigned (c_counter_width-1 downto 0);
	signal time_elapsed : std_logic;
	signal enable_count: std_logic ;

begin

    States: process (clk, rst_n)begin
		if (rst_n = '0') then
			CS <= S0;
		elsif rising_edge(clk) then
			CS<= NS;
		end if;
	end process;
	
	Counter:process (clk, rst_n)
	begin
		if(rst_n= '0') then 
			CNT <= (others  => '0');
			time_elapsed <= '0';
		elsif(rising_edge(clk)) then
			if(enable_count = '1')then
				if(CNT < c_half_T_SCLK)then 
					CNT <= CNT + 1;
					time_elapsed <=  '0';
				else 
					time_elapsed <= '1';
					CNT <= (others  => '0');
				end if;
			else 
				CNT <= (others  => '0');
				time_elapsed <= '0';
			end if;
		end if;
	end process;

	
	FSM:process(CS, time_elapsed, start)
	begin
		case CS is
			when S0 =>
			    SCLK_fall <= '0';
			    SCLK_rise <= '0';
				enable_count <= '0';
				if(start = '1')then NS <= S1;
				else NS <= S0;
				end if;

			when S1 =>
				SCLK <= '0';
				if(time_elapsed = '1')then  
					enable_count <= '0';
					SCLK_rise <= '1';
					SCLK_fall<='0';
					NS <= S2;
				elsif(time_elapsed = '0')then 
				    enable_count <= '1';
					SCLK_rise <= '0';
					SCLK_fall<='0'; 
					NS <= S1;
				end if;
				
			WHEN S2 =>
				SCLK <= '1';
				if(time_elapsed = '1')then  
					enable_count <= '0';
					SCLK_fall <= '1';
					SCLK_rise<='0';
					NS <= S1;
				elsif(time_elapsed = '0')then  
				    enable_count <= '1';
					SCLK_fall <= '0';
					SCLK_rise<='0';
					NS <= S2;
				end if;
		end case;
	end process;
	

end Behavioral;
