----------------------------------------------------------------------------------
-- Company: Pollution Control Technologies
-- Engineer: Mehmet S KAYA
-- 
-- Create Date: 06/20/2018 01:02:01 PM
-- Design Name: Power Sequence
-- Module Name: power_sequence - Behavioral
-- Project Name: High Speed Camera
-- Target Devices: ZedBoard
-- Tool Versions: Vivado 2016.4
-- Description: Power Sequence of the image sensor
-- 
-- Dependencies: 
-- 
-- Revision: 
-- Revision 0.00 - File Created
-- Additional Comments: 
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity power_sequence is
    Port ( clk_in : in STD_LOGIC;
           sw : in STD_LOGIC;
           C5514_enable : out STD_LOGIC;
           Enable_VDD_18 : out STD_LOGIC;
           Enable_VDD_33 : out STD_LOGIC;
           Enable_VDD_pix : out STD_LOGIC;
           clk_en : out STD_LOGIC;
           reset_en : out STD_LOGIC;
           spi_upload : out STD_LOGIC);
end power_sequence;

architecture Behavioral of power_sequence is

signal sw_in : STD_LOGIC;
signal counter : integer :=0;
signal StopCount :std_logic := '1';

begin

sw_in <= sw;
 
process  (clk_in,StopCount,sw_in)

begin 
    
    if rising_edge(clk_in) then    
                
                if sw_in = '1' and StopCount = '1' then
                      
                counter <= counter + 1;
                --every 2000000 count is 20ms wait time on 10ns clock           
                           case counter is
                           when 2000000 =>
                               C5514_enable <= '1';
                           when 4000000 =>
                               Enable_VDD_18 <= '1';
                           when 6000000 =>
                               Enable_VDD_33 <= '1';
                           when 8000000 =>
                               Enable_VDD_pix <= '1';
                           when 10000000=>
                               clk_en <= '1';
                           when 12000000=> 
                               reset_en <= '1';
                           when 14000000=>   
                               spi_upload <= '1';
                               StopCount <= '0';
                               counter <= 0;
                           when others =>
                           end case;

                elsif sw_in = '0' and StopCount = '0' then                           
                
                counter <= counter + 1;
                --every 2000000 count is 20ms wait time on 10ns clock                                  
                           case counter is
                           when 2000000 =>
                               spi_upload <= '0';
                           when 4000000 =>
                               reset_en <= '0';
                           when 6000000 =>
                               clk_en <= '0';
                           when 8000000 =>
                               Enable_VDD_pix <= '0';
                           when 10000000 =>
                               Enable_VDD_33 <= '0';
                           when 12000000=>
                               Enable_VDD_18 <= '0';
                           when 14000000=>   
                               C5514_enable <= '0';
                               StopCount <= '1';
                               counter <= 0;
                          when others =>
                           end case;
                
                elsif sw_in = '1' and StopCount = '0' then
                
                counter <= 0;
                C5514_enable <= '1';
                Enable_VDD_18 <= '1';
                Enable_VDD_33 <= '1';
                Enable_VDD_pix <= '1';
                clk_en <= '1';
                reset_en <= '1';
                spi_upload <= '1';                
                           
                else
                counter <= 0;
                C5514_enable <= '0';
                Enable_VDD_18 <= '0';
                Enable_VDD_33 <= '0';
                Enable_VDD_pix <= '0';
                clk_en <= '0';
                reset_en <= '0';
                spi_upload <= '0';
                
                end if;
   
      end if;

end process;
     
end Behavioral;    
