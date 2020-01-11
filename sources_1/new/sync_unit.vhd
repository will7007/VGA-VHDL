----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 09:08:55 PM
-- Design Name: 
-- Module Name: sync_unit - Behavioral
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

entity sync_unit is
    Port ( h_counter : in STD_LOGIC_VECTOR (8 downto 0);
           v_counter : in STD_LOGIC_VECTOR (9 downto 0);
           HSYNC : out STD_LOGIC := '1'; --these sync signals are normally high and asserted low during the sync pulse
           VSYNC : out STD_LOGIC := '1';
           mem_enable : out STD_LOGIC := '0'); --active high
end sync_unit;

architecture Behavioral of sync_unit is

begin
    HSYNC <= '0' when h_counter="011010010" else '1' when h_counter="011110010"; --flip at 210 and 242
    VSYNC <= '0' when v_counter="1001011001" else '1' when v_counter="1001011101"; --flip at 601 and 605
    mem_enable <= '1' when h_counter="000000000" else '0' when h_counter="011001000"; --ask the memory for pixels between 0 and 199 (stop at 200)
end Behavioral;
