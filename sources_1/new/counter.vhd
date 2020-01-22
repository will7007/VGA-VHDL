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
           enable : in STD_LOGIC := '1';
           reset : in STD_LOGIC := '0';
           output : out STD_LOGIC_VECTOR (output_size-1 downto 0);
           overflow : out STD_LOGIC := '0'); --active high
end counter;

architecture Behavioral of counter is

signal value : unsigned (output_size-1 downto 0) := (others=>'0'); --set this to the output_size instead of the output limit just in case
--signal sig : STD_LOGIC_VECTOR (output_size-1 downto 0) := (others=>'0');

begin
    output<=STD_LOGIC_VECTOR(value);
    process(clk,enable,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
					 value <= (others=>'0');
            elsif enable='1' AND value=(output_limit-1) then
                value <= (others=>'0');
                overflow <= '1';
            elsif enable='1' then
                value <= value + 1;
                overflow <= '0';
            end if;
        end if;
    end process;
end Behavioral;