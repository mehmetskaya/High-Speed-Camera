LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY myspi_tb IS
END myspi_tb;
 
ARCHITECTURE behavior OF myspi_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT myspi
    PORT(
         clk : IN  std_logic;
         sck : IN  std_logic;
         ss : IN  std_logic_vector(1 downto 0);
         reset_n : IN  std_logic;
         sck_hi : OUT  std_logic;
         tx_wr : IN  std_logic;
         tx_di : IN  std_logic_vector(7 downto 0);
         miso : OUT  std_logic;
         tx_empty : OUT  std_logic;
         rx_rd : IN  std_logic;
         mosi : IN  std_logic;
         rx_do : OUT  std_logic_vector(7 downto 0);
         rx_full : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic;
   signal sck : std_logic;
   signal ss : std_logic_vector(1 downto 0);
   signal reset_n : std_logic;
   signal tx_wr : std_logic ;
   signal tx_di : std_logic_vector(7 downto 0);
   signal rx_rd : std_logic ;
   signal mosi : std_logic ;
   signal di : std_logic_vector(7 downto 0);

 	--Outputs
   signal sck_hi : std_logic;
   signal miso : std_logic;
   signal tx_empty : std_logic;
   signal rx_do : std_logic_vector(7 downto 0);
   signal rx_full : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant sck_period : time := 200 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: myspi PORT MAP (
          clk => clk,
          sck => sck,
          ss => ss,
          reset_n => reset_n,
          sck_hi => sck_hi,
          tx_wr => tx_wr,
          tx_di => tx_di,
          miso => miso,
          tx_empty => tx_empty,
          rx_rd => rx_rd,
          mosi => mosi,
          rx_do => rx_do,
          rx_full => rx_full
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;

   -- Stimulus process
   
   stim_proc_rising: process
   begin	 
      wait for 200ns;
      reset_n <= '0';
      sck<='0';
      wait for 200ns;
      reset_n <= '1';
      
      wait for 200ns;
      reset_n <= '0';
      wait for 200ns;
      ss <= "00";
      wait for 400ns;
      

      di <= "11111001";
      wait for 200ns;
      for i in 1 to 8 loop
        mosi <= di(8-i);
        sck<='1';
        wait for 100ns;
        sck<='0'; 
        wait for 100ns;
      end loop;
      rx_rd <= '1';
      tx_wr <= '1';
      tx_di <= "10001111";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for 400ns;
            
      di <= "01101011";
      wait for 200ns;
      for i in 1 to 8 loop
        mosi <= di(8-i);
        sck<='1';
        wait for 100ns;
        sck<='0'; 
        wait for 100ns;
      end loop;
      rx_rd <= '0';
      tx_wr <= '1';
      tx_di <= "01001101";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for 400ns;
      
      di <= "10101001";
      wait for 200ns;
      for i in 1 to 8 loop
        mosi <= di(8-i);
        sck<='1';
        wait for 100ns;
        sck<='0'; 
        wait for 100ns;
      end loop;
      rx_rd <= '1';
      tx_wr <= '0';
      tx_di <= "00000000";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for 400ns;
      
      di <= "10101001";
      wait for 200ns;
      for i in 1 to 8 loop
        mosi <= di(8-i);
        sck<='1';
        wait for 100ns;
        sck<='0'; 
        wait for 100ns;
      end loop;
      rx_rd <= '0';
      tx_wr <= '0';
      tx_di <= "00000000";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for 400ns;
      
      ss <= "01";
      wait for 200ns;
      ss <= "00";
      wait for 200ns;
      reset_n <= '1';
      
      
      wait for 200ns;
      assert false
      report "Simulation Ended"
      severity failure;
      
   end process;

END;
