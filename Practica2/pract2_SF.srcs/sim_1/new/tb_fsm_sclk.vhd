library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fsm_sclk is 
end tb_fsm_sclk;

architecture testBench of tb_fsm_sclk is
  component fsm_sclk is
  port (
    rst_n : IN STD_LOGIC; -- asynchronous reset, low active
    clk : IN STD_LOGIC; -- system clk
    start : IN STD_LOGIC; -- signal to start the synchronous clk
    SCLK : OUT STD_LOGIC;-- Synchronous clock at the g_freq_SCLK_KHZ
    SCLK_rise : OUT STD_LOGIC;-- one cycle signal of the rising edge of SCLK
    SCLK_fall : OUT STD_LOGIC -- one cycle signal of the falling edge of SCLK
  );
end component;


  constant freq : integer := 2_000_000; --KHZ
  constant clk_period : time := (1 ms/ freq);

  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk       :   std_logic := '0';
  signal  start     :   std_logic := '0';
  -- Output
  signal  SCLK         :   std_logic;
  signal  SCLK_rise         :   std_logic;
  signal  SCLK_fall         :   std_logic;

begin
  UUT: fsm_sclk
    port map (
      rst_n     => rst_n,
      clk => clk,
      start       => start,
      SCLK       => SCLK,
      SCLK_fall   => SCLK_fall,
      SCLK_rise   => SCLK_rise
    );
    clk <= not clk after clk_period/2;
  process is 
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';
   
    wait until rising_edge(clk);
    start <='1';
    wait for 300 ns;
  end process;
end testBench;