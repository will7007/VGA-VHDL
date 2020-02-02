----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 10:03:20 PM
-- Design Name: 
-- Module Name: VGA_driver - Behavioral
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

entity basic_VGA_driver is
    Port ( clk : in STD_LOGIC;
           color : out STD_LOGIC_VECTOR (2 downto 0) := "000"; --RGB
           HSYNC : out STD_LOGIC := '1';
           VSYNC : out STD_LOGIC := '1');
end basic_VGA_driver;

architecture Behavioral of basic_VGA_driver is

component Clk40 IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;

component counter is
    Generic (output_size : integer; --size of the output bus in bits
             output_limit : integer); --numerical logical maximum of the counter (no minus 1)
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC := '1'; --both these control signals are active high
           reset : in STD_LOGIC := '0';
           output : out STD_LOGIC_VECTOR (output_size-1 downto 0);
           overflow : out STD_LOGIC := '0'); --active high
end component;

component sync_unit is
    Port ( h_counter : in STD_LOGIC_VECTOR (10 downto 0);
           v_counter : in STD_LOGIC_VECTOR (9 downto 0);
           HSYNC : out STD_LOGIC := '1'; --these sync signals are normally high and asserted low during the sync pulse
           VSYNC : out STD_LOGIC := '1';
           mem_enable : out STD_LOGIC := '1'); --active low
end component;

component ROMTest IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component GlyphRom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

signal clk_sig : STD_LOGIC := '0';

signal h_counter : unsigned (10 downto 0) := (others=>'0');
signal v_counter : unsigned (9 downto 0) := (others=>'0');

signal v_counter_clk : STD_LOGIC := '0';
signal new_frame : STD_LOGIC :='0';

signal memory_address : STD_LOGIC_VECTOR (14 downto 0) := (others=>'0');
signal memory_enable : STD_LOGIC := '0'; --my monitor seems to hate displaying pure white in the sync area, so make sure the memory_enable is setting the color shown in the blanking period to 0 or nothing will be displayed at all anywhere
signal rom_address : STD_LOGIC_VECTOR (8 downto 0) := (others=>'0');

signal background_color : STD_LOGIC_VECTOR (2 downto 0) := "000"; --note that this is for the background layer, not drawn for the glyph pixel
signal text_info : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --contains stuff like the glyph offset (right now, we will just keep setting it to the index of A in white)
signal glyph_pixels : STD_LOGIC_VECTOR (7 downto 0) := "11111111"; --output of the glyph rom
signal glyph_color : STD_LOGIC := '0'; --true when the glyph should be colored in
--signal screen_text : string (4 downto 0) := "Hello";

signal memory_counter_start : unsigned (15 downto 0) := (others=>'0');
signal memory_map_sig : STD_LOGIC_VECTOR (14 downto 0) := (others=>'0');

signal HSYNC_signal : STD_LOGIC := '1';
signal VSYNC_signal : STD_LOGIC := '1';

--signal video_mode : STD_LOGIC_VECTOR (1 downto 0) := "01"; --00 for background only, 01 for text, 10 for sprites, 11 is reserved

signal text_info_extended : unsigned (8 downto 0) := (others=>'0');

signal rom_trigger : STD_LOGIC := '0';

signal glyph_color_extended : STD_LOGIC_VECTOR (2 downto 0) := (others=>'0');
signal memory_enable_extended: STD_LOGIC_VECTOR (2 downto 0) := (others=>'0');

--signal text_location : integer (range 0 to 4) := 0;

begin
	--rom_address<=(unsigned(text_info (5 downto 0))*4+unsigned(memory_address (2 downto 1))+4*unsigned(v_counter (2 downto 0))); --when v_counter(0)='0' else rom_address
	rom_address<=STD_LOGIC_VECTOR(text_info_extended + v_counter (4 downto 2)); --after 8 physical pixels of vertical lines, the next row of the character is loaded. The type of character varies depending on text_info_extended (which is text_info)
	--rom_address_port<=rom_address; for testing
    
	text_info_extended<=(5=>text_info(5), --the fatal, unexplained errors in synthesis seemed to be caused by a mismatch in the length of the unsigned signals 
							4=>text_info(4),
							3=>text_info(3),   
							2=>text_info(2),
							1=>text_info(1),
							0=>text_info(0),
								others=>'0');

