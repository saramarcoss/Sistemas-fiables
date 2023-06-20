library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_shift_register is
end tb_shift_register;

architecture testBench of tb_shift_register is
  component shift_register is
	generic(
		g_N	: integer := 16         -- Size of the register
	);
	port (
		rst_n		: in std_logic; -- asynchronous reset, low active
		clk 		: in std_logic; -- system clk
		s0          : in std_logic;
		s1          : in std_logic;
		din   		: in std_logic; -- Serial IN. One bit serial input
		D  	      	: in std_logic_vector(g_N-1 downto 0);-- Paralel IN. Vector of generic g_n bits.
		Q         	: out std_logic_vector(g_N-1 downto 0);-- Paralel OUT. 
		dout     	: out std_logic -- Serial OUT.
	);
end component;
  constant g_N	: integer := 16;         -- Size of the register
  constant freq : integer := 100_000;   --KHZ
  constant clk_period : time := (1 ms/ freq);
  -- Inputs 
  signal rst_n      : std_logic := '0';
  signal clk        : std_logic := '0';
  signal s0         : std_logic := '0';
  signal s1         : std_logic := '0';
  signal din		: std_logic := '0';-- Serial IN. One bit serial input
  signal D      	: std_logic_vector(g_N-1 downto 0) := (others => '0');-- Paralel IN. Vector of generic g_n bits.
  -- Output
  signal  dout 		:  std_logic;-- Synchronous clock at the g_freq_SCLK_KHZ
  signal  Q	        :  std_logic_vector(g_N-1 downto 0);-- one cycle signal of the rising edge of SCLK
   
begin
  UUT: shift_register
  	generic map(
		g_N	      => g_N       -- Size of the register
	)
    port map (
      rst_n     => rst_n,
      clk       => clk,
      s0        => s0,
      s1        => s1,
      din       => din,
      D         => D,
      Q         => Q,
      dout      => dout
    );
    
  clk <= not clk after clk_period/2;
  process is 
  begin    
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst_n <= '1';
    
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    s0 <='1';
    
    wait until rising_edge(clk);
    din <= '1';

    --------------------------
    -- Completar con los casos de prueba
    -- Recuerda probar tanto la entrada en serie como la carga en paralelo
    --------------------------
     D<="0110111111110111";
        s0<='1';s1<='1';wait for 20ns; --carga
        s0<='1';s1<='0'; -- rotar a la derecha
        din<='1';wait for 100ns;
        s0<='0';s1<='1'; --nada
        din<='1';wait for 100ns;
        s0<='1';s1<='0'; --rotar dcha
        din<='0';    wait for 100ns ; 
        din<='1';wait for 100ns;
        s0<='0';s1<='1'; --nada
        D<="0000111111110111";
        s0<='1';s1<='1';wait for 10ns; --carga
    
    wait until rising_edge(clk);
    rst_n <= '0';
    wait for 200 us;
  end process;
end testBench;

    
