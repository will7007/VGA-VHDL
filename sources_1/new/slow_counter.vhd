----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2020 05:59:02 PM
-- Design Name: 
-- Module Name: slow_counter_18 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity slow_counter is
    Port ( clk : in STD_LOGIC := '0';
			  reset : in STD_LOGIC :='0';
           address : out STD_LOGIC_VECTOR (14 downto 0));
end slow_counter;

architecture Behavioral of slow_counter is
signal value : unsigned (14 downto 0) := (others=>'0');
begin
    address <= STD_LOGIC_VECTOR(value);
    process (clk,value,reset)
    begin
        if rising_edge(clk) then
            if reset='0' then
					value <= value + 1;
				else
					value <= (others=>'0');
				end if;
		  end if;
    end process;
	 
--process (clk,value)
--    begin
--        if (clk'event AND (clk='1' OR clk='0')) then --boo hoo, it seems like my rising and falling edge counter dreams have been rendered un-synthesizeable
--            value <= value + 1;
--		  end if;
--    end process;
end Behavioral;