--	 text_info(5 downto 0)<=							 
--	char_to_index: process(text_info,screen_text,text_location)
--	begin
--			case(screen_text(text_location)) is
--				when 'h'=>text_info<=
--								 
      --text_info_extended<=(text_info (5 downto 0), (others=>'0'));                       
--	  v_counter_extended<=(3=>v_counter(3),
--								  2=>v_counter(2),
--								  1=>v_counter(1),
--								  others=>'0');
					  
PLL: Clk40 port map(inclk0=>clk,c0=>clk_sig); --40Mhz clock for 800x600

   --glyph_color_port<=glyph_color; for testing

	h_pixel_counter: counter generic map(output_size=>11,output_limit=>1056) --counter for the horizontal beam position
	port map(clk=>clk_sig,unsigned(output)=>h_counter,overflow=>v_counter_clk); --clock signal inverted so the proper address will be ready for the memory
	
	v_pixel_counter: counter generic map(output_size=>10,output_limit=>628) --counter for the vertical beam position
	port map(clk=>v_counter_clk,unsigned(output)=>v_counter,overflow=>new_frame); --advanced by the overflowing of the horizontal beam position

	sync_component: sync_unit port map(h_counter=>STD_LOGIC_VECTOR(h_counter),v_counter=>STD_LOGIC_VECTOR(v_counter),HSYNC=>HSYNC_signal,VSYNC=>VSYNC_signal,mem_enable=>memory_enable); --unit which controls when the HSYNC and VSYNC pulses happen

ROM: ROMTest port map(address=>memory_address,clock=>not(clk_sig),q=>background_color,clken=>memory_enable); --loading the pixel on the falling edge reduces latency by 1 physical pixel
	
