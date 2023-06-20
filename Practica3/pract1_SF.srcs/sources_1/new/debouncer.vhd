library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;

architecture Behavioural of debouncer is 
      
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    constant c_max_cycles : unsigned(c_counter_width-1 downto 0) := to_unsigned(c_cycles, c_counter_width);
    
    --estados
    type state_type is (IDLE,BTN_PRS,VALID,BTN_UNPRS);
    signal CS, NS : state_type;

	signal counter: unsigned (c_counter_width-1 downto 0);
    -- Señal para indicar que el tiempo se cumplió
	signal time_elapsed: std_logic ;
    -- Señal para indicar que está en el estado en el que hay que contar
	signal enable_count: std_logic ;
	signal debounced_reg: std_logic;
    
begin
    --Timer
    process (clk, rst_n)
    begin
            if(rst_n = '0') then
                counter <= (others => '0');
                time_elapsed <= '0';
            elsif(rising_edge(clk)) then
                if(enable_count = '1') then
                    if((counter + 1) <= c_max_cycles) then
                        counter <= counter + 1;
                    else
                        counter <= (others => '0');
                        time_elapsed <= '1';
                    end if;
                else 
                   counter <= (others => '0');
                   time_elapsed <= '0';
                end if;
            end if;
        end process;

    --FSM Register of next state
   process (clk, rst_n)
    begin
           if(rst_n= '0') then --Señal de reinicio 
                debounced<='0';
                CS <= IDLE;
           elsif(rising_edge(clk)) then
                debounced<=debounced_reg;
                CS <= NS;
           end if;
    end process;
    
	process (CS,sig_in,ena,time_elapsed)begin
 	case CS is
        when IDLE=>
		    if(sig_in = '1')then 
                NS <= BTN_PRS;
                debounced_reg<= '0';
               enable_count <= '0';
		    else 
		        NS <= IDLE;
                debounced_reg<= '0';
                enable_count <= '0';
            end if;

	   when BTN_PRS=>
	        if(ena = '0')then
	           NS <= IDLE;
               debounced_reg <= '0';
               enable_count <= '0';
            elsif (time_elapsed = '1' and sig_in = '1') then 
	           NS <= VALID;
	           debounced_reg <= '1';
	           enable_count <= '0';
	       elsif (time_elapsed = '0') then 
	           NS <= BTN_PRS;
	           debounced_reg <= '0';
	           enable_count <= '1';
	       else 
	           NS <= IDLE;
	           debounced_reg <= '0';
	          enable_count <= '0';
            end if;
        when VALID=>
            enable_count <= '0';
            debounced_reg <= '0';
            if(ena = '0')then  
                NS <= IDLE;
                enable_count <= '0';
                debounced_reg <= '0';
            elsif(sig_in = '0')
                then  NS <= BTN_UNPRS;
                enable_count <= '0';
                debounced_reg <= '0';
            end if;
	   when BTN_UNPRS =>
	       if (time_elapsed = '1' and sig_in = '0') then 
	           NS <= IDLE;
	           debounced_reg <= '0';
	           enable_count <= '0';
	       elsif (ena = '0') then 
	           NS <= IDLE;
	           debounced_reg <= '0';
	           enable_count <= '0';
	       elsif (time_elapsed = '1' and sig_in = '1') then
	           debounced_reg <= '0';
	           NS <= VALID;
	           enable_count <= '0';
	       elsif (time_elapsed = '0') then 
	           NS <= BTN_UNPRS;
	           enable_count <= '1';
	           debounced_reg <= '0';
	       else 
	           NS <= IDLE;
	           debounced_reg <= '0';
            end if;
      end case; 
    end process;
end Behavioural;