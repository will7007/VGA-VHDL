----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2020 06:22:38 PM
-- Design Name: 
-- Module Name: slow_counter_tb - Behavioral
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

entity slow_counter_tb is
--  Port ( );
end slow_counter_tb;

architecture Behavioral of slow_counter_tb is

component slow_counter is
    Port ( clk : in STD_LOGIC := '0';
           address : out STD_LOGIC_VECTOR (14 downto 0));
end component;

signal clk : STD_LOGIC := '0';
signal enable : STD_LOGIC := '1';
signal address : STD_LOGIC_VECTOR (14 downto 0);
signal go : STD_LOGIC := '0';

begin
    slow: slow_counter port map(clk=>go,address=>address);
    go <= '1' when (clk='1' AND enable='1') else '0';
    process
    begin
        for i in 0 to 32767 loop
            clk<='1';
            wait for 10ps;
            clk<='0';
            wait for 10ps;
        end loop;
        
        enable<='0'; --test the enable line
        for i in 0 to 10 loop
            clk<='1';
            wait for 10ps;
            clk<='0';
            wait for 10ps;
        end loop;
    end process;
end Behavioral;
