----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2019 12:54:25 AM
-- Design Name: 
-- Module Name: power_sequence_top - Behavioral_Top
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

entity power_sequence_top is
    Port ( GCLK : in STD_LOGIC;
           SW0 : in STD_LOGIC;
           LD : out STD_LOGIC_VECTOR (6 downto 0));
end power_sequence_top;

architecture Behavioral_Top of power_sequence_top is

component power_sequence is 
  port (
         clk_in : in STD_LOGIC;
         sw : in STD_LOGIC;
         C5514_enable : out STD_LOGIC;
         Enable_VDD_18 : out STD_LOGIC;
         Enable_VDD_33 : out STD_LOGIC;
         Enable_VDD_pix : out STD_LOGIC;
         clk_en : out STD_LOGIC;
         reset_en : out STD_LOGIC;
         spi_upload : out STD_LOGIC
       );
end component;

begin
comp2 : power_sequence
  port map
   (
     clk_in => GCLK ,
     sw=> SW0,
     C5514_enable=> LD(0),
     Enable_VDD_18=> LD(1),
     Enable_VDD_33=> LD(2),
     Enable_VDD_pix=> LD(3),
     clk_en=> LD(4),
     reset_en=> LD(5),
     spi_upload=> LD(6)  
   );

end Behavioral_Top;
