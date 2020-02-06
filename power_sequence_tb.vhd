LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity power_sequence_tb IS
end power_sequence_tb;
 
architecture behavior of power_sequence_tb is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component power_sequence
    port(
         clk : IN  std_logic;
         sw : IN  std_logic;
         en : IN  std_logic;
         C5514_enable : OUT  std_logic;
         Enable_VDD_18 : OUT  std_logic;
         Enable_VDD_33 : OUT  std_logic;
         Enable_VDD_pix : OUT  std_logic;
         clk_en : OUT  std_logic;
         reset_en : OUT  std_logic;
         spi_upload : OUT  std_logic;
         out_StopCount : OUT  std_logic
        );
    end component;
    

   --Inputs
   signal clk : std_logic;
   signal sw : std_logic ;
   signal en : std_logic ;

 	--Outputs
   signal C5514_enable : std_logic;
   signal Enable_VDD_18 : std_logic;
   signal Enable_VDD_33 : std_logic;
   signal Enable_VDD_pix : std_logic;
   signal clk_en : std_logic;
   signal reset_en : std_logic;
   signal spi_upload : std_logic;
   signal out_StopCount : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant on_time : time := 20 ms;
   
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: power_sequence PORT MAP (
          clk => clk,
          sw => sw,
          en => en,
          C5514_enable => C5514_enable,
          Enable_VDD_18 => Enable_VDD_18,
          Enable_VDD_33 => Enable_VDD_33,
          Enable_VDD_pix => Enable_VDD_pix,
          clk_en => clk_en,
          reset_en => reset_en,
          spi_upload => spi_upload,
          out_StopCount => out_StopCount
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      sw <= '1';
      wait for 4*on_time;
      en <= '0';
      sw <= '0';
      wait for 4*on_time;
      en <= '1';
      wait for 4*on_time;
      sw <= '1';
      wait for 9*on_time;
		sw <= '0';
		wait for 9*on_time;
		sw <= '1';
		wait for 5*on_time;
		sw <= '0';
		wait for 5*on_time;
		sw <= '1';
		wait for 6*on_time;
		sw <= 'U';
      wait for 5*on_time;
      en <= '0';
		wait for 5*on_time;
		sw <= '0';
		wait for 5*on_time;
		sw <= '1';
		wait for 6*on_time;      
      en <= '1';
      wait for 5*on_time;
		sw <= '1';
		wait for 9*on_time;
		sw <= 'U';
		wait for 4*on_time;
		sw <= '1';
		wait for 6*on_time;
		sw <= 'U';
		wait for 5*on_time;
		sw <= '0';
		wait for 9*on_time;

      assert false
      report "simulation ended"
      severity failure;
		
   end process;

end;
