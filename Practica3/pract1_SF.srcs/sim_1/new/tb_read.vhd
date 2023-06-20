library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;

entity tb_read is 
end tb_read;

architecture testBench of tb_read is
  -- Inputs 
  signal rst_n    : std_logic := '0';
  signal clk      : std_logic := '0';
  signal BTN      : std_logic := '0';
  -- Output
  signal LED      : std_logic;


  component top_practica1 is
    generic (
      g_sys_clock_freq_KHZ  : integer := 100e3; -- Value of the clock frequencies in KHz
      g_debounce_time       : integer := 20;  -- Time for the debouncer in ms
      g_reset_value         : std_logic := '0'; -- Value for the synchronizer 
      g_number_flip_flps    : natural := 2  -- Number of ffs used to synchronize  
    );
    port (
      rst_n     : in std_logic;
      clk100Mhz : in std_logic;
      BTNC      : in std_logic;
      LED       : out std_logic
    );
  end component;

  -- Frecuencia reducida y timeout al minimo para una visualizaci?n m?s sencilla.
  constant timer_debounce : integer := 1; --ms
  constant freq : integer := 30; --KHZ
  constant clk_period : time := (1 ms/ freq);

begin
  UUT: top_practica1
    generic map ( 
      g_sys_clock_freq_KHZ  => freq, 
      g_debounce_time       => timer_debounce,
      g_reset_value         => '0',
      g_number_flip_flps    => 2
    )
    port map (
      rst_n     => rst_n,
      clk100Mhz => clk,
      BTNC      => BTN,
      LED       => LED
    );
    clk <= not clk after clk_period/2;
    

 
  process is 
    -- file handlers
    file file_input   : text;    --FICHERO QUE VAMOS A LEER
    file file_output  : text;    --FICHERO EN EL QUE VAMOS A ESCRIBIR
    variable text_line : line; -- Current line
	variable file_line : line;
	variable char : character; -- Read each character of the line(used when using comments)
	variable delay: time ; -- Saves the desired delay time
	variable RST_N2: std_logic;
	variable BTNC2: std_logic;
	variable LED2: std_logic;
	variable estado: file_open_status;
	
  begin
    file_open(estado, file_input, "C:\Users\saram\Downloads\input.txt", read_mode);
    if estado /= open_ok then
      report "Error opening input file";
      wait;
    end if;

    file_open(estado, file_output, "C:\Users\saram\Downloads\output.txt", write_mode);
    write(file_line, string'("Simulation of top_practica1.vhd"));
	writeline(file_output,file_line);
    if estado /= open_ok then
      report "Error opening output file";
      wait;
    end if;
    
    
   while not endfile(file_input) loop
        readline(file_input, text_line);
			if text_line.all'length = 0 or text_line.all(1) = '#' then -- Skip empty lines and commented lines
				next;
			end if;
			
			-- delay 
			read(text_line, delay);
			assert estado=open_ok
				report "Read 'delay' failed for line: " & text_line.all
				severity failure;
			-- RST_N
			read(text_line, RST_N2);
			assert estado=open_ok
				report "Read 'rst_n' failed for line: " & text_line.all
				severity failure;
			rst_n<= RST_N2;
			-- BTNC
			read(text_line, BTNC2);
			assert estado=open_ok
				report "Read 'BTNC' failed for line: " & text_line.all
				severity failure;
			BTN <= BTNC2;
			-- LED
			read(text_line, LED2);
			assert estado=open_ok
				report "Read 'LED' failed for line: " & text_line.all
				severity failure;
			wait for delay;
			
  
			writeline(file_output,file_line);
		    write(file_line,string'("Time: "));
		    write(file_line,delay);
			write(file_line,string'("; RST_N: "));
		    write(file_line,RST_N2);
		    write(file_line,string'("; BTNC: "));
		    write(file_line,BTNC2);
		    write(file_line,string'("; LED: "));
		    write(file_line, LED2);
		    write(file_line,string'(" ;"));
			writeline(file_output,file_line);
			

			read(text_line, char); -- Skip expected newline
			read(text_line, char);
			if char = '#' then
				read(text_line, char); -- Skip expected newline
				report text_line.all;
			end if;
			
			if LED = LED2 then
				writeline(file_output,file_line);
				write(file_line,string'("Correct value of LED: "));
				write(file_line,LED2);
				write(file_line,string'(" ;"));
				writeline(file_output,file_line);
				writeline(file_output,file_line);
			else
				writeline(file_output,file_line);
				write(file_line,string'("ERROR: expected LED to be "));
				write(file_line,LED2);
				write(file_line,string'(" actual value "));
				write(file_line,LED);
				write(file_line,string'(" ;"));
                writeline(file_output,file_line);
				writeline(file_output,file_line);
			end if;	
		end loop;	
		
		write(file_line, string'("Finished simulation of top_practica1.vhd"));
        writeline(file_output,file_line);
       report "Finished" severity failure; 
        file_close(file_output);
  end process;
  process is 
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait for 100ns;
  end process;
end testBench;
