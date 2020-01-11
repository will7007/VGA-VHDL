----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 10:19:56 PM
-- Design Name: 
-- Module Name: basic_VGA_driver - Behavioral
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

component clk_div is
    Generic ( div_amount : integer := 5); --clock/div_amount=clk output 
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           enable : in STD_LOGIC := '1'); --active high
end component;

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
    Port ( h_counter : in STD_LOGIC_VECTOR (8 downto 0);
           v_counter : in STD_LOGIC_VECTOR (9 downto 0);
           HSYNC : out STD_LOGIC := '1'; --these sync signals are normally high and asserted low during the sync pulse
           VSYNC : out STD_LOGIC := '1';
           mem_enable : out STD_LOGIC := '0'); --active high
end component;

component ROMTest IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

--signal raw_clk : STD_LOGIC;
signal clk_sig : STD_LOGIC := '0';
signal h_counter : STD_LOGIC_VECTOR (8 downto 0);
signal v_counter : STD_LOGIC_VECTOR (9 downto 0);
signal v_counter_clk : STD_LOGIC := '0';
signal memory_address : STD_LOGIC_VECTOR (11 downto 0) := (others=>'0');

--signal VSYNC_signal : STD_LOGIC := '0'; --used to let the colored bars know when to move NEW
--signal motion_signal : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
--signal adder_signal :STD_LOGIC_VECTOR (5 downto 0) := "000000";

begin
    clock: clk_div port map(clk_in=>clk,clk_out=>clk_sig); --clock divider from 50 MHz to 10 Mhz
    
    h_pixel_counter: counter generic map(output_size=>9,output_limit=>264) --counter for the horizontal beam position
                             port map(clk=>clk_sig,output=>h_counter,overflow=>v_counter_clk);
    v_pixel_counter: counter generic map(output_size=>10,output_limit=>628) --counter for the vertical beam position
                             port map(clk=>v_counter_clk,output=>v_counter); --advanced by the overflowing of the horizontal beam position
                         
    sync_component: sync_unit port map(h_counter=>h_counter,v_counter=>v_counter,HSYNC=>HSYNC,VSYNC=>VSYNC); --unit which controls when the HSYNC and VSYNC pulses happen
	 
	 ROM: ROMTest port map(address=>memory_address,clock=>clk_sig,q=>color);
	 
--	 motion: counter generic map(output_size=>8,output_limit=>200) --NEW
--						  port map(clk=>VSYNC_signal,output=>motion_signal);

	 memory_address (8 downto 0) <= h_counter;
	 memory_address (11 downto 10) <= v_counter (1 downto 0);

	 --color<="111"; --white?
    --color<=v_counter (7 downto 5); --Make some horizontal stripes based on the changing values of v_counter 
	 --color<=h_counter (8 downto 6); --Make some vertical stripes based on the changing values of h_counter (blurry due to the speed of the scanline?)
	 --adder_signal<=STD_LOGIC_VECTOR(unsigned(v_counter (9 downto 4)) + unsigned(motion_signal (5 downto 0)));
	 --color<=adder_signal (5 downto 3);
end Behavioral;