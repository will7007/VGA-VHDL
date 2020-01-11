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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div is
    Generic ( div_amount : integer := 5); --clock/div_amount=clk output 
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           enable : in STD_LOGIC := '1'); --active high
end clk_div;

architecture Behavioral of clk_div is

signal counter : integer range 0 to div_amount := 0;
signal clk : STD_LOGIC := '0';

begin
    clk_out<=clk;
    process(clk_in,enable)
    begin
        if enable='1' AND rising_edge(clk_in) then
            if counter=(div_amount-1) then
                counter <= 0;
                clk<=not(clk);
            else 
                counter <= counter + 1;
            end if;
        end if;
    end process;
end Behavioral;
