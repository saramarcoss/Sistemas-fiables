library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
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
end shift_register;

architecture behavioural of shift_register is
signal reg: std_logic_vector(g_N-1 downto 0);
    begin
    
    process (rst_n, clk)
    begin
        if (rst_n = '0') then
            reg <=(others=>'0');
        elsif rising_edge(clk) then
            if(s0 = '1')then
                if(s1='1') then 
                reg<=D;
                elsif(s1='0')then
                reg<=din & reg(g_N-1 downto 1);
                end if;
            else
                reg<=reg;
            end if;
        end if;       
    end process;
    
    -- asignacion final a Q y dout con los valores correspondientes del registro
    Q<=reg;
    dout<=reg(0);

end behavioural;




