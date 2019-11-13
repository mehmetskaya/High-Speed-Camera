library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity power_sequence is

Port (     clk_in         : in STD_LOGIC;
           sw             : in STD_LOGIC;
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
signal counter : integer :=0;
signal StopCount :std_logic := '1';

type state_type is(sleep,awake,power_up_seq,power_on,power_down_seq,power_down);
signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "sleep";

begin

sw_in <= sw;
out_StopCount <= StopCount;

process (clk_in, sw_in)

begin

  if sw_in = '0' and StopCount = '1' then
     state <= awake;
	             C5514_enable   <= '0';
                Enable_VDD_18  <= '0';
                Enable_VDD_33  <= '0';
                Enable_VDD_pix <= '0';
                clk_en         <= '0';
                reset_en       <= '0';
                spi_upload     <= '0';
	  
  elsif clk_in'event and clk_in = '1' then
    
	 case state is
	 
	    when awake =>
           if sw_in = '1' then
              state <= power_up_seq;
				  StopCount <= '0';
           elsif sw_in = '0' then
              state <=power_down ;
           end if;
	 
	    when power_down =>
		      if sw_in = '1' then
				    state <= power_up_seq;
	             
	         elsif sw_in = '0' or sw_in = 'U' then
				    counter        <= 0;
                C5514_enable   <= '0';
                Enable_VDD_18  <= '0';
                Enable_VDD_33  <= '0';
                Enable_VDD_pix <= '0';
                clk_en         <= '0';
                reset_en       <= '0';
                spi_upload     <= '0';
					 state <= power_down;
				end if;
				
       when power_up_seq =>
           if sw_in = '0' and StopCount = '0' then
			      state <= power_down_seq;
					counter <= 0;
			      StopCount <= '0';
		
           else
               counter <= counter + 1;
                          
                      case counter is
                           when 2000000 =>
                               C5514_enable <= '1';
                           when 4000000 =>
                               Enable_VDD_18 <= '1';
                           when 6000000 =>
                               Enable_VDD_33 <= '1';
                           when 8000000 =>
                               Enable_VDD_pix <= '1';
                           when 10000000=>
                               clk_en <= '1';
                           when 12000000=> 
                               reset_en <= '1';
                           when 14000000=>   
                               spi_upload <= '1';
										 StopCount <= '0';
										 state <= power_on;
										 counter <= 0;
                           when others =>
                        end case;
              
           end if;
			  
		 when power_down_seq =>
           if sw_in = '0' and StopCount = '0' then
			  
			     counter <= counter + 1;
                          
                      case counter is
                           when 2000000 =>
                               spi_upload <= '0';
                           when 4000000 =>
                               reset_en <= '0';
                           when 6000000 =>
                               clk_en <= '0';
                           when 8000000 =>
                               Enable_VDD_pix <= '0';
                           when 10000000 =>
                               Enable_VDD_33 <= '0';
                           when 12000000=>
                               Enable_VDD_18 <= '0';
                           when 14000000=>   
                               C5514_enable <= '0';
										 state <= power_down;
                               counter <= 0;
                          when others =>
                       end case;
           else
              counter <= 0;
				  StopCount <= '1';
              state <= power_up_seq;
			  end if;  
				  
		when power_on =>
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
				    state <= power_on;
            end if;
				
				
       when others =>
		      if (sw_in = '0' and StopCount = '1') or (sw_in = '1' and StopCount = '0') then
	             state <= power_down_seq;
	         elsif (sw_in = '1' and StopCount = '1') or (sw_in = '0' and StopCount = '0') then
				    state <= power_up_seq;
            end if;
      
	 end case;
	 
  end if;
  
end process;

end Behavioral;
