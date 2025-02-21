-------------------------------------------------------------------------------
-- i2s_unit.vhd:  VHDL RTL model for the i2s_unit.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_unit is
  
  port (
    clk   : in std_logic;
    rst_n : in std_logic;
    play_in : in std_logic;
    tick_in : in std_logic;
    audio0_in : in std_logic_vector(23 downto 0);
    audio1_in : in std_logic_vector(23 downto 0);    
    req_out : out std_logic;
    ws_out : out std_logic;
    sck_out : out std_logic;
    sdo_out : out std_logic
  );
  
end i2s_unit;

-------------------------------------------------------------------------------
-- Architecture declaration
-------------------------------------------------------------------------------

architecture RTL of i2s_unit is

   -- **Registers**
   signal mode_reg		: std_logic;				-- 1-bit mode register (0: standby, 1: play)
   signal audio_data_reg	: std_logic_vector(47 downto 0); 	-- 48-bit input data register
   signal shift_reg		: std_logic_vector(47 downto 0);	-- 48-bit shift register
   signal counter_reg		: unsigned(8 downto 0);			-- 9-biot counter for waveforms

   -- **Combinational Signals**
   signal next_mode_logic	: std_logic;				-- Next state of mode_reg
   signal audio_data_logic	: std_logic;				-- Load audio_data_reg
   signal req_out_logic		: std_logic;				-- Data request logic
   signal sck_out_logic		: std_logic;				-- Serial clock output logic
   signal ws_out_logic		: std_logic;				-- Word select output logic
   signal shift_logic		: std_logic;				-- Shift enable for shift_reg
   signal counter_logic		: std_logic;				-- Counter reset signal

begin

   -- **Combinational Logic and Output Assignments**
   req_out <= req_out_logic;						-- Direct connection to output
   sck_out <= sck_out_logic;						-- Direct connection to output
   ws_out  <= ws_out_logic;						-- Direct connection to output
   sdo_out <= shift_reg(47);						-- Direct connection to output

      
  
end RTL;

