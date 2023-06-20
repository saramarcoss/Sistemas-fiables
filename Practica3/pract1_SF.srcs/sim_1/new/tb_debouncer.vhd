library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_debouncer is
end tb_debouncer;

architecture testBench of tb_debouncer is
  component debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic;
        clk         : in    std_logic;
        ena         : in    std_logic;
        sig_in      : in    std_logic;
        debounced   : out   std_logic
    ); 
  end component;
  
  -- Frecuencia reducida y timeout al minimo para una visualizaci?n m?s sencilla.
  constant timer_debounce : integer := 1; --ms
  constant freq : integer := 30; --KHZ
  
  constant clk_period : time := (1 ms/ freq);
  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk         :   std_logic := '0';
  signal  ena         :   std_logic := '1';
  signal  BTN_sync      :   std_logic := '0';
  -- Output
  signal  debounced   :   std_logic;
   
begin
  UUT: debouncer
    generic map (
      g_timeout        => timer_debounce,
      g_clock_freq_KHZ => freq
    )
    port map (
      rst_n     => rst_n,
      clk       => clk,
      ena       => ena,
      sig_in    => BTN_sync,
      debounced => debounced
    );
  clk <= not clk after clk_period/2;
  process is 
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst_n <= '1';
    
    -- Btn on with noise
    -- Tras la se?al inicial del boton, el debouncer comenzara a contar
    -- el tiempo de timeout (1 ms), dado que despues de ese tiempo el boton sigue en valor '1'
    -- se debe haber producido un solo ciclo de debouncer a valor 1.
    wait for 100 us;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 100 us;
    wait until rising_edge(clk);
    BTN_sync <= '0';
    wait for 100 us;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 900 us;
    
    -- False boton off 
    -- Al apagarse la se?al, se comienza a contar el tiempo de debounce (1 ms),
    -- dado que despues de este la se?al esta encendida, no se considera valido el apagado del bot?n.
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 100 us;
    wait until rising_edge(clk);
    -- Esta cambio a se?al de encendido no debe generar una se?al positiva de debounce
    -- dado que se ha producido durante el tiempo de debounce para comprobar el apagado del boton
    BTN_sync <='1';
    wait for 950 us;
    
    -- Boton off with noise
    -- Al apagarse la se?al, se comienza a contar el tiempo de debounce (1 ms),
    -- dado que despues de este la se?al esta apagada, es un apagado v?lido.
    -- Los encendidos de la se?al del boton durante estos momentos no generan se?al de debounce
    -- dado que se han producido durante el tiempo de debounce y son ruido.
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 100 us;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 100 us;
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 850 us;
    
    wait until rising_edge(clk);
    rst_n <= '0';
    wait for 200 us;
  end process;
end testBench;


