----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 04:47:36 PM
-- Design Name: 
-- Module Name: clk_div - Behavioral
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

entity counter is
    Generic (output_size : integer; --size of the output bus in bits
             output_limit : integer); --numerical logical maximum of the counter (no -1)
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC := '1'; --both these control signals are active high
           reset : in STD_LOGIC := '0';
           output : out STD_LOGIC_VECTOR (output_size-1 downto 0);
           overflow : out STD_LOGIC := '0'); --active high
end counter;

architecture Behavioral of counter is --really my clock divider is just a simplified version of the counter

signal value : unsigned (output_size-1 downto 0) := (others=>'0'); --set this to the output_size instead of the output limit just in case
--signal sig : STD_LOGIC_VECTOR (output_size-1 downto 0) := (others=>'0');

begin
    output<=STD_LOGIC_VECTOR(value) when reset='0' else (others=>'0');
    process(clk)
    begin
        if enable='1' AND rising_edge(clk) AND NOT(reset='1') then
            if value=(output_limit-1) then
                value <= (others=>'0');
                overflow<='1';
            else 
                value <= value + 1;
                overflow<='0';
            end if;
        end if;
    end process;
end Behavioral;