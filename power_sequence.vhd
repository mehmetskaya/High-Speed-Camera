library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity power_sequence is

Port(     
      clk            : in STD_LOGIC;
      sw             : in STD_LOGIC;
      en             : in STD_LOGIC;
      C5514_enable   : out STD_LOGIC;
      Enable_VDD_18  : out STD_LOGIC;
      Enable_VDD_33  : out STD_LOGIC;
      Enable_VDD_pix : out STD_LOGIC;
      clk_en         : out STD_LOGIC;
      reset_en       : out STD_LOGIC;
      spi_upload     : out STD_LOGIC;
      out_StopCount  : out STD_LOGIC 
   );
		 
end power_sequence;

architecture Behavioral of power_sequence is

signal sw_in : STD_LOGIC;
signal en_in : STD_LOGIC;
signal counter : integer :=0;
signal enable_pins :STD_LOGIC_VECTOR ( 2 downto 0);
signal StopCount :STD_LOGIC;

type state_type is(sleep,awake,ready,power_up_seq,onn,power_down_seq,off);
signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "sleep";

begin

sw_in <= sw;
en_in <= en;
out_StopCount <= StopCount;

process (clk, sw_in, en_in)

begin
  
  
   if sw_in = '0' and en_in = '0' then
       state <= awake;
       StopCount <= '1';
       C5514_enable   <= '0';
       Enable_VDD_18  <= '0';
       Enable_VDD_33  <= '0';
       Enable_VDD_pix <= '0';
       clk_en         <= '0';
       reset_en       <= '0';
       spi_upload     <= '0';
       enable_pins    <= (others => '0');
     
   elsif clk'event and clk = '1' then
    
      case state is

      when awake =>
         if en_in = '1' then
           state <= ready;
         else
           state <=awake ;
         end if;

      when ready =>
         if en_in = '1' then
            if sw_in = '1' then
               state <= power_up_seq;
               StopCount <= '0';  
            else 
               state <=off ;
            end if;
         else
            state <=ready;
         end if;

      when off =>
      StopCount <= '1';
         if en_in = '1' then
            state <= off;
               if sw_in = '1' then
                  state <= power_up_seq;
               elsif (sw_in = '0' or sw_in = 'U') then
                  counter        <= 0;
                  C5514_enable   <= '0';
                  Enable_VDD_18  <= '0';
                  Enable_VDD_33  <= '0';
                  Enable_VDD_pix <= '0';
                  clk_en         <= '0';
                  reset_en       <= '0';
                  spi_upload     <= '0';
                  state <= off;
               end if;
         else
            state <= ready;
         end if;         
           
      when onn =>
      StopCount <= '1';
         if en_in = '1' then
            state <= onn;
               if sw_in = '0' or sw_in = 'U'  then
                  state <= power_down_seq;
               else
                  counter        <= 0;
                  C5514_enable   <= '1';
                  Enable_VDD_18  <= '1';
                  Enable_VDD_33  <= '1';
                  Enable_VDD_pix <= '1';
                  clk_en         <= '1';
                  reset_en       <= '1';
                  spi_upload     <= '1';
                  state <= onn;
               end if;
         else
            state <= ready;
         end if;

      when power_up_seq =>
      StopCount <= '0';
         if en_in = '1' then
            if (sw_in = '0'  or sw_in = 'U') then
               state <= power_down_seq;
               counter <= 0;
               enable_pins    <= ("111"-enable_pins)+'1';
            else
               counter <= counter + 1;
                  if counter = 2000000 then
                     enable_pins <= enable_pins + '1';
                     counter <= 0;
                  end if;
                  -- every 2 000 000 count is equal to 20ms for clk of 10ns.          
                  case enable_pins is
                     when "001" =>
                         C5514_enable <= '1';
                     when "010" =>
                         Enable_VDD_18 <= '1';
                     when "011" =>
                         Enable_VDD_33 <= '1';
                     when "100" =>
                         Enable_VDD_pix <= '1';
                     when "101" =>
                         clk_en <= '1';
                     when "110" => 
                         reset_en <= '1';
                     when "111" =>   
                         spi_upload <= '1';
                         state <= onn;
                         enable_pins    <= (others => '0');
                         counter <= 0;
                     when others =>
                  end case;
            end if;
         else
            state <= power_down_seq;
         end if;
        
      when power_down_seq =>
      StopCount <= '0';
         if en_in = '1' then 
            if (sw_in = '0' or sw_in = 'U')then
               counter <= counter + 1;
                  if counter = 2000000 then
                  enable_pins <= enable_pins + '1';
                  counter <= 0;
                  end if;
                  -- every 2 000 000 count is equal to 20ms for clk of 10ns.             
                  case enable_pins is
                     when "001" =>
                         spi_upload <= '0';
                     when "010" =>
                         reset_en <= '0';
                     when "011" =>
                         clk_en <= '0';
                     when "100" =>
                         Enable_VDD_pix <= '0';
                     when "101" =>
                         Enable_VDD_33 <= '0';
                     when "110" =>
                         Enable_VDD_18 <= '0';
                     when "111" =>   
                         C5514_enable <= '0';
                         state <= off;
                         enable_pins    <= (others => '0');
                         counter <= 0;
                    when others =>
                  end case;
            else
               counter <= 0;
               state <= power_up_seq;
               enable_pins    <= ("111"-enable_pins)+'1';
            end if;
         else
            state <= power_up_seq;
         end if;

      when others =>
      
      end case;
    
   end if;
  
end process;

end Behavioral;
