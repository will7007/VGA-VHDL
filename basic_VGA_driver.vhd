library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

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

--component GlyphRom IS
--	PORT
--	(
--		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
--		clken		: IN STD_LOGIC  := '1';
--		clock		: IN STD_LOGIC  := '1';
--		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
--	);
--END component;

component glyph_memory is
	Port(	address : in STD_LOGIC_VECTOR (8 downto 0) := (others=>'0');
			clk_en : in STD_LOGIC :='1';
			clk : in STD_LOGIC := '0';
			data : out STD_LOGIC_VECTOR (7 downto 0) := (others=>'0')
	);	
end component;

signal clk_sig : STD_LOGIC := '0';

signal h_counter : unsigned (10 downto 0) := (others=>'0');
signal v_counter : unsigned (9 downto 0) := (others=>'0');

signal v_counter_clk : STD_LOGIC := '0';
signal new_frame : STD_LOGIC :='0';

signal memory_address : STD_LOGIC_VECTOR (14 downto 0) := (others=>'0');
signal memory_enable : STD_LOGIC := '0'; --my monitor seems to hate displaying pure white in the sync area, so make sure the memory_enable is setting the color shown in the blanking period to 0 or nothing will be displayed at all anywhere
signal rom_address : STD_LOGIC_VECTOR (8 downto 0) := (others=>'0');

signal background_color : STD_LOGIC_VECTOR (2 downto 0) := "000"; --note that this is for the background layer, not drawn for the glyph pixel
signal text_info : unsigned (8 downto 0) := (others=>'0'); --contains stuff like the glyph offset (maybe it can contain color data in the future, but for now the text is just white)
signal glyph_pixels : STD_LOGIC_VECTOR (7 downto 0) := "11111111"; --output of the glyph rom
signal glyph_color : STD_LOGIC := '0'; --true when the glyph should be colored in

signal memory_counter_start : unsigned (15 downto 0) := (others=>'0');
signal memory_map_sig : STD_LOGIC_VECTOR (14 downto 0) := (others=>'0');

signal HSYNC_signal : STD_LOGIC := '1';
signal VSYNC_signal : STD_LOGIC := '1';

--signal video_mode : STD_LOGIC_VECTOR (1 downto 0) := "01"; --00 for background only, 01 for text, 10 for sprites, 11 is reserved


signal glyph_color_extended : STD_LOGIC_VECTOR (2 downto 0) := (others=>'0');
signal memory_enable_extended: STD_LOGIC_VECTOR (2 downto 0) := (others=>'0');

type text_grid is array (0 to 17) of string (1 to 25);
signal screen_text : text_grid := ("AELLO                    ", --glyph rom may be showing letters reversed, with lsb on the left (I think it is, since we start reading from text pixel 0 and end on text pixel 7)
											  "WORLD                    ",
											  "WORLD                    ",
											  others=>"                         ");

begin
	PLL: Clk40 port map(inclk0=>clk,c0=>clk_sig); --40Mhz clock for 800x600

	h_pixel_counter: counter generic map(output_size=>11,output_limit=>1056) --counter for the horizontal beam position
	port map(clk=>clk_sig,unsigned(output)=>h_counter,overflow=>v_counter_clk); --clock signal inverted so the proper address will be ready for the memory
	
	v_pixel_counter: counter generic map(output_size=>10,output_limit=>628) --counter for the vertical beam position
	port map(clk=>v_counter_clk,unsigned(output)=>v_counter,overflow=>new_frame); --advanced by the overflowing of the horizontal beam position

	sync_component: sync_unit port map(h_counter=>STD_LOGIC_VECTOR(h_counter),v_counter=>STD_LOGIC_VECTOR(v_counter),HSYNC=>HSYNC_signal,VSYNC=>VSYNC_signal,mem_enable=>memory_enable); --unit which controls when the HSYNC and VSYNC pulses happen

	ROM: ROMTest port map(address=>memory_address,clock=>not(clk_sig),q=>background_color,clken=>memory_enable); --loading the pixel on the falling edge reduces latency by 1 physical pixel
	
	--Glyph: GlyphRom port map(address=>rom_address,clken=>memory_enable,clock=>clk_sig,q=>glyph_pixels);
	Glyph: glyph_memory port map(address=>rom_address,clk_en=>memory_enable,clk=>clk_sig,data=>glyph_pixels);

	glyph_color_extended<=(others=>glyph_color); --surely there must be a better way to do this?		
	memory_enable_extended<=(others=>memory_enable);

	rom_address<=STD_LOGIC_VECTOR(text_info + v_counter (4 downto 2)); --after 8 physical pixels of vertical lines, the next row of the character is loaded. The type of character varies depending on text_info

	memory_map_sig <= STD_LOGIC_VECTOR(memory_counter_start (14 downto 0) + h_counter (10 downto 2));
	memory_address <= memory_map_sig when memory_enable = '1' else (others=>'0') when memory_enable = '0'; --STD_LOGIC_VECTOR(unsigned(memory_map_sig)+1) does not reduce the 1 physical pixel latency, it just moves the square pixels over to the left by 1
	--therefore the issue is almost certainly a timing one (will need to remove the IP so I can see in a beter simulator)

	VSYNC <= VSYNC_signal;
	HSYNC <= HSYNC_signal;

	color <= memory_enable_extended AND (background_color OR glyph_color_extended); --using conditional assignment with lots of conditions seemed to be causing weird screen problems (cannot display this mode, mostly red coloring, sometimes it would infer latch)
	--color <= "111" when glyph_color='1' AND memory_enable='1' else "000"; --for no background

	text_decoder: process(clk_sig,screen_text,text_info,v_counter) --clk_sig is used to trigger the process to actually happen
	begin
		if rising_edge(clk_sig) then
		text_converter: for index in 0 to 25 loop --this loop will apparently be implemented in an unrolled state, such that there are 26 checkers similar to the concurrent generate thing. The concurrent generate would not work inside of the sequential case statement, nor would it work inside a conditional assignment
			if screen_text(to_integer(unsigned(v_counter (9 downto 5)))) (1) = character'val(index+65) then --recall that v_counter counts in physical pixels, not 4x4 squares, so a letter is 32 lines tall
				text_info <= unsigned(STD_LOGIC_VECTOR(to_unsigned(index,6)*8)(8 downto 0)); --We need the 8* to get the offset to be the height of the character
			end if;
		end loop text_converter;
		end if;
	end process;

	memory_mapper: process(HSYNC_signal,memory_counter_start,v_counter)
	begin
		if falling_edge(HSYNC_signal) then --? changed to v_counter_clk from HSYNC so that we avoid being a line behind
			memory_counter_start<=(v_counter (9 downto 2) * 200); --note that this is already adjusted to have a pixel width of 
		end if;
	end process memory_mapper;

	grid_loader: process(clk_sig,glyph_pixels,memory_address,glyph_color,v_counter)
	begin
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
			end if;
	end process grid_loader;
end Behavioral;