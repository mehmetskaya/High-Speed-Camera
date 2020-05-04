------------------------------------------------------------------------------------
-- SPI MASTER FOR PYTHON300/500/1300 IMAGE SENSOR
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity python300_spi is
    Port ( clk         : in   STD_LOGIC;
           enable_n    : in   STD_LOGIC;
           reset       : in   STD_LOGIC;
           sck_in      : in   STD_LOGIC;
           we          : in   STD_LOGIC; -- if we =1 then write , if we=0 then read
           miso        : in   STD_LOGIC;
           tx_d        : in   STD_LOGIC_VECTOR (15 downto 0); -- to mosi
           address     : in   STD_LOGIC_VECTOR (8 downto 0);  -- to mosi         
           rx_d        : out  STD_LOGIC_VECTOR (15 downto 0); -- from miso
           sck_out     : out  STD_LOGIC;
           mosi        : out  STD_LOGIC;
           ss_n        : out  STD_LOGIC;
           tx_empty    : out  STD_LOGIC;
           rx_full     : out  STD_LOGIC);
end entity;

architecture rtl of python300_spi is

signal tx_reg        : STD_LOGIC_VECTOR ( 15 downto 0);
signal rx_reg        : STD_LOGIC_VECTOR ( 15 downto 0);
signal address_reg   : STD_LOGIC_VECTOR ( 9 downto 0);
signal bit_cnt       : STD_LOGIC_VECTOR ( 4 downto 0);
signal rst_cnt       : STD_LOGIC_VECTOR ( 4 downto 0);
signal rx_is_full    : STD_LOGIC;
signal tx_is_empty   : STD_LOGIC;
signal sckd          : STD_LOGIC;
signal sck           : STD_LOGIC;

type state_type is ( off, ready, start, write_address, write_data, read_data, done );

signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "off";

begin

tx_empty <= tx_is_empty;
rx_full  <= rx_is_full;

   spi_process: process (clk, reset, enable_n)
   begin

      if reset = '1' and enable_n= '1' then
         state       <= ready;
         tx_is_empty <= '1';
         rx_is_full  <= '0';
         ss_n        <= '1';
         rx_reg      <= (others=>'0');
         rx_d        <= (others=>'0');
         address_reg <= (others=>'0');
         tx_reg      <= (others=>'0');
         bit_cnt     <= (others=>'0');
         rst_cnt     <= (others=>'0');

      elsif clk'event and clk = '1' then
      
         if rst_cnt="01110" and state /= start and state /= done then
            rst_cnt <= (others=>'0');
         elsif (state = start and rst_cnt="01110") or (state = done and rst_cnt="11100") then
            rst_cnt <= (others=>'0');
         elsif state/= ready then
            rst_cnt <= rst_cnt+'1';
         end if;
         
         if state = write_data or state = read_data or state = write_address then
            sck_out <= sck_in;         
         else
            sck_out <= '0';
         end if;
         
         sck  <= sck_in;
         sckd <= sck;
         
         case state is

            when ready =>
               if reset = '0' and enable_n = '0' and (sck='1' and sckd='0') then -- when rising edge of sck
                  state    <= start;
                  ss_n     <= '0';
                  mosi     <= '0';
               else
                  state <= ready;
                  ss_n     <= '1';
               end if;

            when start =>
               if rst_cnt="01110" then
                  state       <= write_address;
                  bit_cnt     <= bit_cnt+'1';
                  mosi        <= address_reg(9);
                  address_reg <= address_reg(8 downto 0) & '0';
               else
                  state       <= start;
                  address_reg <= address & we;
               end if;               

            when write_address =>
               if (sck='0' and sckd='1')and bit_cnt/="01010"  then -- when falling edge of sck
                  bit_cnt     <= bit_cnt+'1';
                  mosi        <= address_reg(9);
                  address_reg <= address_reg(8 downto 0) & '0';
               end if;
               if bit_cnt="01010" and we = '1' and rst_cnt="01110" and sckd = '1' then
                  bit_cnt     <= (others=>'0');
                  tx_is_empty <= '0';
                  mosi        <= tx_d(15);
                  tx_reg      <= tx_d(14 downto 0) & '0';
                  state       <= write_data;                            
               end if;
               if bit_cnt="01010" and we = '0' and rst_cnt="01110" and sckd = '1' then
                  bit_cnt <= (others=>'0');
                  state   <= read_data;          
               end if;

            when write_data =>
               if (sck='0' and sckd='1') and bit_cnt/="10000"  then -- when falling edge of sck
                  bit_cnt  <= bit_cnt+'1';
                  mosi     <= tx_reg(15);
                  tx_reg   <= tx_reg(14 downto 0) & '0';
               end if;
               if bit_cnt="10000" then
                  state    <= done;
               end if;

            when read_data =>
               if (sck='0' and sckd='1')and bit_cnt/="10000"  then -- when falling edge of sck
                  bit_cnt <= bit_cnt+'1';
                  rx_reg  <= rx_reg(14 downto 0) & miso;
                  if bit_cnt = "01111" then 
                     rx_is_full <= '1';
                  end if;
               end if;
               if bit_cnt="10000" then
                  state <= done;
                  rx_d  <= rx_reg;
               end if;
               
            when done =>
               if tx_is_empty = '0' then
                  tx_is_empty <= '1';
               elsif rst_cnt="11100" then
                  rx_is_full <= '0';
                  mosi       <= '0';
                  bit_cnt    <= (others=>'0');
                  state      <= ready;
               end if;
               
            when others =>
               state <= off;

         end case;

      end if;
     
   end process;
   
end architecture;
