library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity myspi_tb is
end myspi_tb;
 
architecture Behavioral of myspi_tb is
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component myspi
    port(
         clk : IN  std_logic;
         sck : IN  std_logic;
         ss : IN  std_logic_vector(1 downto 0);
         reset : IN  std_logic;
         sck_hi : OUT  std_logic;
         tx_wr : IN  std_logic;
         tx_d : IN  std_logic_vector(7 downto 0);
         miso : OUT  std_logic;
         tx_empty : OUT  std_logic;
         rx_rd : IN  std_logic;
         mosi : IN  std_logic;
         rx_d : OUT  std_logic_vector(7 downto 0);
         rx_full : OUT  std_logic
        );
    end component;
    

   --Inputs
   signal clk : std_logic;
   signal sck : std_logic;
   signal ss : std_logic_vector(1 downto 0);
   signal reset : std_logic;
   signal tx_wr : std_logic ;
   signal tx_d : std_logic_vector(7 downto 0);
   signal rx_rd : std_logic ;
   signal mosi : std_logic ;
   signal di : std_logic_vector(7 downto 0);

 	--Outputs
   signal sck_hi : std_logic;
   signal miso : std_logic;
   signal tx_empty : std_logic;
   signal rx_d : std_logic_vector(7 downto 0);
   signal rx_full : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant sck_period : time := 200 ns;
   
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: myspi port map (
          clk => clk,
          sck => sck,
          ss => ss,
          reset => reset,
          sck_hi => sck_hi,
          tx_wr => tx_wr,
          tx_d => tx_d,
          miso => miso,
          tx_empty => tx_empty,
          rx_rd => rx_rd,
          mosi => mosi,
          rx_d => rx_d,
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
      wait for sck_period;
      reset <= '0';
      sck<='0';
      wait for sck_period;
      reset <= '1';
      
      wait for sck_period;
      reset <= '0';
      wait for sck_period;
      ss <= "00";
      wait for sck_period;
      
      wait for sck_period;
      di <= "11110010";
      wait for sck_period;
      for i in 1 to 8 loop
        mosi <= di(8-i); 
        wait for sck_period/2;
        sck<='1'; 
        wait for sck_period/2;
        sck<='0';
      end loop;
      rx_rd <= '1';
      tx_wr <= '1';
      tx_d <= "10000110";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for sck_period;
            
      wait for sck_period;
      di <= "00000011";
      wait for sck_period;
      for i in 1 to 8 loop
        mosi <= di(8-i); 
        wait for sck_period/2;
        sck<='1'; 
        wait for sck_period/2;
        sck<='0';
      end loop;
      rx_rd <= '0';
      tx_wr <= '1';
      tx_d <= "10001111";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for sck_period;
      
      wait for sck_period;
      di <= "11011011";
      wait for sck_period;
      for i in 1 to 8 loop
        mosi <= di(8-i); 
        wait for sck_period/2;
        sck<='1'; 
        wait for sck_period/2;
        sck<='0';
      end loop;
      rx_rd <= '0';
      tx_wr <= '0';
      tx_d <= "11001011";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for sck_period;
      
      wait for sck_period;
      di <= "10101011";
      wait for sck_period;
      for i in 1 to 8 loop
        mosi <= di(8-i); 
        wait for sck_period/2;
        sck<='1'; 
        wait for sck_period/2;
        sck<='0';
      end loop;
      rx_rd <= '1';
      tx_wr <= '0';
      tx_d <= "10010111";
      mosi <= '0';
      wait for clk_period;
      rx_rd <= '0';
      tx_wr <= '0';
      wait for sck_period;
      
      ss <= "01";
      wait for sck_period;
      ss <= "00";
      wait for sck_period;
      
      reset <= '1';
      wait for sck_period;
      assert false
      report "Simulation Ended"
      severity failure;
      
   end process;

end;
