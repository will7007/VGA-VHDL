----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 05:17:18 PM
-- Design Name: 
-- Module Name: clk_div_tb - Behavioral
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

entity clk_div_tb is
--  Port ( );
end clk_div_tb;

architecture Behavioral of clk_div_tb is

component clk_div is
    Generic ( div_amount : integer := 5); --clock/div_amount=clk output 
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           enable : in STD_LOGIC := '1'); --active high
end component;

signal clk_in : STD_LOGIC := '0';
signal clk_out : STD_LOGIC;

begin
    uut: clk_div port map(clk_in=>clk_in,clk_out=>clk_out);
    process
    begin
        for i in 0 to 100 loop
            clk_in<='1';
            wait for 10ps;
            clk_in<='0';
            wait for 10ps;
        end loop;
    end process;
end Behavioral;
