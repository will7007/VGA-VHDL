----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 08:06:43 PM
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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

entity counter_tb is
--  Port ( );
end counter_tb;

architecture Behavioral of counter_tb is

component counter is
    Generic (output_size : integer; --size of the output bus in bits
             output_limit : integer); --numerical logical maximum of the counter (no -1)
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC := '1'; --both these control signals are active high
           reset : in STD_LOGIC := '0';
           output : out STD_LOGIC_VECTOR (output_size-1 downto 0);
           overflow : out STD_LOGIC); --active high
end component;

signal clk : STD_LOGIC;
signal output : STD_LOGIC_VECTOR (9 downto 0);
signal enable : STD_LOGIC := '1';
signal reset : STD_LOGIC := '0';

begin
    uut: counter generic map(output_size=>10,output_limit=>600)
                 port map(clk=>clk,output=>output,reset=>reset,enable=>enable);
    process
    begin
        for i in 0 to 700 loop
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
        
        reset<='1'; --test the reset line
        for i in 0 to 10 loop
            clk<='1';
            wait for 10ps;
            clk<='0';
            wait for 10ps;
        end loop;
        
        wait; -- all done
        
    end process;

end Behavioral;
