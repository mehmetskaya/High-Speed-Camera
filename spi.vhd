library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity spi is
    Port ( clk      : in   STD_LOGIC;
           ss       : in   STD_LOGIC_VECTOR (1 downto 0);
           sck      : in   STD_LOGIC;
           reset    : in   STD_LOGIC;
           sck_hi   : out  STD_LOGIC;
           tx_wr    : in   STD_LOGIC;
           tx_d     : in   STD_LOGIC_VECTOR (7 downto 0);
           miso     : out  STD_LOGIC;
           tx_empty : out  STD_LOGIC;
           rx_rd    : in   STD_LOGIC;
           mosi     : in   STD_LOGIC;
           rx_d     : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_full  : out  STD_LOGIC);
end entity;

architecture rtl of spi is

signal tx_reg      : STD_LOGIC_VECTOR ( 7 downto 0);
signal rx_reg      : STD_LOGIC_VECTOR ( 7 downto 0);
signal bit_cnt     : STD_LOGIC_VECTOR ( 3 downto 0);
signal rst_cnt     : STD_LOGIC_VECTOR ( 5 downto 0);
signal rx_is_full  : STD_LOGIC;
signal tx_is_empty : STD_LOGIC;
signal sckd        : STD_LOGIC;
signal sckdd       : STD_LOGIC;
signal filter_sck  : STD_LOGIC;
signal filter_sckd : STD_LOGIC;
signal mosid       : STD_LOGIC;
signal mosidd      : STD_LOGIC;
signal filter_mosi : STD_LOGIC;
signal rxfd        : STD_LOGIC;
signal rst         : STD_LOGIC;

type state_type is ( off, sleep, ready, shifting, done );

signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "off";

begin

tx_empty     <= tx_is_empty;
rx_full      <= rx_is_full;

   spi_process: process (clk,reset)
   begin

      if rst = '1' or reset = '1' then
         state       <= sleep;
         tx_is_empty <= '1';
         rx_is_full  <= '0';
         sck_hi      <= '0';
         rx_reg      <= (others=>'0');
         rx_d        <= (others=>'0');
         tx_reg      <= (others=>'0');
         bit_cnt     <= (others=>'0');
         rst_cnt     <= (others=>'0');

      elsif clk'event and clk = '1' then

         rxfd        <= bit_cnt(3);
         sckd        <= sck;
         sckdd       <= sckd;
         filter_sckd <= filter_sck;

         if sckd='1' and sckdd='1' then
            filter_sck <= '1';
         elsif sckd='0' and sckdd='0' then
            filter_sck <= '0';
         end if;

         mosid <= mosi;
         mosidd <= mosid;

         if mosid='1' and mosidd='1' then
            filter_mosi <= '1';
         elsif mosid='0' and mosidd='0' then
            filter_mosi <= '0';
         end if;

         if (filter_sck='1' and filter_sckd='0') or bit_cnt="1000"  then
            rst_cnt <= (others=>'0');
         elsif bit_cnt/="0000" then
            rst_cnt <= rst_cnt+'1';
         end if;

         case state is

            when sleep =>
               if reset = '0' and ss = "00"  then
                  state <= ready;
               else
                  state <= sleep;
               end if;

            when ready =>
               if tx_wr = '1' then
                  tx_reg      <= tx_d( 6 downto 0) & '0';
                  miso        <= tx_d(7);
                  tx_is_empty <= '0';
               elsif rx_rd = '1' then
                  rx_d        <= rx_reg;
                  rx_is_full  <= '0';
               end if;
               if reset = '0' and ss = "00" then
                  if sckd='1' and sckdd='0' then
                     state   <= shifting;
                  else
                     state <= ready;
                  end if;
               else
                  state <= sleep;
               end if;

            when shifting =>
               if (filter_sck='1' and filter_sckd='0')and bit_cnt/="1000" then
                  sck_hi  <= '1';
                  bit_cnt <= bit_cnt+'1';
                  miso    <= tx_reg(7);
                  tx_reg  <= tx_reg ( 6 downto 0) & '0';
                  rx_reg  <= rx_reg ( 6 downto 0) & filter_mosi;
                  if bit_cnt = "0111" and tx_is_empty = '1' then 
                     rx_is_full <= '1';
                  end if; 
               end if;
               if bit_cnt="1000" then
                  state       <= done;
               end if;
               
            when done =>
               if tx_is_empty = '0' then
                  tx_is_empty <= '1';
               else
                  bit_cnt(3)  <= '0';
                  sck_hi      <= '0';
                  state       <= ready;
               end if;
               
            when others =>
               state <= off;

         end case;

      end if;
     
   end process;
   
   rst_process: process
   begin
   wait until clk'event and clk='1';
      if rst_cnt = "111111" then
         rst <= '1';
      else
         rst <= '0';
      end if;
   end process;
   
end architecture;
