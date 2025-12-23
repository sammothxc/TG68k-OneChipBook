-- Fixed DMACacheRAM - Uses Block RAM (M4K) instead of logic cells
-- The original had an unregistered read output which prevented block RAM inference
--
-- For Cyclone I/II/III/IV, the RAM output MUST be registered for block RAM inference

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DMACacheRAM is
	generic
		(
			CacheAddrBits : integer := 8;
			CacheWidth : integer := 16
		);
	port (
		clock : in std_logic;
		data : in std_logic_vector(CacheWidth-1 downto 0);
		rdaddress : in std_logic_vector(CacheAddrBits-1 downto 0);
		wraddress : in std_logic_vector(CacheAddrBits-1 downto 0);
		wren : in std_logic;
		q : out std_logic_vector(CacheWidth-1 downto 0)
	);
end DMACacheRAM;

architecture RTL of DMACacheRAM is

	type ram_type is array(0 to (2**CacheAddrBits)-1) of std_logic_vector(CacheWidth-1 downto 0);
	signal ram : ram_type;

begin

	-- Simple dual-port RAM with registered output
	-- This coding style is recognized by Quartus for M4K block RAM inference
	process (clock)
	begin
		if rising_edge(clock) then
			-- Write port
			if wren = '1' then
				ram(to_integer(unsigned(wraddress))) <= data;
			end if;
			
			-- Read port (registered output - REQUIRED for block RAM)
			q <= ram(to_integer(unsigned(rdaddress)));
		end if;
	end process;

end RTL;
