--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:37:54 11/13/2019
-- Design Name:   
-- Module Name:   Y:/Sirac/FPGA_research/power_up/power_sequence_tb.vhd
-- Project Name:  power_up
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: power_up
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY power_sequence_tb IS
END power_sequence_tb;
 
ARCHITECTURE behavior OF power_sequence_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT power_sequence
    PORT(
         clk_in : IN  std_logic;
         sw : IN  std_logic;
         C5514_enable : OUT  std_logic;
         Enable_VDD_18 : OUT  std_logic;
         Enable_VDD_33 : OUT  std_logic;
         Enable_VDD_pix : OUT  std_logic;
         clk_en : OUT  std_logic;
         reset_en : OUT  std_logic;
         spi_upload : OUT  std_logic;
			state_reg  : out STD_LOGIC_VECTOR ( 2 downto 0);
         out_StopCount : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic;
   signal sw : std_logic ;

 	--Outputs
   signal C5514_enable : std_logic;
   signal Enable_VDD_18 : std_logic;
   signal Enable_VDD_33 : std_logic;
   signal Enable_VDD_pix : std_logic;
   signal clk_en : std_logic;
   signal reset_en : std_logic;
   signal spi_upload : std_logic;
	signal state_reg :STD_LOGIC_VECTOR ( 2 downto 0);
   signal out_StopCount : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: power_sequence PORT MAP (
          clk_in => clk_in,
          sw => sw,
          C5514_enable => C5514_enable,
          Enable_VDD_18 => Enable_VDD_18,
          Enable_VDD_33 => Enable_VDD_33,
          Enable_VDD_pix => Enable_VDD_pix,
          clk_en => clk_en,
          reset_en => reset_en,
          spi_upload => spi_upload,
			 state_reg => state_reg,
          out_StopCount => out_StopCount
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      
      wait for 20.1 ms;	
      sw <= '0';
		
		-- insert stimulus here 
      wait for 20.1 ms;
      sw <= '1';
      wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '0';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '1';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '0';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '1';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= 'U';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '1';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= 'U';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '1';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= 'U';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		sw <= '0';
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;
		wait for 20.1 ms;

      assert false
      report "simulation ended"
      severity failure;
		
   end process;

END;
