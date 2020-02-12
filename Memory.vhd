library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity glyph_memory is
	Port(	address : in STD_LOGIC_VECTOR (8 downto 0) := (others=>'0');
			clk_en : in STD_LOGIC :='1';
			clk : in STD_LOGIC := '0';
			--input : 
			data : out STD_LOGIC_VECTOR (7 downto 0) := (others=>'0')
	);	
end glyph_memory;

architecture behavioral of glyph_memory is

type memory_blocks is array (0 to 511) of STD_LOGIC_VECTOR (7 downto 0);
signal memory_data : memory_blocks :=	("00011100",
													"00110110",
													"01100011",
													"01100011",
													"01111111",
													"01100011",
													"01100011",
													"01100011",
													others=>"00000000");

begin
	read_data: process(clk,clk_en,address)
	begin
		if rising_edge(clk) then
			if clk_en='1' then
				data<=(memory_data(to_integer(unsigned(address))));
			end if;
		end if;
	end process;
end architecture;