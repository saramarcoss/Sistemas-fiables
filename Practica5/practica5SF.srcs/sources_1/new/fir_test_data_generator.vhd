library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fir_test_data_generator is
port (
  clk                     : in  std_logic;
  rst                     : in  std_logic;
  pattern_sel             : in  integer;  -- '0'=> delta; '1'=> step
  enable                  : in  std_logic;
  o_data                  : out std_logic_vector( 7 downto 0));  -- to FIR
end fir_test_data_generator;
architecture rtl of fir_test_data_generator is
type t_pattern_input is array(0 to 31) of integer range -128 to 127;
constant C_PATTERN_DELTA     : t_pattern_input := (
     0  ,
   127  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  );
constant C_PATTERN_STEP      : t_pattern_input := (
     0  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
   127  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  ,
     0  );
constant C_PATTERN_SINE      : t_pattern_input := (
     0  ,
   49  ,
   91  ,
   118  ,
   127  ,
   118  ,
   91  ,
   49  ,
   0  ,
   -48  ,
   -90  ,
   -117  ,
   -127  ,
   -117  ,
   -90  ,
   -48  ,
   0  ,
   49  ,
   91  ,
   118  ,
   127  ,
   118  ,
   91  ,
   49  ,
   0  ,
   -48  ,
   -90  ,
   -117  ,
   -127  ,
   -117  ,
   -90  ,
   -48);
signal r_write_counter             : integer range 0 to 31; 
signal r_write_counter_ena         : std_logic;
begin

p_write_counter : process (rst,clk)
begin
  if(rst='0') then
    r_write_counter             <= 0;
    r_write_counter_ena         <= '0';
  elsif(rising_edge(clk)) then
    if(enable='1') then
        if (r_write_counter<31) then
          r_write_counter             <= r_write_counter + 1;
          r_write_counter_ena         <= '1';
        else
          r_write_counter             <= 0;
          r_write_counter_ena         <= '1';
        end if;
    else
        r_write_counter             <= 0;
        r_write_counter_ena         <= '0';
    end if;
  end if;
end process p_write_counter;


p_output : process (rst,clk)
begin
  if(rst='0') then
    o_data          <= (others=>'0');
  elsif(rising_edge(clk)) then
    if (r_write_counter_ena='1') then
        if(pattern_sel=0) then
          o_data     <= std_logic_vector(to_signed(C_PATTERN_DELTA(r_write_counter),8));
        elsif (pattern_sel=1) then
          o_data     <= std_logic_vector(to_signed(C_PATTERN_STEP(r_write_counter),8));
         elsif (pattern_sel=2) then
          o_data     <= std_logic_vector(to_signed(C_PATTERN_SINE(r_write_counter),8));
         
        else 
            o_data <= (others => '0');
        end if;    
    end if;
  end if;
end process p_output;
end rtl;
