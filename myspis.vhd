library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity myspis is

 Port ( clk : in STD_LOGIC;
        clr : in std_logic;
        data : in STD_LOGIC_VECTOR(7 downto 0);
        start : in STD_LOGIC;
        done : out STD_LOGIC;
        ss : out STD_LOGIC;
        mosi : out STD_LOGIC;
        sck : out STD_LOGIC);
		  
end myspis;

architecture Behavioral of myspis is

signal counter: STD_LOGIC_VECTOR (3 downto 0);
signal sclk: std_logic;
signal temp: std_logic_vector(7 downto 0);

type state_type is(initial,copy,clk_gen,shifting,completed);
signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "initial";

begin

process (clk, clr)

begin
  if clr = '1' or clr = 'U' then
     done <= '0';
     ss <= '1';
     mosi <= '0';
     sck <= '1';
     counter <= "0000";
     state <= initial;
  elsif clk'event and clk = '1' then
    case state is
       when initial =>
           if start = '0' then
              state <= completed;
           else
              counter <= "0000";
              state <= copy;
              ss <= '0';
           end if;
           sclk <= '1';
           done <= '0';
       when copy =>
           temp <= data;
           state <= clk_gen;
       when clk_gen =>
           sclk <= not sclk;
           state <= shifting;
       when shifting =>
           if counter = "1000" then
              done <= '1';
              state <= completed;
           else
              counter <= counter + '1';
              state <= clk_gen;
           end if;
           mosi <= temp(7);
           temp <= (temp(6 downto 0) & '0');
           sclk <= not sclk;
       when completed =>
           ss <= '1';
           state <= initial;
       when others =>
           state <= initial;
    end case;
    sck <= sclk;
  end if;
  
end process;

end Behavioral;