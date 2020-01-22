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
           --mem_enable : out STD_LOGIC; --not really used here since there's no memory 
           HSYNC : out STD_LOGIC := '1';
           VSYNC : out STD_LOGIC := '1');
end basic_VGA_driver;

architecture Behavioral of basic_VGA_driver is

--component clk_div is
--    Generic ( div_amount : integer := 5); --clock/div_amount=clk output 
--    Port ( clk_in : in STD_LOGIC;
--           clk_out : out STD_LOGIC;
--           enable : in STD_LOGIC := '1'); --active high
--end component;

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

--I tried making a counter which flipped on both the rising and falling edge, but it didn't work out
--component slow_counter is
--    Port ( clk : in STD_LOGIC := '0';
--			  reset : in STD_LOGIC :='0';
--           address : out STD_LOGIC_VECTOR (14 downto 0));
--end component;

signal clk_sig : STD_LOGIC := '0';

signal h_counter : unsigned (10 downto 0) := (others=>'0');
signal v_counter : unsigned (9 downto 0) := (others=>'0');

signal v_counter_clk : STD_LOGIC := '0';
signal new_frame : STD_LOGIC :='0';

--signal memory_address_counter_sig: STD_LOGIC_VECTOR (14 downto 0) := (others=>'0'); --added

signal memory_address : STD_LOGIC_VECTOR (14 downto 0) := (others=>'0');
signal memory_enable : STD_LOGIC := '0';
signal color_intermediate : STD_LOGIC_VECTOR (2 downto 0) := "000";

signal memory_counter_start : unsigned (15 downto 0) := (others=>'0');

signal HSYNC_signal : STD_LOGIC := '1';
signal VSYNC_signal : STD_LOGIC := '1';

begin
	PLL: Clk40 port map(inclk0=>clk,c0=>clk_sig);
	 
	h_pixel_counter: counter generic map(output_size=>11,output_limit=>1056) --counter for the horizontal beam position
							  port map(clk=>clk_sig,unsigned(output)=>h_counter,overflow=>v_counter_clk);
	v_pixel_counter: counter generic map(output_size=>10,output_limit=>628) --counter for the vertical beam position (CHANGED FROM 628 TO 609)
							  port map(clk=>v_counter_clk,unsigned(output)=>v_counter,overflow=>new_frame); --advanced by the overflowing of the horizontal beam position
	 
	--memory_address_counter: counter generic map(output_size=>19,output_limit=>524272) --counter for the memory byte (added)
	--                         port map(clk=>clk_sig,output=>memory_address_counter_sig,enable=>memory_enable,reset=>NOT(VSYNC_signal));

	--memory_address_counter: slow_counter port map(clk=>memory_counter_advance,address=>memory_address_counter_sig,reset=>NOT(VSYNC_signal));
	 
	sync_component: sync_unit port map(h_counter=>STD_LOGIC_VECTOR(h_counter),v_counter=>STD_LOGIC_VECTOR(v_counter),HSYNC=>HSYNC_signal,VSYNC=>VSYNC_signal,mem_enable=>memory_enable); --unit which controls when the HSYNC and VSYNC pulses happen
	 
	ROM: ROMTest port map(address=>memory_address,clock=>clk_sig,q=>color_intermediate,clken=>memory_enable);
	 
	--memory_address (4 downto 0) <= h_counter (9 downto 5) when memory_enable = '1' else "00000" when memory_enable = '0'; --0 to 24 x (0 to 799, 0 to 18 in hex) 25
	--memory_address (11 downto 5) <= v_counter (9 downto 3) when memory_enable = '1' else "0000000" when memory_enable = '0'; --0 to 37 y (0 to 599) 38
	--The amount of unused portion in the memory is determined by the LSB place of the selected portion of the v_counter
	  
	memory_address <= STD_LOGIC_VECTOR(memory_counter_start (14 downto 0) + h_counter (10 downto 2)) when memory_enable = '1' else (others=>'0') when memory_enable = '0';
	 
	VSYNC <= VSYNC_signal;
	HSYNC <= HSYNC_signal; --when VSYNC_signal='1' else '1'; 
	
	color <= color_intermediate when memory_enable = '1' else "000" when memory_enable = '0'; --stop random things from being on the screen after the memory is off
 
	process(HSYNC_signal,memory_counter_start,v_counter)
	begin
		if falling_edge(HSYNC_signal) then
			memory_counter_start<=(v_counter (9 downto 2) * 200);
		end if;
	end process;

	--memory_counter_advance <= '1' when (h_counter (3 downto 0) = "1111" AND memory_enable='1') else '0'; --when the counter is about to flip h_counter (5) to something new, change the address counter (must have the memory_enable here or problems arise)
	--5 downto 0 means we care about the 6th bit, which is 64, thus 64 horizontal pixles pass before we load in a new color
	--3 downto 0 means that each color takes up 16 pixels
end Behavioral;