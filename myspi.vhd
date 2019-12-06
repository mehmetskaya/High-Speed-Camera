
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity myspi is
    Port ( clk : in  STD_LOGIC;
           ss : in  STD_LOGIC_VECTOR (1 downto 0);
           sck : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           sck_hi : out  STD_LOGIC;
           tx_wr : in  STD_LOGIC;
           tx_di : in  STD_LOGIC_VECTOR (7 downto 0);
           miso : out  STD_LOGIC;
           tx_empty : out  STD_LOGIC;
           rx_rd : in  STD_LOGIC;
           mosi : in  STD_LOGIC;
           rx_do : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_full : out  STD_LOGIC);
end myspi;

architecture Behavioral of myspi is

signal tx_reg : STD_LOGIC_VECTOR ( 7 downto 0);
signal rx_reg : STD_LOGIC_VECTOR ( 7 downto 0);
signal bit_cnt : integer:=0 ;
signal sck_cnt : integer:=0;
signal rx_is_full : STD_LOGIC;
signal tx_is_empty : STD_LOGIC;

type state_type is(off,sleep,awake,ready,shifting,done);

signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "off";

begin

tx_empty <= tx_is_empty;
rx_full <= rx_is_full;

process (clk, ss, reset_n, sck)

begin

  if reset_n = '1' then
  state <= sleep;
  tx_reg <= (others =>'Z');
  rx_reg <= (others =>'Z');
  bit_cnt <= 0;
  sck_cnt <= 0;
  sck_hi <= 'Z';
  tx_is_empty <= 'Z';
  rx_is_full <= 'Z';
  
  elsif clk'event and clk = '1' then
  
  case state is
  
  when sleep =>
  sck_hi <= '0';
  tx_is_empty <= '1';
  rx_is_full <= '0';
  tx_reg <= (others =>'0');
  rx_reg <= (others =>'0');
  if reset_n = '0'  then
  state <= awake;
  else
  state <= sleep;
  end if;
  
  when awake =>
  if reset_n = '0' then
   if ss = "00" then
   sck_cnt <= 0;
   bit_cnt <= 0;
   state <= ready;
   else
   state <= awake;
   end if;
  else
  state <= sleep;
  end if;
  

  when ready =>
  if ss = "00" then
   if sck'event and sck='1' then
   rx_reg(0)<= mosi;
   bit_cnt <= 1;
   tx_is_empty <= '0';
   sck_hi <= '1';
   state <= shifting;
   else
   state <= ready;
   end if;
  else
  state <= awake;
  end if;
  
  when shifting =>
  sck_cnt <= sck_cnt + 1;
  if sck'event and sck='1' then
  bit_cnt <= bit_cnt + 1;
  sck_cnt <= 0;
  miso <= tx_reg(7);
  tx_reg <= tx_reg ( 6 downto 0) & '0';
  rx_reg <= rx_reg ( 6 downto 0) & mosi;
  end if;
  if bit_cnt=8 and sck_cnt = 19 then
  sck_cnt <= 0;
  sck_hi <= '0';
  bit_cnt <= 0;
    if rx_rd = '1' then
    rx_is_full <= '1';
    rx_do <= rx_reg;
    state <= done;
    end if;
    if tx_wr = '1' then
    tx_is_empty <= '1';
    tx_reg <= tx_di( 6 downto 0) & '0';
    miso <= tx_di(7);
    state <= done;
    else
    miso <= '0';
    state <= done;
    end if;
  end if;

  when done =>
  state <= awake;
  rx_is_full <= '0';
 
  when others =>
  state <= off;
  
  end case;
  
  end if;
  
end process;
end Behavioral;
