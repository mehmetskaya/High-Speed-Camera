LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY python300_spi_tb IS
END python300_spi_tb;
 
ARCHITECTURE behavior OF python300_spi_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT python300_spi
    PORT(
         clk : IN  std_logic;
         enable_n : IN  std_logic;
         sck_in : IN  std_logic;
         reset : IN  std_logic;
         we : IN  std_logic;
         miso : IN  std_logic;
         tx_d : IN  std_logic_vector(15 downto 0);
         address : IN  std_logic_vector(8 downto 0);
         rx_d : OUT  std_logic_vector(15 downto 0);
         sck_out : OUT  std_logic;
         mosi : OUT  std_logic;
         ss_n : OUT  std_logic;
         tx_empty : OUT  std_logic;
         rx_full : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic ;
   signal enable_n : std_logic ;
   signal sck_in : std_logic ;
   signal reset : std_logic ;
   signal we : std_logic ;
   signal miso : std_logic ;
   signal tx_d : std_logic_vector(15 downto 0) ;
   signal address : std_logic_vector(8 downto 0) ;

 	--Outputs
   signal rx_d : std_logic_vector(15 downto 0);
   signal sck_out : std_logic;
   signal mosi : std_logic;
   signal ss_n : std_logic;
   signal tx_empty : std_logic;
   signal rx_full : std_logic;
   
 	--Signals
   signal addr : std_logic_vector(8 downto 0);
   signal tx : std_logic_vector(15 downto 0);
   signal rx : std_logic_vector(15 downto 0);   

   -- Clock period definitions
   constant clk_period : time := 2.78 ns;
   constant sck_period : time := 83.4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: python300_spi 
   PORT MAP (
          clk      => clk,
          enable_n => enable_n,
          sck_in   => sck_in,
          reset    => reset,
          we       => we,
          miso     => miso,
          tx_d     => tx_d,
          address  => address,
          rx_d     => rx_d,
          sck_out  => sck_out,
          mosi     => mosi,
          ss_n     => ss_n,
          tx_empty => tx_empty,
          rx_full  => rx_full
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;

   -- Clock process definitions
   sck_process :process
   begin
		sck_in <= '0';
		wait for sck_period/2;
		sck_in <= '1';
		wait for sck_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
      
      reset    <= '1';
      enable_n <= '1';
      wait for sck_period;
      reset <= '0';
      
      --READ Data w/ MISO
      wait for 2*sck_period;
      enable_n <= '0';
      address  <= "111100101";
      rx       <= "1011001011010111";
      we       <= '0'; -- read
      miso     <='0';
      wait for sck_period;
      for i in 1 to 10 loop
        wait for sck_period;
      end loop;
      wait for sck_period/2;
      for i in 1 to 16 loop
        miso <= rx(16-i); -- shift data in with miso to read
        wait for sck_period;
      end loop;
      miso  <='0';
      wait for sck_period/2;
      enable_n <= '1';
      wait for sck_period;

      --WRITE Data w/ MOSI
      wait for 2*sck_period;
      enable_n <= '0';
      address  <= "111100101";
      we       <='1'; -- write
      tx_d     <= rx_d; -- loop back in the data read in to write out
      wait for sck_period;
      for i in 1 to 10 loop
        wait for sck_period;
      end loop;
      for i in 1 to 16 loop
        wait for sck_period; -- shift data out with mosi to write
      end loop;
      wait for sck_period;
      enable_n <= '1';
      wait for sck_period;
      
      wait for sck_period;
      reset <= '1';
      wait for sck_period;
      assert false
      report "Simulation Ended"
      severity failure;
      
   end process;

END;
