library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is 
end tb_top;

architecture testBench of tb_top is
  component top_practica1 is
  generic (
      g_sys_clock_freq_KHZ  : integer := 100e3; -- Value of the clock frequencies in KHz
      g_debounce_time 		: integer := 20;  -- Time for the debouncer in ms
      g_reset_value 		: std_logic := '0'; -- Value for the synchronizer 
      g_number_flip_flps 	: natural := 2 	-- Number of ffs used to synchronize	
  );
  port (
      rst_n         : in std_logic;
      clk100Mhz     : in std_logic;
      BTNC           : in std_logic;
      LED           : out std_logic
  );
end component;

  -- Frecuencia reducida y timeout al minimo para una visualizaci?n m?s sencilla.
  constant timer_debounce : integer := 1; --ms
  constant freq : integer := 30; --KHZ
  constant clk_period : time := (1 ms/ freq);

  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk         :   std_logic := '0';
  signal  BTN     :   std_logic := '0';
  -- Output
  signal  LED   :   std_logic;

begin
  UUT: top_practica1
    generic map ( 
      g_sys_clock_freq_KHZ  => freq, 
      g_debounce_time       => timer_debounce,
      g_reset_value         => '0',
      g_number_flip_flps 	=> 2
    )
    port map (
      rst_n     => rst_n,
      clk100Mhz => clk,
      BTNC       => BTN,
      LED       => LED
    );
    clk <= not clk after clk_period/2;
  process is 
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst_n <= '1';
    
    -- Btn on with noise
    -- Tras la se?al inicial del boton, el debouncer comenzara a contar
    -- el tiempo de timeout: 1 ms, teniendo en ceunta peque?as variaciones por la sincronizacion
    -- de la se?al del boton. Dado que despues de ese tiempo el boton sigue en valor '1'
    -- se debe haber producido un toggle en el led, cambiando su valor.
    wait for 16 us;
    BTN <='1';
    wait for 235 us;
    BTN <= '0';
    wait for 166 us;
    BTN <='1';
    wait for 721 us;
    
    -- Btn off
    BTN <='0';
    wait for 1092 us;
    
    -- Btn on with noise
    wait for 21 us;
    BTN <='1';
    wait for 492 us;
    BTN <= '0';
    wait for 166 us;
    BTN <='1';
    wait for 900 us;
    
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst_n <= '1';
  end process;
end testBench;