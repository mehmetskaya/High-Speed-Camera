
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

type state_type is(sleep,awake,ready,selected,busy,done);

signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "sleep";

begin

tx_empty <= tx_is_empty;
rx_full <= rx_is_full;

process (clk, ss, reset_n)

begin

  if reset_n = '1' then
  state <= awake;
  tx_reg <= (others =>'Z');
  rx_reg <= (others =>'Z');
  bit_cnt <= 0;
  sck_cnt <= 0;
  sck_hi <= 'Z';
  tx_is_empty <= 'Z';
  rx_is_full <= 'Z';
  
  elsif clk'event and clk = '1' then
  
  case state is
  
  when awake =>
  if reset_n = '0'  then
  state <= ready;
  miso <= '0';
  sck_hi <= '0';
  tx_is_empty <= '1';
  rx_is_full <= '0';
  end if;

  when ready =>
  if ss = "00" and reset_n = '0' and mosi'event then
  state <= selected;
  end if;

  when selected =>
  sck_cnt <= 0;
  bit_cnt <= 0;
  rx_reg <= (others =>'0');
  if tx_wr = '1' then
  sck_hi <= '1';
  tx_reg <= tx_di ( 6 downto 0) & '0';
  miso <= tx_di(7);
  tx_is_empty <= '0';
  state <= busy;
  elsif rx_rd = '1' then
  sck_hi <= '1';
  rx_reg(0) <= mosi;
  state <= busy;
  else
  state <= selected;
  end if;
  
  when busy => 
  if bit_cnt<=7 and (tx_wr = '1' or rx_rd = '1') then
  sck_cnt <= sck_cnt + 1;
    if sck_cnt=63 then
    bit_cnt <= bit_cnt + 1;
    sck_cnt <= 0;
     if tx_wr = '1' then
     miso <= tx_reg(7);
     tx_reg <= tx_reg ( 6 downto 0) & '0';
     else
     rx_reg <= rx_reg ( 6 downto 0) & mosi;
     end if;
    end if;
  end if;
  if bit_cnt=7 and sck_cnt=63 then
    if rx_rd = '1' then
    rx_is_full <= '1';
    rx_do <= rx_reg;
    state <= done;
    end if;
    if tx_wr = '1' then
    tx_is_empty <= '1';
    tx_reg <= tx_reg;
    state <= done;
    end if;
  end if;
  
  when done =>
  state <= awake;
  rx_is_full <= '0';
  sck_hi <= '0';
  sck_cnt <= 0;
  bit_cnt <= 0;

  
  when sleep =>
  state <= sleep;
  
  end case;
  
  end if;
  
end process;
end Behavioral;