Glyph: GlyphRom port map(address=>rom_address,clken=>memory_enable,clock=>clk_sig,q=>glyph_pixels);

	memory_map_sig <= STD_LOGIC_VECTOR(memory_counter_start (14 downto 0) + h_counter (10 downto 2));
	memory_address <= memory_map_sig when memory_enable = '1' else (others=>'0') when memory_enable = '0'; --STD_LOGIC_VECTOR(unsigned(memory_map_sig)+1) does not reduce the 1 physical pixel latency, it just moves the square pixels over to the left by 1
	--therefore the issue is almost certainly a timing one (will need to remove the IP so I can see in a beter simulator)
	
	VSYNC <= VSYNC_signal;
	HSYNC <= HSYNC_signal;

	--color <= background_color when memory_enable = '1' AND video_mode="00" else (others=>text_info(7)) when memory_enable = '1' AND video_mode="01" AND glyph_color='1' else "000" when memory_enable = '0' OR (glyph_color='0' AND video_mode="01"); --stop random things from being on the screen after the memory is off  
	--color <= "111" when memory_enable='1' AND glyph_color='1' else background_color when glyph_color='0' else "000" when memory_enable='0'; --kept inferring a latch so I reduced the complexity of the assignment   
	
	color <= memory_enable_extended AND (background_color OR glyph_color_extended); --using conditional assignment seemed to be causing weird screen problems (cannot display this mode, mostly red coloring)
	--color <= "111" when glyph_color='1' AND memory_enable='1' else "000";
	
	glyph_color_extended<=(others=>glyph_color);
	memory_enable_extended<=(others=>memory_enable); --surely there must be a better way to do this?
	
	memory_map: process(HSYNC_signal,memory_counter_start,v_counter)
	begin
		if falling_edge(HSYNC_signal) then --? changed to v_counter_clk from HSYNC so that we avoid being a line behind
			memory_counter_start<=(v_counter (9 downto 2) * 200); --note that this is already adjusted to have a pixel width of 
		end if;
	end process;
	
	--rom_address<=STD_LOGIC_VECTOR(unsigned(text_info (5 downto 0))*4+unsigned(memory_address (2 downto 1))+4*unsigned(v_counter (2 downto 0))) (8 downto 0); --Vivado doesn't want the indexing of a type conversion, but Quartus II does when v_counter(0)='0' else rom_address
	
	grid_loader: process(clk_sig,glyph_pixels,memory_address,glyph_color,v_counter)
	--variable v_shifted : unsigned (2 downto 0) := (others=>'0');
	begin
		--v_shifted_2:=(4=>v_counter(0),others=>'0'); --not sure if this is more efficient than doing an sll
		if falling_edge(clk_sig) then --The color is set on the falling edge: rising makes a clock period's worth of wrong color when the memory switches to enable, falling makes it only wrong for half a period
			case(memory_address (2 downto 0)) is--read the pixel that we stored away in our glyph_color register (which has two lines worth of pixel data in it 
				when "000"=>glyph_color<=glyph_pixels(0); --This case statement is for a width of 8
				when "001"=>glyph_color<=glyph_pixels(1);
				when "010"=>glyph_color<=glyph_pixels(2);
				when "011"=>glyph_color<=glyph_pixels(3);
				when "100"=>glyph_color<=glyph_pixels(4);
				when "101"=>glyph_color<=glyph_pixels(5);
				when "110"=>glyph_color<=glyph_pixels(6);
				when "111"=>glyph_color<=glyph_pixels(7); --text_info should be changed here
				when others=>glyph_color<='0';
			end case;
			
--			case(memory_address (1 downto 0)) is--read the pixel that we stored away in our glyph_color register (which has two lines worth of pixel data in it 
--				when "00"=>
--					if v_counter(2)='0' then glyph_color<=glyph_pixels(0); --v_counter(2)=every 4th line, switch to the second row
--					else glyph_color<=glyph_pixels(4);
--					end if;
--				when "01"=>
--					if v_counter(2)='0' then glyph_color<=glyph_pixels(1);
--					else glyph_color<=glyph_pixels(5);
--					end if;
--				when "10"=>
--					if v_counter(2)='0' then glyph_color<=glyph_pixels(2);
--					else glyph_color<=glyph_pixels(6);
--					end if;
--				when "11"=>
--					if v_counter(2)='0' then glyph_color<=glyph_pixels(3);
--					else glyph_color<=glyph_pixels(7); --rom_trigger<='1'; --load in the final glyph pixel and ask the rom for the new address location so we can get the next two lines
--					end if;
--				when others=>
--					glyph_color<='0'; rom_trigger<='0';
--			end case;
			
			--conditional assignment doesn't seem to work inside of a process
--			glyph_color<=glyph_pixels(0) when v_counter(0)='0' AND memory_address (1 downto 0)="00" else glyph_pixels(4) when v_counter(0)='1' AND memory_address (1 downto 0)="00" else
--							 glyph_pixels(1) when v_counter(0)='0' AND memory_address (1 downto 0)="01" else glyph_pixels(5) when v_counter(0)='1' AND memory_address (1 downto 0)="01" else
--							 glyph_pixels(2) when v_counter(0)='0' AND memory_address (1 downto 0)="10" else glyph_pixels(6) when v_counter(0)='1' AND memory_address (1 downto 0)="10" else
--							 glyph_pixels(3) when v_counter(0)='0' AND memory_address (1 downto 0)="11" else glyph_pixels(7) when v_counter(0)='1' AND memory_address (1 downto 0)="11";
			
			--glyph_color<=glyph_pixels(unsigned(memory_address (1 downto 0))+unsigned(v_counter(0 downto 0) sll 2)); --tried to do this instead of a case statement, but it couldn't resolve the + operator so I must have mixed up some types
			--if(memory_address (1 downto 0)="11") then --if we are about to enter a new grid then...
				--text_info<=--ask the memory for the next grid's glyph index and put this index in the index register 
				--nothing to do here for the moment as I haven't made the graphics memory yet 
				
			end if;
	end process;
end Behavioral;