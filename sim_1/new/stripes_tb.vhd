----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 10:04:35 PM
-- Design Name: 
-- Module Name: stripes_tb - Behavioral
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

entity stripes_tb is
--  Port ( );
end stripes_tb;

architecture Behavioral of stripes_tb is

component basic_VGA_driver is
    Port ( clk : in STD_LOGIC;
           color : out STD_LOGIC_VECTOR (5 downto 0) := "000000";
           --mem_enable : out STD_LOGIC; --not really used here since there's no memory 
           HSYNC : out STD_LOGIC := '1';
           VSYNC : out STD_LOGIC := '1');
end component;

signal clk : STD_LOGIC := '0';
signal color : STD_LOGIC_VECTOR (5 downto 0) := "000000"; 
signal HSYNC : STD_LOGIC := '1';
signal VSYNC : STD_LOGIC := '1';
           
begin
    uut: basic_VGA_driver port map(clk=>clk,color=>color,HSYNC=>HSYNC,VSYNC=>VSYNC);
    process
        begin
            for i in 0 to 1000 loop
                clk<='1';
                wait for 10ps;
                clk<='0';
                wait for 10ps;
            end loop;
        end process;
    
end Behavioral;
