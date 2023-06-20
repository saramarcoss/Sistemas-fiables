library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture rtl of fir_filter_tb is

constant beta1    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-10,8));--(100,8)); Probad distintos filtros
constant beta2    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(110,8));--(100,8));
constant beta3    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(127,8));--(100,8));
constant beta4    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-20,8));--(100,8));

component fir_test_data_generator
port (
  clk                   : in  std_logic;
  rst                  : in  std_logic;
  pattern_sel           : in  integer;  -- 0=> delta; 1=> step; 2=> sine
  enable      : in  std_logic;
  o_data                  : out std_logic_vector( 7 downto 0)); -- to FIR 
end component;

component fir_filter
port (
	clk		:in std_logic;
	rst		:in std_logic;
	-- Coeficientes
	beta1	:in std_logic_vector(7 downto 0);
 	beta2	:in std_logic_vector(7 downto 0);
	beta3	:in std_logic_vector(7 downto 0);
	beta4	:in std_logic_vector(7 downto 0);
	-- Data input 8 bit
	i_data 	:in std_logic_vector(7 downto 0);
	-- Filtered data
	o_data 	:out std_logic_vector(9 downto 0)
	);
end component;


constant freq : integer := 100_000;   --KHZ
constant clk_period : time := (1 ms/ freq);


signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal pattern_sel : integer := 0;
signal enable : std_logic := '0';
signal w_data_test : std_logic_vector( 7 downto 0) := (others => '0');
signal o_data : std_logic_vector( 9 downto 0) := (others => '0');


begin
U_fir_test_data_generator : fir_test_data_generator
port map(
  clk                   => clk,
  rst                   => rst,
  pattern_sel           => pattern_sel,
  enable                => enable,
  o_data                => w_data_test);
  
  
UUT : fir_filter 
port map(
  clk        => clk        ,
  rst       => rst       ,
  -- coefficient
  beta1    => beta1    ,
  beta2    => beta2    ,
  beta3    => beta3    ,
  beta4    => beta4    ,
  -- data input
  i_data       => w_data_test  ,
  -- filtered data 
  o_data       => o_data);
  
  clk <= not clk after clk_period/2;
  process is
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '1';
    
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    pattern_sel <= 0;
    enable <='1';
    
    wait for 100 us;
    
    wait until rising_edge(clk);
    rst <= '0';
  
    wait for 100 us;
  end process;
  
end rtl;