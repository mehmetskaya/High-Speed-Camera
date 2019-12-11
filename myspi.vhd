
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity myspi is
    Port ( clk : in  STD_LOGIC;
           ss : in  STD_LOGIC_VECTOR (1 downto 0);
           sck : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           sck_hi : out  STD_LOGIC;
           tx_wr : in  STD_LOGIC;
           tx_d : in  STD_LOGIC_VECTOR (7 downto 0);
           miso : out  STD_LOGIC;
           tx_empty : out  STD_LOGIC;
           rx_rd : in  STD_LOGIC;
           mosi : in  STD_LOGIC;
           rx_d : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_full : out  STD_LOGIC);
end myspi;

architecture Behavioral of myspi is

signal tx_reg : STD_LOGIC_VECTOR ( 7 downto 0);
signal rx_reg : STD_LOGIC_VECTOR ( 7 downto 0);

signal bit_cnt : STD_LOGIC_VECTOR ( 3 downto 0);
signal rst_cnt : STD_LOGIC_VECTOR ( 5 downto 0);
signal rx_is_full : STD_LOGIC;
signal tx_is_empty : STD_LOGIC;
signal sckd        :std_logic;
signal sckdd       :std_logic;
signal filter_sck    :std_logic;
signal filter_sckd   :std_logic;
signal mosid       :std_logic;
signal mosidd      :std_logic;
signal filter_mosi    :std_logic;
signal rxfd        :std_logic;

type state_type is(off,sleep,awake,ready,shifting,done);

signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "off";

begin

tx_empty <= tx_is_empty;
rx_full <= rx_is_full;

process (clk, ss, reset, sck)

begin

  if reset = '1' then
  state <= sleep;
  tx_reg <= (others =>'Z');
  rx_reg <= (others =>'Z');
  sck_hi <= 'Z';
  tx_is_empty <= 'Z';
  rx_is_full <= 'Z';
  
  elsif clk'event and clk = '1' then
  
  sckd<=sck;
  sckdd<=sckd;
  filter_sckd<=filter_sck;
  
    if sckd='1' and sckdd='1' then
      filter_sck<='1';
    elsif sckd='0' and sckdd='0' then
      filter_sck<='0';
    end if;
    
  mosid<=mosi;
  mosidd<=mosid;
  
    if mosid='1' and mosidd='1' then
      filter_mosi<='1';
    elsif mosid='0' and mosidd='0' then
      filter_mosi<='0';
    end if;
  
  case state is
  
  when sleep =>
  sck_hi <= '0';
  tx_is_empty <= '1';
  rx_is_full <= '0';
  tx_reg <= (others =>'0');
  rx_reg <= (others =>'0');
  bit_cnt <= (others =>'0');
  rst_cnt <= (others =>'0');
  if reset = '0'  then
  state <= awake;
  else
  state <= sleep;
  end if;
  
  when awake =>
  if reset = '0' then
   if ss = "00" then
   state <= ready;
   else
   state <= awake;
   end if;
  else
  state <= sleep;
  end if;
  
  when ready =>
  if ss = "00" then
   if (filter_sck='1' and filter_sckd='0') then
   rx_reg <= rx_reg ( 6 downto 0) & filter_mosi;
   miso <= tx_reg(7);
   tx_reg <= tx_reg ( 6 downto 0) & '0';
   bit_cnt <= bit_cnt+'1';
   sck_hi <= '1';
   state <= shifting;
   else
   state <= ready;
   end if;
  else
  state <= awake;
  end if;
  
  when shifting =>
  rst_cnt <= rst_cnt+'1';
  if (filter_sck='1' and filter_sckd='0')and bit_cnt/="1000" then
  bit_cnt <= bit_cnt+'1';
  rst_cnt <=(others =>'0');
  miso <= tx_reg(7);
  tx_reg <= tx_reg ( 6 downto 0) & '0';
  rx_reg <= rx_reg ( 6 downto 0) & filter_mosi;
  end if;
  if bit_cnt="1000" then
  rxfd <= '1';
    if rst_cnt="10011" then
    state <= done;
    rst_cnt <=(others =>'0');
    end if;
    if tx_is_empty = '0' then
    tx_is_empty <= '1';
    end if;
    if rx_rd = '1' then
    rx_is_full <= '1';
    rx_d <= rx_reg;
    state <= done;
    end if;
    if tx_wr = '1' then
    tx_reg <= tx_d( 6 downto 0) & '0';
    miso <= tx_d(7);
    tx_is_empty <= '0';
    state <= done;
    end if;
  end if;

  when done =>
  rxfd <= '0';
  rx_is_full <= '0';
  sck_hi <= '0';
  bit_cnt <= (others =>'0');
  rst_cnt <= (others =>'0');
  state <= ready;

  when others =>
  state <= off;
  
  end case;
  
  end if;
  
end process;
end Behavioral;
